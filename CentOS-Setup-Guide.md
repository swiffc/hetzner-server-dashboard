# CentOS Server Setup for Dashboard Integration

## 🚀 Complete CentOS Setup Guide

### Step 1: Initial System Update
```bash
# Update system packages
sudo yum update -y

# Install EPEL repository for additional packages
sudo yum install -y epel-release
```

### Step 2: Install Essential Development Tools
```bash
# Install development tools
sudo yum groupinstall -y "Development Tools"

# Install essential packages
sudo yum install -y curl wget git vim nano htop tree unzip
```

### Step 3: Install Node.js (for API endpoints)
```bash
# Install Node.js 18.x LTS
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Verify installation
node --version
npm --version
```

### Step 4: Install Docker (for container management)
```bash
# Install Docker
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER

# Verify Docker installation
sudo docker --version
```

### Step 5: Install Docker Compose
```bash
# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
```

### Step 6: Configure Firewall
```bash
# Check firewall status
sudo firewall-cmd --state

# Open necessary ports
sudo firewall-cmd --permanent --add-port=22/tcp    # SSH
sudo firewall-cmd --permanent --add-port=80/tcp    # HTTP
sudo firewall-cmd --permanent --add-port=443/tcp   # HTTPS
sudo firewall-cmd --permanent --add-port=3000/tcp  # Node.js apps
sudo firewall-cmd --permanent --add-port=8080/tcp  # Alternative web port

# Reload firewall
sudo firewall-cmd --reload

# List open ports
sudo firewall-cmd --list-ports
```

### Step 7: Create API Server for Dashboard Communication
```bash
# Create project directory
mkdir -p ~/server-api
cd ~/server-api

# Initialize Node.js project
npm init -y

# Install dependencies
npm install express cors helmet morgan dotenv
```

### Step 8: Create Server API (server.js)
```javascript
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// System status endpoint
app.get('/api/status', (req, res) => {
  exec('top -bn1 | grep "Cpu(s)" && free -m && df -h', (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ error: error.message });
    }
    res.json({ 
      status: 'success',
      data: stdout,
      timestamp: new Date().toISOString()
    });
  });
});

// Docker containers endpoint
app.get('/api/docker/containers', (req, res) => {
  exec('docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"', (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ error: error.message });
    }
    res.json({ 
      status: 'success',
      containers: stdout,
      timestamp: new Date().toISOString()
    });
  });
});

// System services endpoint
app.get('/api/services', (req, res) => {
  exec('systemctl list-units --type=service --state=running', (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ error: error.message });
    }
    res.json({ 
      status: 'success',
      services: stdout,
      timestamp: new Date().toISOString()
    });
  });
});

// Restart service endpoint
app.post('/api/service/restart', (req, res) => {
  const { serviceName } = req.body;
  if (!serviceName) {
    return res.status(400).json({ error: 'Service name required' });
  }
  
  exec(`sudo systemctl restart ${serviceName}`, (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ error: error.message });
    }
    res.json({ 
      status: 'success',
      message: `Service ${serviceName} restarted`,
      timestamp: new Date().toISOString()
    });
  });
});

// System logs endpoint
app.get('/api/logs/:service?', (req, res) => {
  const service = req.params.service || 'system';
  const lines = req.query.lines || '50';
  
  const command = service === 'system' 
    ? `journalctl -n ${lines}` 
    : `journalctl -u ${service} -n ${lines}`;
    
  exec(command, (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ error: error.message });
    }
    res.json({ 
      status: 'success',
      logs: stdout,
      timestamp: new Date().toISOString()
    });
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server API running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});
```

### Step 9: Create Systemd Service
```bash
# Create systemd service file
sudo tee /etc/systemd/system/server-api.service > /dev/null <<EOF
[Unit]
Description=Server API for Dashboard
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/server-api
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=3000

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
sudo systemctl daemon-reload
sudo systemctl enable server-api
sudo systemctl start server-api

# Check service status
sudo systemctl status server-api
```

### Step 10: Install and Configure Nginx (Optional - for HTTPS)
```bash
# Install Nginx
sudo yum install -y nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Basic Nginx configuration for API proxy
sudo tee /etc/nginx/conf.d/api.conf > /dev/null <<EOF
server {
    listen 80;
    server_name your-server-ip-or-domain;

    location /api/ {
        proxy_pass http://localhost:3000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    location /health {
        proxy_pass http://localhost:3000/health;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
    }
}
EOF

# Test Nginx configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### Step 11: Set Up SSL with Let's Encrypt (Optional)
```bash
# Install Certbot
sudo yum install -y certbot python3-certbot-nginx

# Get SSL certificate (replace with your domain)
sudo certbot --nginx -d your-domain.com

# Auto-renewal
sudo crontab -e
# Add this line:
# 0 12 * * * /usr/bin/certbot renew --quiet
```

### Step 12: Configure Monitoring Tools
```bash
# Install htop for better process monitoring
sudo yum install -y htop

# Install iotop for disk I/O monitoring
sudo yum install -y iotop

# Install nethogs for network monitoring
sudo yum install -y nethogs
```

## 🔧 Testing Your Setup

### Test API Endpoints
```bash
# Test health check
curl http://localhost:3000/health

# Test system status
curl http://localhost:3000/api/status

# Test Docker containers
curl http://localhost:3000/api/docker/containers

# Test services
curl http://localhost:3000/api/services
```

### Test from Your Dashboard
1. Enter your server IP in the dashboard: `http://YOUR_SERVER_IP:3000`
2. Click "Connect"
3. Try the management buttons

## 🚨 Security Considerations

### Basic Security Setup
```bash
# Update SSH configuration
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Install fail2ban
sudo yum install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## 📝 Next Steps

1. **Replace `YOUR_SERVER_IP` with your actual Hetzner server IP**
2. **Test all API endpoints**
3. **Configure your domain name (optional)**
4. **Set up SSL certificates for HTTPS**
5. **Configure monitoring and alerting**

Your CentOS server is now ready to work with your Vercel dashboard! 🎉
