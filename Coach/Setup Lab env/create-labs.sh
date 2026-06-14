#!/usr/bin/env bash
set -euo pipefail

############################################
# Usage:
#   bash create-labs.sh <COUNT>
############################################

COUNT="${1:-1}"

# ===== Tenant / naming =====
DOMAIN="${DOMAIN:-mannu2050gmail578.onmicrosoft.com}"
USER_PREFIX="${USER_PREFIX:-lab6auser}"      # e.g. lab1user1, lab1user2
RG_SUFFIX="${RG_SUFFIX:--rg}"               # e.g. lab1user1-rg
CDB_PREFIX="${CDB_PREFIX:-cdb}"             # e.g. cdblab1user1
AOAI_PREFIX="${AOAI_PREFIX:-aoai}"          # e.g. aoai-lab1user1
VM_PREFIX="${VM_PREFIX:-vm}"                # e.g. vm-lab1user1

IMAGE_DEF="myImageDef"
IMAGE="labimage"
GALLERY="myGallery"
IMAGE_VERSION="1.0.0"
RG_NAME_IMG="lab8user1-rg"
# ===== Regions =====
LOCATION="${LOCATION:-westus2}"             # RG / Cosmos DB / VM
AOAI_LOCATION="${AOAI_LOCATION:-eastus}"    # Azure OpenAI (safer for ada-002)

# ===== Shared passwords =====
ENTRA_USER_PASSWORD="${ENTRA_USER_PASSWORD:-<SpecifyYourPasswordhere>}"
VM_ADMIN_PASSWORD="${VM_ADMIN_PASSWORD:-<SpecifyYourPasswordhere>}"

# ===== VM sizing =====
VM_SIZE="${VM_SIZE:-Standard_B2as_v2}"

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

# 4) Cosmos DB
if ! az cosmosdb show --name "$CDB_NAME" --resource-group "$RG_NAME" --only-show-errors >/dev/null 2>&1; then
  echo "Creating Cosmos DB account: $CDB_NAME"
  az cosmosdb create \
    --name "$CDB_NAME" \
    --resource-group "$RG_NAME" \
    --kind GlobalDocumentDB \
    --locations regionName="$LOCATION" failoverPriority=0 isZoneRedundant=false \
    --capabilities EnableNoSQLVectorSearch \
    --only-show-errors
else
  echo "Cosmos DB already exists: $CDB_NAME"
fi

# Use SAME naming as your script (aligned with USER_ALIAS)
IDENTITY_NAME="${USER_ALIAS}-mi"

# Create Managed Identity if missing (fixes ResourceNotFound)
if ! az identity show --name "$IDENTITY_NAME" --resource-group "$RG_NAME" >/dev/null 2>&1; then
  echo "Creating Managed Identity: $IDENTITY_NAME"

  az identity create \
    --name "$IDENTITY_NAME" \
    --resource-group "$RG_NAME" \
    --location "$LOCATION" \
    --only-show-errors
fi

# Now safely fetch principalId
MI_PRINCIPAL_ID=$(az identity show \
  --name "$IDENTITY_NAME" \
  --resource-group "$RG_NAME" \
  --query principalId -o tsv)


# Role Assignment → Current User
az cosmosdb sql role assignment create \
  --account-name "$CDB_NAME" \
  --resource-group "$RG_NAME" \
  --scope "//" \
  --principal-id "$USER_OBJECT_ID" \
  --role-definition-id "00000000-0000-0000-0000-000000000002"


# Role Assignment → Managed Identity
az cosmosdb sql role assignment create \
  --account-name "$CDB_NAME" \
  --resource-group "$RG_NAME" \
  --scope "//" \
  --principal-id "$MI_PRINCIPAL_ID" \
  --role-definition-id "00000000-0000-0000-0000-000000000002"


  # 5) Azure OpenAI + multiple deployments

AOAI_ENDPOINT="NOT_CREATED"
AOAI_KEY="NOT_CREATED"

# Create OpenAI account if not exists
if ! az cognitiveservices account show -g "$RG_NAME" -n "$AOAI_NAME" --only-show-errors >/dev/null 2>&1; then
  echo "Creating Azure OpenAI resource: $AOAI_NAME"

  az cognitiveservices account create \
    --name "$AOAI_NAME" \
    --resource-group "$RG_NAME" \
    --kind OpenAI \
    --sku S0 \
    --location "$AOAI_LOCATION" \
    --yes \
    --only-show-errors
fi


# Define deployments (simple arrays instead of objects)
DEPLOY_NAMES=("gpt-4o" "text-embedding-3-small")
MODEL_NAMES=("gpt-4o" "text-embedding-3-small")
MODEL_VERSIONS=("2024-11-20" "1")
SKU_NAMES=("GlobalStandard" "Standard")
SKU_CAPACITY=(30 5)


# Loop through deployments
for i in "${!DEPLOY_NAMES[@]}"; do
  DEPLOY_NAME="${DEPLOY_NAMES[$i]}"

  if ! az cognitiveservices account deployment show \
    --name "$AOAI_NAME" \
    --resource-group "$RG_NAME" \
    --deployment-name "$DEPLOY_NAME" \
    --only-show-errors >/dev/null 2>&1; then

    echo "Deploying ${MODEL_NAMES[$i]}..."

    az cognitiveservices account deployment create \
      --name "$AOAI_NAME" \
      --resource-group "$RG_NAME" \
      --deployment-name "$DEPLOY_NAME" \
      --model-name "${MODEL_NAMES[$i]}" \
      --model-version "${MODEL_VERSIONS[$i]}" \
      --model-format OpenAI \
      --sku-name "${SKU_NAMES[$i]}" \
      --sku-capacity "${SKU_CAPACITY[$i]}" \
      --only-show-errors
  else
    echo "Deployment exists: $DEPLOY_NAME"
  fi
done


# Get endpoint + key
AOAI_ENDPOINT=$(az cognitiveservices account show \
  --name "$AOAI_NAME" \
  --resource-group "$RG_NAME" \
  --query "properties.endpoint" \
  -o tsv 2>/dev/null || echo "NOT_AVAILABLE")

# ===== Assign OpenAI RBAC =====

echo "Assigning Azure OpenAI role..."

AOAI_ID=$(az cognitiveservices account show \
  --name "$AOAI_NAME" \
  --resource-group "$RG_NAME" \
  --query id -o tsv)

USER_EMAIL="$UPN"

az role assignment create \
  --assignee "$USER_EMAIL" \
  --role "Cognitive Services OpenAI User" \
  --scope "$AOAI_ID" \
  --only-show-errors || true


  # 6) Windows 11 VM

export MSYS_NO_PATHCONV=1

IMAGE_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME_IMG/providers/Microsoft.Compute/galleries/$GALLERY/images/$IMAGE_DEF/versions/$IMAGE_VERSION"

echo "$SUBSCRIPTION_ID"
echo "$RG_NAME_IMG"
echo "$GALLERY"
echo "$IMAGE_DEF"
echo "$IMAGE_VERSION"

  if ! az vm show -g "$RG_NAME" -n "$VM_NAME" --only-show-errors >/dev/null 2>&1; then
    echo "Creating Windows 11 VM: $VM_NAME"
    az vm create \
      --resource-group "$RG_NAME" \
      --name "$VM_NAME" \
      --location "$LOCATION" \
      --image $IMAGE_ID \
      --size "$VM_SIZE" \
      --admin-username "$VM_ADMIN_USER" \
      --admin-password "$VM_ADMIN_PASSWORD" \
      --security-type TrustedLaunch \
      --enable-secure-boot true \
      --enable-vtpm true \
      --public-ip-sku Standard \
      --public-ip-address-dns-name "$VM_NAME" \
      --debug
  else
    echo "VM already exists: $VM_NAME"
  fi

  # 7) Auto-shutdown
  az vm auto-shutdown \
    --resource-group "$RG_NAME" \
    --name "$VM_NAME" \
    --time "$SHUTDOWN_TIME_UTC" \
    --only-show-errors

  echo "Completed lab $i: $USER_ALIAS"
done

echo ""
echo "All labs have been created."
echo "VM auto-shutdown time (UTC): $SHUTDOWN_TIME_UTC"