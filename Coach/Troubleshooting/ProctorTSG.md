# **Azure Cosmos DB Hands-on Lab – Proctor Troubleshooting Guide (TSG)**

## **Purpose**

This guide helps proctors quickly resolve common issues faced by participants during the hands-on lab (VM access, login, credentials, and environment issues).

---

## **1. VM Issues – Shutdown / Not Available**

### **Symptoms**

- VM is not responding
- RDP fails or times out
- User says VM is not accessible
- Portal shows VM as **Stopped (deallocated)**

### **Resolution Steps**

1. Ask user to log into **Azure Portal**
   - Navigate to: `portal.azure.com`

2. Go to: **Resource Group → Virtual Machine**

3. Check VM Status:
   - If **Stopped (deallocated)** → Click **Start**

4. If **Starting** → Wait 1–2 minutes

5. Once running:
   - Click **Connect → RDP**

6. Download RDP file and retry

✅ **Pro Tip for Proctors**
- Many labs auto-shutdown VMs → this is **expected behaviour**
- Ensure user waits until VM status = **Running**

---

## **2. Unable to Find Login Credentials**

### **Symptoms**

- User cannot find login details email
- Lost username/password
- Confused about assigned lab

### **Resolution Steps**

1. Ask for: ✅ Registered **mobile number**

2. Search in: 📄 **Registration Sheet / Master Tracker**

3. Identify:
   - Assigned lab user
   - VM name
   - Credentials

4. Share with user securely

✅ **Best Practice**
- Do not guess credentials
- Always refer to the **registration source of truth**

---

## **3. Azure Portal Login (Domain + MFA Setup)**

### **Steps to Guide User**

1. Open browser → go to: `portal.azure.com`

2. Enter **domain user**
   - Example: `xxx@.onmicrosoft.com`

3. Enter: Password (same as VM password)

4. MFA Setup:
   - Install **Microsoft Authenticator**
   - Scan QR code
   - Enter verification code

5. After login: Click **View All Resources**

6. Validate user sees:
   - ✅ Virtual Machine
   - ✅ Cosmos DB
   - ✅ Azure OpenAI
   - ✅ Supporting resources

> ⚠️ All lab resources are under **one Resource Group** – ensure users stay within that.

---

## **4. RDP Login Failure**

### **Symptoms**

- "Login failed"
- "Invalid username/password"
- RDP connects but cannot log in

### **Root Cause**

User is entering **domain credentials inside VM**

### **✅ Resolution**

Inside RDP → use **LOCAL VM credentials only**

**Correct:**
```
Username: labuser / localadmin (as provided)
Password: [provided credential]
```

**Incorrect:**
```
xxx@tenant.onmicrosoft.com  ❌
```

✅ **Key Rule**
- **Domain user** → only for Azure Portal
- **Local user** → for VM login (RDP)

---

## **5. MFA Issues**

### **Symptoms**

- Not receiving code
- QR scan not working
- Code expired

### **Resolution**

- Ensure:
  - Phone internet is ON
  - Authenticator app installed

- Retry:
  - Use **"Enter code manually"**
  - Wait for next rotating code if expired

✅ **Tip**
- Codes expire quickly → ask user to **enter immediately**

---

## **6. Resources Not Visible in Portal**

### **Symptoms**

- User logs in but sees no resources

### **Resolution Steps**

1. Check: Correct **tenant/domain login**

2. Verify: User is in correct **subscription**

3. Navigate manually: Resource Groups → Assigned RG

✅ **Shortcut**
- Share Resource Group name explicitly

---

## **7. Wrong Resource Usage**

### **Symptoms**

- User working in wrong resource group
- Cannot find Cosmos DB / OpenAI

### **Resolution**

- Reinforce:
  - ✅ Use only assigned **Resource Group**
  - ✅ Do not create new resources

---

## **8. Slow VM / Performance Issues**

### **Symptoms**

- Lag in RDP
- Commands slow

### **Resolution**

- Ask user to:
  - Close extra apps
  - Reconnect RDP
  - Check local internet
  - If severe: Restart VM (last resort)

---

## **9. Escalation Guidelines**

Escalate when:
- VM fails to start
- Credentials missing in registration sheet
- Multiple users impacted
- Azure service issue suspected

Provide:
- User name
- Resource Group
- VM name
- Issue summary

---

## **✅ Quick Proctor Checklist**

Before escalating, confirm:
- ✅ VM is running
- ✅ User using correct credentials (local vs domain)
- ✅ MFA completed
- ✅ Resource group verified
- ✅ Registration details checked

---

## **Golden Rules for Proctors**

- Stay calm and guide step-by-step
- Do NOT assume — always verify
- Use registration sheet as source of truth
- Most issues = **VM stopped OR wrong credentials**
