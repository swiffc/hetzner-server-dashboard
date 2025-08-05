# 🔄 Hetzner Server Rebuild Guide

## Why Rebuild?
SSH connection timeouts usually mean the server wasn't created with the SSH key properly configured.

## Steps to Rebuild:

### 1. Go to Hetzner Console
- Open: https://console.hetzner.cloud
- Login to your account

### 2. Navigate to Your Server
- Click "Servers" in left menu
- Find your server (5.78.70.68)
- Click on the server name

### 3. Rebuild Server
- Click "Actions" dropdown (top right)
- Select "Rebuild"
- **IMPORTANT**: This will wipe all data!

### 4. Configure Rebuild
- **Image**: Ubuntu 24.04 LTS
- **SSH Keys**: ✅ Check "hetzner-clean" (your new key)
- **User Data**: Leave empty
- Click "Rebuild Server"

### 5. Wait for Completion
- Rebuild takes 5-10 minutes
- Server will show "Running" when complete
- IP address stays the same: 5.78.70.68

### 6. Test Connection
After rebuild, we'll test:
```bash
ssh hetzner-server
```

## Your SSH Key to Verify:
Make sure this key is selected during rebuild:
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGmE8IfzQ9okdGTaNqaEgLcXpEhlJNqdPPSy3wQICetJ hetzner-clean
```