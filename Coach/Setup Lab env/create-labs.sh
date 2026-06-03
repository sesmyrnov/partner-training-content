#!/usr/bin/env bash
set -euo pipefail

############################################
# Usage:
#   bash create-labs.sh <COUNT>
############################################

COUNT="${1:-1}"

# ===== Tenant / naming =====
DOMAIN="${DOMAIN:-mannu2050gmail578.onmicrosoft.com}"
USER_PREFIX="${USER_PREFIX:-labeuser}"      # e.g. lab1user1, lab1user2
RG_SUFFIX="${RG_SUFFIX:--rg}"               # e.g. lab1user1-rg
CDB_PREFIX="${CDB_PREFIX:-cdb}"             # e.g. cdblab1user1
AOAI_PREFIX="${AOAI_PREFIX:-aoai}"          # e.g. aoai-lab1user1
VM_PREFIX="${VM_PREFIX:-vm}"                # e.g. vm-lab1user1

# ===== Regions =====
LOCATION="${LOCATION:-westus2}"             # RG / Cosmos DB / VM
AOAI_LOCATION="${AOAI_LOCATION:-eastus}"    # Azure OpenAI (safer for ada-002)

# ===== Shared passwords =====
ENTRA_USER_PASSWORD="${ENTRA_USER_PASSWORD:-LabUser!23456Aa}"
VM_ADMIN_PASSWORD="${VM_ADMIN_PASSWORD:-LabUser!23456Aa}"

# ===== VM sizing =====
VM_SIZE="${VM_SIZE:-Standard_F2als_v7}"

# ===== Repo =====
REPO_URL="${REPO_URL:-https://github.com/AzureCosmosDB/partner-training-content.git}"

# ===== Azure OpenAI deployment =====
AOAI_DEPLOYMENT_NAME="${AOAI_DEPLOYMENT_NAME:-ada2-embedding}"
AOAI_MODEL_NAME="${AOAI_MODEL_NAME:-text-embedding-ada-002}"
AOAI_MODEL_VERSION="${AOAI_MODEL_VERSION:-2}"

if ! [[ "$COUNT" =~ ^[0-9]+$ ]] || [ "$COUNT" -lt 1 ]; then
  echo "COUNT must be a positive integer."
  exit 1
fi

echo "Using domain: $DOMAIN"
echo "Creating $COUNT lab(s)..."

# Auto-shutdown target = now + 12h in UTC (HHmm)
SHUTDOWN_TIME_UTC="$(date -u -d '+12 hours' +%H%M)"
echo "VM auto-shutdown time (UTC): $SHUTDOWN_TIME_UTC"

# Register providers (safe to rerun)
for ns in Microsoft.DocumentDB Microsoft.CognitiveServices Microsoft.Compute Microsoft.Network Microsoft.Storage; do
  echo "Registering provider: $ns"
  az provider register --namespace "$ns" --only-show-errors 1>/dev/null || true
done


# ==========================================================
# Main loop
# ==========================================================
for i in $(seq 1 "$COUNT"); do
  USER_ALIAS="${USER_PREFIX}${i}"                 # same alias used for Entra + VM username
  VM_ADMIN_USER="$USER_ALIAS"
  UPN="${USER_ALIAS}@${DOMAIN}"
  MAIL_NICKNAME="${USER_ALIAS}"
  RG_NAME="${USER_ALIAS}${RG_SUFFIX}"
  CDB_NAME="$(echo "${CDB_PREFIX}${USER_ALIAS}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')"
  AOAI_NAME="$(echo "${AOAI_PREFIX}-${USER_ALIAS}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')"
  VM_NAME="${VM_PREFIX}-${USER_ALIAS}"

  echo "===================================================="
  echo "Creating lab $i"
  echo "Entra user:     $UPN"
  echo "VM admin user:  $VM_ADMIN_USER"
  echo "ResourceGroup:  $RG_NAME"
  echo "Cosmos DB:      $CDB_NAME"
  echo "Azure OpenAI:   $AOAI_NAME"
  echo "VM:             $VM_NAME"
  echo "===================================================="

  # 1) Entra ID user
  if az ad user show --id "$UPN" --only-show-errors >/dev/null 2>&1; then
    echo "User already exists: $UPN"
  else
    echo "Creating Entra user: $UPN"
    az ad user create \
      --display-name "$USER_ALIAS" \
      --user-principal-name "$UPN" \
      --mail-nickname "$MAIL_NICKNAME" \
      --password "$ENTRA_USER_PASSWORD" \
      --force-change-password-next-sign-in false \
      --only-show-errors
  fi

  # 2) Resource group
  echo "Creating resource group: $RG_NAME"
  az group create \
    --name "$RG_NAME" \
    --location "$LOCATION" \
    --only-show-errors 1>/dev/null

# 3) Contributor access for the Entra user
echo "Resolving subscription + object ID..."

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo $SUBSCRIPTION_ID

# Allow Entra propagation for newly created user
sleep 20

USER_OBJECT_ID=$(az ad user show \
  --id "$UPN" \
  --query "id" \
  -o tsv 2>/dev/null || echo "")

echo $USER_OBJECT_ID

if [ -n "$USER_OBJECT_ID" ] && [ -n "$SUBSCRIPTION_ID" ]; then
  echo "Assigning Contributor on $RG_NAME to $UPN"
  az role assignment create \
    --assignee-object-id "$USER_OBJECT_ID" \
    --assignee-principal-type User \
    --role "Owner" \
    --scope "subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME" \
    --only-show-errors || true
else
  echo "WARNING: Skipping role assignment (missing object ID or subscription)"
fi

  # 4) Cosmos DB
  if ! az cosmosdb show --name "$CDB_NAME" --resource-group "$RG_NAME" --only-show-errors >/dev/null 2>&1; then
    echo "Creating Cosmos DB account: $CDB_NAME"
    az cosmosdb create \
      --name "$CDB_NAME" \
      --resource-group "$RG_NAME" \
      --kind GlobalDocumentDB \
      --locations regionName="$LOCATION" failoverPriority=0 isZoneRedundant=false \
      --capabilities EnableServerless \
      --only-show-errors
  else
    echo "Cosmos DB already exists: $CDB_NAME"
  fi

  COSMOS_CONN=$(az cosmosdb keys list \
    --name "$CDB_NAME" \
    --resource-group "$RG_NAME" \
    --type connection-strings \
    --query "connectionStrings[0].connectionString" \
    -o tsv)

  # 5) Azure OpenAI + embedding deployment
  AOAI_ENDPOINT="NOT_CREATED"
  AOAI_KEY="NOT_CREATED"
  AOAI_DEPLOYMENT_OUT="$AOAI_DEPLOYMENT_NAME"

  if ! az cognitiveservices account show -g "$RG_NAME" -n "$AOAI_NAME" --only-show-errors >/dev/null 2>&1; then
    echo "Creating Azure OpenAI resource: $AOAI_NAME"
    set +e
    az cognitiveservices account create \
      --name "$AOAI_NAME" \
      --resource-group "$RG_NAME" \
      --kind OpenAI \
      --sku S0 \
      --location "$AOAI_LOCATION" \
      --yes \
      --only-show-errors
    AOAI_CREATE_RC=$?
    set -e
  else
    AOAI_CREATE_RC=0
  fi

  if [ "$AOAI_CREATE_RC" -eq 0 ]; then
    if ! az cognitiveservices account deployment show \
      --name "$AOAI_NAME" \
      --resource-group "$RG_NAME" \
      --deployment-name "$AOAI_DEPLOYMENT_NAME" \
      --only-show-errors >/dev/null 2>&1; then
      echo "Deploying model $AOAI_MODEL_NAME on $AOAI_NAME"
      set +e
      az cognitiveservices account deployment create \
        --name "$AOAI_NAME" \
        --resource-group "$RG_NAME" \
        --deployment-name "$AOAI_DEPLOYMENT_NAME" \
        --model-name "$AOAI_MODEL_NAME" \
        --model-version "$AOAI_MODEL_VERSION" \
        --model-format OpenAI \
        --sku-name Standard \
        --sku-capacity 1 \
        --only-show-errors
      AOAI_DEPLOY_RC=$?
      set -e
    else
      AOAI_DEPLOY_RC=0
    fi

    AOAI_ENDPOINT=$(az cognitiveservices account show \
      --name "$AOAI_NAME" \
      --resource-group "$RG_NAME" \
      --query "properties.endpoint" \
      -o tsv 2>/dev/null || echo "NOT_AVAILABLE")

    AOAI_KEY=$(az cognitiveservices account keys list \
      --name "$AOAI_NAME" \
      --resource-group "$RG_NAME" \
      --query "key1" \
      -o tsv 2>/dev/null || echo "NOT_AVAILABLE")

    if [ "${AOAI_DEPLOY_RC:-0}" -ne 0 ]; then
      AOAI_DEPLOYMENT_OUT="DEPLOYMENT_FAILED"
      echo "WARNING: Azure OpenAI deployment failed for $AOAI_NAME"
    fi
  else
    AOAI_DEPLOYMENT_OUT="RESOURCE_CREATE_FAILED"
    echo "WARNING: Azure OpenAI resource creation failed for $AOAI_NAME"
  fi

  # 6) Windows 11 VM
  if ! az vm show -g "$RG_NAME" -n "$VM_NAME" --only-show-errors >/dev/null 2>&1; then
    echo "Creating Windows 11 VM: $VM_NAME"
    az vm create \
      --resource-group "$RG_NAME" \
      --name "$VM_NAME" \
      --location "$LOCATION" \
      --image "MicrosoftWindowsDesktop:Windows-11:win11-24h2-pro:latest" \
      --size "$VM_SIZE" \
      --admin-username "$VM_ADMIN_USER" \
      --admin-password "$VM_ADMIN_PASSWORD" \
      --security-type TrustedLaunch \
      --enable-secure-boot true \
      --enable-vtpm true \
      --public-ip-sku Standard \
      --only-show-errors
  else
    echo "VM already exists: $VM_NAME"
  fi

  # 7) Auto-shutdown
  az vm auto-shutdown \
    --resource-group "$RG_NAME" \
    --name "$VM_NAME" \
    --time "$SHUTDOWN_TIME_UTC" \
    --only-show-errors

  # 8) Install tools + clone repo + write credentials on VM
  az vm run-command invoke \
    --resource-group "$RG_NAME" \
    --name "$VM_NAME" \
    --command-id RunPowerShellScript \
    --scripts @vm-bootstrap.ps1 \
    --parameters \
      VmAdminUser="$VM_ADMIN_USER" \
      CosmosConn="$COSMOS_CONN" \
      AoaiEndpoint="$AOAI_ENDPOINT" \
      AoaiKey="$AOAI_KEY" \
      AoaiDeployment="$AOAI_DEPLOYMENT_OUT" \
      RepoUrl="$REPO_URL" \
    --only-show-errors

  echo "Completed lab $i: $USER_ALIAS"
done

echo ""
echo "All labs have been created."
echo "VM auto-shutdown time (UTC): $SHUTDOWN_TIME_UTC"