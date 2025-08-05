# 🚀 Full Setup Guide: Configuring Your Hetzner Server for DevOps Using Cursor Editor

This document serves as a complete Product Requirements Document (PRD)-style guide for setting up your Hetzner Ubuntu server (IP: 5.78.70.68) in a full DevOps style using Cursor, the AI-powered code editor. It includes requirements, step-by-step instructions, scripts, and best practices.

**Goal**: Create a secure, containerized DevOps environment for building, testing, and deploying apps/software using Cursor for local scripting and remote editing directly on the server.

## 📋 1. Product Overview and Requirements

### Objective
- Set up a Hetzner CPX41 server (8 vCPUs, 16 GB RAM, 240 GB disk) with Ubuntu 24.04 for DevOps workflows
- Enable remote development via SSH in Cursor for seamless code editing, debugging, and deployment
- Implement core DevOps practices: security hardening, containerization (Docker), CI/CD (GitHub Actions or Jenkins), monitoring (Prometheus/Grafana), and automation

### Key Features/Requirements
- **Security**: SSH key-based access, firewall (UFW), non-root user, disabled password auth
- **Development Tools**: Git, Node.js, Python, text editors
- **Containerization**: Docker for app isolation
- **CI/CD**: GitHub Actions for automation; optional Jenkins
- **Monitoring**: Prometheus for metrics, Grafana for dashboards
- **Remote Access**: Use Cursor's Remote - SSH extension to edit files directly on the server

### Assumptions
- You have Cursor installed (download from [cursor.sh](https://cursor.sh) if not)
- Server is accessible via IP 5.78.70.68
- Ubuntu 16.04 initially, but we'll rebuild to 24.04

### Non-Functional Requirements
- Secure (least privilege)
- Scalable
- Cost-effective (<$40/month)
- Easy to maintain via scripts

### Success Metrics
- Server online
- Sample Node.js app deployed and accessible
- Monitoring dashboard running

### Dependencies
- **Local**: Cursor editor, SSH client (built-in terminal)
- **Server**: Hetzner Console access for rebuilds/backups
- **External**: GitHub account for CI/CD

## 🛠️ 2. Setup Steps in Cursor

Follow these steps within Cursor. Use the integrated terminal (`Ctrl + \``) for commands.

### Step 2.1: Install Remote - SSH Extension in Cursor

Cursor is based on VS Code, so it supports the Remote - SSH extension for direct server editing.

1. Open Cursor
2. Go to Extensions view (`Ctrl + Shift + X`)
3. Search for "Remote - SSH" (published by Microsoft)
4. Click Install
   > **Note**: If it shows an error like "only supported in Microsoft versions," ensure you're using the latest Cursor version (as of 2025, this is resolved in Cursor 0.48+)
5. Restart Cursor if prompted

### Step 2.2: Configure SSH in Cursor

#### Generate or use an existing SSH key:
```bash
# In Cursor terminal
ssh-keygen -t ed25519 -C "your_email@example.com"
# Save to default location
```

#### Add public key to Hetzner:
```bash
# Copy public key
cat ~/.ssh/id_ed25519.pub
```
- In Hetzner Console > Project > Security > SSH Keys > Add SSH Key > Paste and save

#### Add SSH config for easy connection:
In Cursor, create/edit `~/.ssh/config`:
```text
Host hetzner-server
    HostName 5.78.70.68
    User root
    IdentityFile ~/.ssh/id_ed25519
```

#### Test connection:
```bash
ssh hetzner-server
# Accept fingerprint
```

### Step 2.3: Connect to Server Remotely in Cursor

1. In Cursor: `Ctrl + Shift + P` (Command Palette) > Type "Remote-SSH: Connect to Host" > Select "hetzner-server"
2. Cursor will install VS Code Server on your Hetzner machine (automatic)
3. Once connected, the status bar shows "SSH: hetzner-server"
4. You can now open folders/files on the server directly (e.g., File > Open Folder > /root/)

### Step 2.4: Rebuild Server to Ubuntu 24.04 (If Needed)

Ubuntu 16.04 is unsupported; rebuild for security.

1. In Hetzner Console: Select server > Rebuild > Choose Ubuntu 24.04 > Add your SSH key > Confirm
   > **Warning**: This wipes data; snapshot first if needed
2. After rebuild (5-10 mins), reconnect via Cursor Remote - SSH

### Step 2.5: Secure the Server

Create a new file in Cursor (`secure-server.sh`) on your local machine, then copy/run it remotely.

```bash
#!/bin/bash

# Run as root after connecting
echo "🔒 Securing server..."

# Create non-root user
adduser devopsuser --gecos "" --disabled-password
echo "devopsuser:your_secure_password" | chpasswd  # Change password later
usermod -aG sudo devopsuser

# Copy SSH key to new user
rsync --archive --chown=devopsuser:devopsuser ~/.ssh /home/devopsuser

# Disable root login and password auth
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh

# Set up firewall
apt install ufw -y
ufw allow OpenSSH
ufw --force enable

echo "✅ Security setup complete. Log in as devopsuser."
```

**To execute:**
1. Connect remotely in Cursor
2. Open terminal in remote workspace (`Ctrl + \``)
3. Paste and run: `bash secure-server.sh`
4. Disconnect and reconnect as `devopsuser@5.78.70.68` (update SSH config)

### Step 2.6: Install Development Tools

In remote terminal:
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y curl wget git unzip software-properties-common python3-pip vim

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installations
node --version
npm --version
python3 --version
git --version
```

### Step 2.7: Install Docker for Containerization

```bash
# Install prerequisites
sudo apt install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings

# Add Docker GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, then test
docker run hello-world
```

### Step 2.8: Set Up CI/CD with GitHub Actions

#### Create GitHub repository:
1. Create a GitHub repo in browser
2. In Cursor (remote): Clone repo
   ```bash
   git clone https://github.com/yourusername/yourrepo.git
   ```

#### Create workflow file:
Create `.github/workflows/deploy.yml` in Cursor:
```yaml
name: Deploy to Hetzner
on: 
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Deploy via SSH
      uses: appleboy/ssh-action@master
      with:
        host: 5.78.70.68
        username: devopsuser
        key: ${{ secrets.SSH_PRIVATE_KEY }}
        script: |
          cd /path/to/app
          git pull
          docker compose up -d --build
```

#### Add secrets:
In GitHub: Settings > Secrets and variables > Actions > New repository secret
- Name: `SSH_PRIVATE_KEY`
- Value: Your private key content from `~/.ssh/id_ed25519`

### Step 2.9: Set Up Monitoring (Prometheus + Grafana)

```bash
# Install Prometheus
sudo apt install prometheus -y
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Install Grafana
sudo apt install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt update
sudo apt install grafana -y

# Start services
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Configure firewall
sudo ufw allow 9090  # Prometheus
sudo ufw allow 3000  # Grafana

echo "📊 Monitoring setup complete!"
echo "Prometheus: http://5.78.70.68:9090"
echo "Grafana: http://5.78.70.68:3000 (admin/admin)"
```

### Step 2.10: Deploy Sample Application

In Cursor (remote), create a sample application:

#### Create project structure:
```bash
mkdir -p ~/myapp
cd ~/myapp
```

#### Create `app.js`:
```javascript
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from DevOps!',
    timestamp: new Date().toISOString(),
    server: 'Hetzner',
    env: process.env.NODE_ENV || 'development'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', uptime: process.uptime() });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running at http://0.0.0.0:${port}`);
});
```

#### Create `package.json`:
```json
{
  "name": "hetzner-devops-app",
  "version": "1.0.0",
  "description": "Sample DevOps application",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "nodemon app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
```

#### Create `Dockerfile`:
```dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy app source
COPY . .

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Run app
CMD ["npm", "start"]
```

#### Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

#### Deploy the application:
```bash
# Install dependencies
npm install

# Build and run with Docker
docker compose up -d --build

# Allow port through firewall
sudo ufw allow 3000

# Test locally
curl http://localhost:3000

echo "🚀 App deployed!"
echo "Access at: http://5.78.70.68:3000"
```

## ✅ 3. Testing and Validation

### Verify SSH Connection
```bash
# Test SSH connection works in Cursor
ssh hetzner-server
```

### Test Application Deployment
```bash
# Test app responds
curl http://5.78.70.68:3000
curl http://5.78.70.68:3000/health
```

### Verify CI/CD Pipeline
1. Make a change to your code
2. Push to GitHub
3. Check Actions tab for deployment status

### Check Monitoring
- Prometheus: http://5.78.70.68:9090
- Grafana: http://5.78.70.68:3000 (admin/admin)

### Security Verification
```bash
# Verify no root login
ssh root@5.78.70.68  # Should fail

# Check firewall status
sudo ufw status

# Verify services
sudo systemctl status docker
sudo systemctl status prometheus
sudo systemctl status grafana-server
```

## 🔧 4. Maintenance and Scaling

### Regular Maintenance
```bash
# Weekly security updates
sudo apt update && sudo apt upgrade -y

# Docker cleanup
docker system prune -f

# Check disk space
df -h

# Monitor logs
journalctl -u docker.service --since "1 hour ago"
```

### Backup Strategy
1. **Hetzner Snapshots**: Weekly automated snapshots
2. **Application Data**: Daily database backups
3. **Configuration**: Store configs in Git

### Scaling Options
- **Vertical**: Upgrade server specs in Hetzner Console
- **Horizontal**: Add load balancers and multiple servers
- **Container Orchestration**: Migrate to Kubernetes for larger deployments

### Performance Monitoring
```bash
# System resources
htop
iotop
nethogs

# Application metrics
docker stats
docker logs <container-name>

# Network monitoring
sudo netstat -tlnp
sudo ss -tlnp
```

## 🚨 5. Troubleshooting

### Common Issues

#### SSH Connection Problems
```bash
# Reset SSH service
sudo systemctl restart ssh

# Check SSH logs
sudo journalctl -u ssh.service

# Verify SSH config
sudo sshd -T
```

#### Docker Issues
```bash
# Restart Docker service
sudo systemctl restart docker

# Check Docker logs
sudo journalctl -u docker.service

# Test Docker functionality
docker run hello-world
```

#### Application Not Accessible
```bash
# Check if app is running
docker ps

# Check app logs
docker logs <container-name>

# Verify port is open
sudo ufw status
sudo netstat -tlnp | grep 3000
```

#### Monitoring Issues
```bash
# Restart monitoring services
sudo systemctl restart prometheus
sudo systemctl restart grafana-server

# Check service status
sudo systemctl status prometheus
sudo systemctl status grafana-server
```

### Emergency Procedures

#### Server Recovery
1. Access Hetzner Console
2. Use Recovery Mode if needed
3. Mount rescue system
4. Backup critical data
5. Rebuild from snapshot

#### Application Recovery
```bash
# Stop all containers
docker stop $(docker ps -q)

# Remove problematic containers
docker rm $(docker ps -aq)

# Rebuild from source
cd ~/myapp
docker compose up -d --build
```

## 📚 6. Additional Resources

### Useful Commands Cheat Sheet
```bash
# System monitoring
htop                          # Interactive process viewer
df -h                         # Disk usage
free -h                       # Memory usage
systemctl status <service>    # Service status

# Docker management
docker ps                     # Running containers
docker images                 # Available images
docker logs <container>       # Container logs
docker exec -it <container> bash  # Container shell

# Git operations
git status                    # Repository status
git pull                      # Pull latest changes
git add . && git commit -m "message"  # Stage and commit
git push                      # Push changes

# Network diagnostics
curl -I http://localhost:3000 # Test HTTP endpoint
netstat -tlnp                 # Open ports
ping google.com               # Network connectivity
```

### Best Practices
1. **Security**: Regularly update packages, use strong passwords, monitor logs
2. **Backup**: Automate backups, test restore procedures
3. **Monitoring**: Set up alerts for critical metrics
4. **Documentation**: Keep runbooks updated
5. **Testing**: Test deployments in staging first

### Further Reading
- [Hetzner Cloud Documentation](https://docs.hetzner.com/)
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [Cursor Editor Documentation](https://cursor.sh/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)

---

## 🎉 Conclusion

This comprehensive setup provides you with a production-ready DevOps environment on Hetzner Cloud using Cursor editor. You now have:

✅ **Secure server** with proper authentication and firewall  
✅ **Development environment** with modern tools and languages  
✅ **Containerized applications** using Docker  
✅ **Automated CI/CD** pipeline with GitHub Actions  
✅ **Monitoring and observability** with Prometheus and Grafana  
✅ **Remote development** capabilities with Cursor editor  

Your server is now ready for any development project, from simple web applications to complex microservices architectures. Use Cursor's AI chat (`Ctrl + L`) for code assistance during development!

**Next Steps**: Start building your applications, set up additional monitoring alerts, and explore advanced DevOps practices like Infrastructure as Code (IaC) with Terraform.