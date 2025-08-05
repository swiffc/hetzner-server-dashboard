# 🚀 Hetzner DevOps Server Setup

Complete DevOps environment setup for your Hetzner server (5.78.70.68) using Cursor editor.

## 📁 Files Overview

| File | Purpose |
|------|---------|
| `hetzner-devops-setup.md` | **Complete setup guide** - Step-by-step instructions |
| `hetzner-setup-script.sh` | **Automated setup script** - Run on server to install everything |
| `hetzner-quick-deploy.sh` | **Deployment script** - Quick commands for common tasks |
| `hetzner-cursor-config.md` | **Cursor configuration** - Remote development setup |

## 🎯 Quick Start

### 1. Initial Server Setup

```bash
# Copy setup script to your Hetzner server
scp hetzner-setup-script.sh root@5.78.70.68:~/

# SSH to server and run setup
ssh root@5.78.70.68
chmod +x hetzner-setup-script.sh
./hetzner-setup-script.sh
```

### 2. Configure Cursor Editor

Follow the guide in `hetzner-cursor-config.md` to set up remote development.

### 3. Quick Deployment

```bash
# Check server status
./hetzner-quick-deploy.sh status

# Deploy sample application
./hetzner-quick-deploy.sh deploy-sample

# Deploy with Docker
./hetzner-quick-deploy.sh deploy-docker
```

## 🌟 What You Get

✅ **Secure server** - SSH keys, firewall, non-root user  
✅ **Docker containerization** - Full Docker + Docker Compose  
✅ **Development tools** - Node.js, Git, Python, build tools  
✅ **Monitoring** - Prometheus + Grafana dashboards  
✅ **CI/CD ready** - GitHub Actions integration  
✅ **Remote development** - Cursor editor with SSH  
✅ **Sample application** - Ready-to-deploy Node.js app  

## 🔧 Server Specs

- **Provider**: Hetzner Cloud
- **Server**: CPX41 (8 vCPUs, 16GB RAM, 240GB SSD)
- **OS**: Ubuntu 24.04 LTS
- **IP**: 5.78.70.68

## 🌐 Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| **Application** | http://5.78.70.68:3000 | - |
| **Prometheus** | http://5.78.70.68:9090 | - |
| **Grafana** | http://5.78.70.68:3000 | admin/admin |
| **SSH** | ssh devopsuser@5.78.70.68 | SSH key |

## 📋 Common Commands

```bash
# Server management
./hetzner-quick-deploy.sh status      # Check server status
./hetzner-quick-deploy.sh update      # Update packages
./hetzner-quick-deploy.sh logs        # View logs
./hetzner-quick-deploy.sh backup      # Backup data

# Application deployment
./hetzner-quick-deploy.sh deploy-sample    # Deploy with PM2
./hetzner-quick-deploy.sh deploy-docker    # Deploy with Docker

# Development tools
./hetzner-quick-deploy.sh install-tools    # Install additional tools
./hetzner-quick-deploy.sh check           # Test connection
```

## 🔒 Security Notes

- SSH key-based authentication only
- Firewall configured with UFW
- Non-root user (devopsuser) for operations
- Automatic security updates enabled

## 📚 Documentation

1. **[Complete Setup Guide](hetzner-devops-setup.md)** - Detailed step-by-step instructions
2. **[Cursor Configuration](hetzner-cursor-config.md)** - Remote development setup
3. **Setup Script** - Automated server configuration
4. **Deploy Script** - Quick deployment commands

## 🆘 Troubleshooting

### Can't connect to server?
```bash
# Test connection
ssh -v devopsuser@5.78.70.68

# Check if server is running in Hetzner Console
```

### Application not accessible?
```bash
# Check if application is running
./hetzner-quick-deploy.sh status

# Check firewall
ssh devopsuser@5.78.70.68 "sudo ufw status"
```

### Docker issues?
```bash
# Restart Docker
ssh devopsuser@5.78.70.68 "sudo systemctl restart docker"
```

## 🚀 Next Steps

1. **Set up monitoring alerts** in Grafana
2. **Configure CI/CD pipeline** with GitHub Actions
3. **Add SSL certificates** for HTTPS
4. **Set up backup automation**
5. **Scale with load balancers** if needed

---

**Happy DevOps!** 🎉

For detailed instructions, see `hetzner-devops-setup.md`