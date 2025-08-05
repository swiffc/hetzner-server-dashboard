#!/bin/bash

# 🚀 Hetzner DevOps Server Setup Script
# This script automates the complete setup of your Hetzner server for DevOps workflows
# Server IP: 5.78.70.68
# Run this script as root after initial connection

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEVOPS_USER="devopsuser"
DEVOPS_PASSWORD="DevOps2025!"  # Change this!
SERVER_IP="5.78.70.68"

# Logging function
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
        exit 1
    fi
}

# Update system
update_system() {
    log "🔄 Updating system packages..."
    apt update && apt upgrade -y
    apt autoremove -y
}

# Create DevOps user
create_devops_user() {
    log "👤 Creating DevOps user: $DEVOPS_USER"
    
    # Create user if doesn't exist
    if ! id "$DEVOPS_USER" &>/dev/null; then
        adduser $DEVOPS_USER --gecos "" --disabled-password
        echo "$DEVOPS_USER:$DEVOPS_PASSWORD" | chpasswd
        usermod -aG sudo $DEVOPS_USER
        
        # Copy SSH keys to new user
        if [ -d ~/.ssh ]; then
            rsync --archive --chown=$DEVOPS_USER:$DEVOPS_USER ~/.ssh /home/$DEVOPS_USER/
        fi
        
        log "✅ User $DEVOPS_USER created successfully"
    else
        warning "User $DEVOPS_USER already exists"
    fi
}

# Secure SSH
secure_ssh() {
    log "🔒 Securing SSH configuration..."
    
    # Backup original config
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    
    # Update SSH config
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    
    # Restart SSH service
    systemctl restart ssh
    log "✅ SSH secured successfully"
}

# Setup firewall
setup_firewall() {
    log "🛡️ Setting up UFW firewall..."
    
    # Install UFW if not present
    apt install ufw -y
    
    # Reset UFW rules
    ufw --force reset
    
    # Default policies
    ufw default deny incoming
    ufw default allow outgoing
    
    # Allow essential services
    ufw allow OpenSSH
    ufw allow 22/tcp      # SSH
    ufw allow 80/tcp      # HTTP
    ufw allow 443/tcp     # HTTPS
    ufw allow 3000/tcp    # Application port
    ufw allow 9090/tcp    # Prometheus
    ufw allow 3000/tcp    # Grafana (will conflict with app, handle separately)
    
    # Enable firewall
    ufw --force enable
    
    log "✅ Firewall configured successfully"
}

# Install essential tools
install_essential_tools() {
    log "🔧 Installing essential development tools..."
    
    apt install -y \
        curl \
        wget \
        git \
        unzip \
        software-properties-common \
        python3-pip \
        vim \
        nano \
        htop \
        tree \
        jq \
        build-essential \
        ca-certificates \
        gnupg \
        lsb-release
    
    log "✅ Essential tools installed"
}

# Install Node.js
install_nodejs() {
    log "📦 Installing Node.js..."
    
    # Add NodeSource repository
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
    
    # Install global packages
    npm install -g nodemon pm2 yarn
    
    # Verify installation
    node_version=$(node --version)
    npm_version=$(npm --version)
    
    log "✅ Node.js $node_version and npm $npm_version installed"
}

# Install Docker
install_docker() {
    log "🐳 Installing Docker..."
    
    # Add Docker's official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    
    # Add repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Add user to docker group
    usermod -aG docker $DEVOPS_USER
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    log "✅ Docker installed successfully"
}

# Install monitoring tools
install_monitoring() {
    log "📊 Installing monitoring tools (Prometheus & Grafana)..."
    
    # Install Prometheus
    apt install -y prometheus
    systemctl start prometheus
    systemctl enable prometheus
    
    # Install Grafana
    apt install -y software-properties-common
    wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
    add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
    apt update
    apt install -y grafana
    
    # Start and enable Grafana
    systemctl start grafana-server
    systemctl enable grafana-server
    
    log "✅ Monitoring tools installed"
}

# Create project structure
create_project_structure() {
    log "📁 Creating project structure..."
    
    # Create directories as devops user
    sudo -u $DEVOPS_USER mkdir -p /home/$DEVOPS_USER/{projects,scripts,tools,workspace}
    sudo -u $DEVOPS_USER mkdir -p /home/$DEVOPS_USER/projects/{web,mobile,api,microservices}
    
    # Create useful scripts
    cat > /home/$DEVOPS_USER/scripts/server-status.sh << 'EOF'
#!/bin/bash
echo "=== Hetzner DevOps Server Status ==="
echo "Server IP: 5.78.70.68"
echo "Date: $(date)"
echo ""
echo "=== System Resources ==="
echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
echo "Memory: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
echo "Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
echo ""
echo "=== Services Status ==="
systemctl is-active --quiet docker && echo "✅ Docker: Running" || echo "❌ Docker: Stopped"
systemctl is-active --quiet prometheus && echo "✅ Prometheus: Running" || echo "❌ Prometheus: Stopped"
systemctl is-active --quiet grafana-server && echo "✅ Grafana: Running" || echo "❌ Grafana: Stopped"
echo ""
echo "=== Docker Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "=== Access URLs ==="
echo "Prometheus: http://5.78.70.68:9090"
echo "Grafana: http://5.78.70.68:3000 (admin/admin)"
echo "Application: http://5.78.70.68:3000"
EOF

    chmod +x /home/$DEVOPS_USER/scripts/server-status.sh
    chown -R $DEVOPS_USER:$DEVOPS_USER /home/$DEVOPS_USER/
    
    log "✅ Project structure created"
}

# Setup sample application
setup_sample_app() {
    log "🚀 Setting up sample application..."
    
    APP_DIR="/home/$DEVOPS_USER/projects/sample-app"
    
    # Create app directory
    sudo -u $DEVOPS_USER mkdir -p $APP_DIR
    
    # Create package.json
    cat > $APP_DIR/package.json << 'EOF'
{
  "name": "hetzner-devops-app",
  "version": "1.0.0",
  "description": "Sample DevOps application for Hetzner server",
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
EOF

    # Create app.js
    cat > $APP_DIR/app.js << 'EOF'
const express = require('express');
const app = express();
const port = 3000;

// Middleware
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Hetzner DevOps Server! 🚀',
    timestamp: new Date().toISOString(),
    server: 'Hetzner CPX41',
    ip: '5.78.70.68',
    env: process.env.NODE_ENV || 'development',
    uptime: process.uptime(),
    memory: process.memoryUsage()
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

app.get('/api/info', (req, res) => {
  res.json({
    name: 'Hetzner DevOps API',
    version: '1.0.0',
    endpoints: [
      'GET /',
      'GET /health',
      'GET /api/info'
    ]
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Server running at http://0.0.0.0:${port}`);
  console.log(`🌐 External access: http://5.78.70.68:${port}`);
});
EOF

    # Create Dockerfile
    cat > $APP_DIR/Dockerfile << 'EOF'
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
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Run app
CMD ["npm", "start"]
EOF

    # Create docker-compose.yml
    cat > $APP_DIR/docker-compose.yml << 'EOF'
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
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
EOF

    # Set ownership
    chown -R $DEVOPS_USER:$DEVOPS_USER $APP_DIR
    
    log "✅ Sample application created at $APP_DIR"
}

# Setup environment
setup_environment() {
    log "🌍 Setting up development environment..."
    
    # Add useful aliases to bashrc
    cat >> /home/$DEVOPS_USER/.bashrc << 'EOF'

# DevOps aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Docker aliases
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'

# System aliases
alias ll='ls -alF'
alias status='~/scripts/server-status.sh'
alias logs='journalctl -f'

# Development shortcuts
alias proj='cd ~/projects'
alias scripts='cd ~/scripts'

echo "🚀 Hetzner DevOps Environment Ready!"
echo "Server IP: 5.78.70.68"
echo "Run 'status' to check server status"
EOF

    chown $DEVOPS_USER:$DEVOPS_USER /home/$DEVOPS_USER/.bashrc
    
    log "✅ Development environment configured"
}

# Final setup and verification
final_setup() {
    log "🔍 Performing final setup and verification..."
    
    # Test Docker installation
    if sudo -u $DEVOPS_USER docker run hello-world > /dev/null 2>&1; then
        log "✅ Docker test successful"
    else
        warning "Docker test failed - may need reboot"
    fi
    
    # Check services
    systemctl is-active --quiet docker && log "✅ Docker service running"
    systemctl is-active --quiet prometheus && log "✅ Prometheus service running"
    systemctl is-active --quiet grafana-server && log "✅ Grafana service running"
    
    # Display access information
    info "📋 Server Setup Complete!"
    echo ""
    echo "🌐 Access Information:"
    echo "  Server IP: $SERVER_IP"
    echo "  SSH User: $DEVOPS_USER"
    echo "  SSH Password: $DEVOPS_PASSWORD (change this!)"
    echo ""
    echo "🔗 Web Services:"
    echo "  Prometheus: http://$SERVER_IP:9090"
    echo "  Grafana: http://$SERVER_IP:3000 (admin/admin)"
    echo ""
    echo "📁 Project Structure:"
    echo "  Projects: /home/$DEVOPS_USER/projects/"
    echo "  Scripts: /home/$DEVOPS_USER/scripts/"
    echo "  Sample App: /home/$DEVOPS_USER/projects/sample-app/"
    echo ""
    echo "🚀 Next Steps:"
    echo "  1. Login as $DEVOPS_USER"
    echo "  2. Change the default password"
    echo "  3. Deploy your sample app: cd ~/projects/sample-app && npm install && npm start"
    echo "  4. Set up Cursor Remote-SSH connection"
    echo ""
    warning "IMPORTANT: Change the default password for $DEVOPS_USER!"
    warning "Update SSH config to use $DEVOPS_USER instead of root"
}

# Main execution
main() {
    log "🚀 Starting Hetzner DevOps Server Setup..."
    log "Server IP: $SERVER_IP"
    
    check_root
    update_system
    create_devops_user
    install_essential_tools
    install_nodejs
    install_docker
    install_monitoring
    setup_firewall
    secure_ssh
    create_project_structure
    setup_sample_app
    setup_environment
    final_setup
    
    log "🎉 Hetzner DevOps Server setup completed successfully!"
    echo ""
    warning "⚠️  REBOOT REQUIRED for all changes to take effect"
    echo "Run: sudo reboot"
}

# Execute main function
main "$@"