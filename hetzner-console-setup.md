# 🖥️ Hetzner Console SSH Setup

If regular SSH isn't working, use Hetzner's browser console:

## Step 1: Access Console
1. Go to: https://console.hetzner.cloud
2. Click on your server
3. Click "Console" tab (browser-based terminal)

## Step 2: Login as Root
- Username: `root`
- If prompted for password, use the one from server creation

## Step 3: Add Your SSH Key Manually
```bash
# Create .ssh directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add your public key
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIaMbgONTU4D1HkCCnhMHRRNWg6jndZu0Ig+AYILvVG9 davidcornealius2@gmail.com" >> ~/.ssh/authorized_keys

# Set permissions
chmod 600 ~/.ssh/authorized_keys

# Restart SSH service
systemctl restart ssh
systemctl status ssh
```

## Step 4: Test SSH Connection
Now try connecting from your local machine:
```bash
ssh hetzner-server
```

If this works, proceed with the automated setup script!