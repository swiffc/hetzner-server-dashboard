#!/bin/bash

# 🚀 Hetzner Quick Deploy Script
# This script quickly deploys applications to your Hetzner DevOps server
# Server IP: 5.78.70.68

set -e

# Configuration
SERVER_IP="5.78.70.68"
SERVER_USER="devopsuser"
SSH_KEY="~/.ssh/id_ed25519"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date '+%H:%M:%S')] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARN] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; }

# Check if we can connect to server
check_connection() {
    log "🔍 Checking connection to Hetzner server..."
    if ssh -i $SSH_KEY -o ConnectTimeout=10 -o BatchMode=yes $SERVER_USER@$SERVER_IP "echo 'Connection successful'" 2>/dev/null; then
        log "✅ Connection to $SERVER_IP successful"
    else
        error "❌ Cannot connect to $SERVER_IP"
        echo "Make sure:"
        echo "1. Server is running"
        echo "2. SSH key is configured: $SSH_KEY"
        echo "3. User exists: $SERVER_USER"
        exit 1
    fi
}

# Deploy sample application
deploy_sample_app() {
    log "🚀 Deploying sample application..."
    
    ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP << 'EOF'
cd ~/projects/sample-app

# Install dependencies if package.json exists
if [ -f package.json ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Stop existing application
echo "🛑 Stopping existing application..."
pm2 stop hetzner-app 2>/dev/null || true

# Start application with PM2
echo "🚀 Starting application..."
pm2 start app.js --name hetzner-app --watch

# Save PM2 configuration
pm2 save
pm2 startup

echo "✅ Application deployed successfully!"
echo "🌐 Access at: http://5.78.70.68:3000"
EOF

    log "✅ Sample application deployed"
}

# Deploy with Docker
deploy_docker_app() {
    log "🐳 Deploying application with Docker..."
    
    ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP << 'EOF'
cd ~/projects/sample-app

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker compose down 2>/dev/null || true

# Build and start with Docker Compose
echo "🔨 Building and starting containers..."
docker compose up -d --build

# Show status
echo "📊 Container status:"
docker compose ps

echo "✅ Docker deployment completed!"
echo "🌐 Access at: http://5.78.70.68:3000"
EOF

    log "✅ Docker application deployed"
}

# Check server status
check_status() {
    log "📊 Checking server status..."
    
    ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP << 'EOF'
echo "=== Hetzner DevOps Server Status ==="
echo "Date: $(date)"
echo "Server: 5.78.70.68"
echo ""

echo "=== System Resources ==="
echo "Uptime: $(uptime -p)"
echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
echo "Memory: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2 " (" $5 " used)"}')"
echo "Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
echo ""

echo "=== Services ==="
systemctl is-active --quiet docker && echo "✅ Docker: Running" || echo "❌ Docker: Stopped"
systemctl is-active --quiet prometheus && echo "✅ Prometheus: Running" || echo "❌ Prometheus: Stopped"
systemctl is-active --quiet grafana-server && echo "✅ Grafana: Running" || echo "❌ Grafana: Stopped"
echo ""

echo "=== Running Containers ==="
if command -v docker &> /dev/null; then
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No containers running"
else
    echo "Docker not installed"
fi
echo ""

echo "=== PM2 Processes ==="
if command -v pm2 &> /dev/null; then
    pm2 list 2>/dev/null || echo "No PM2 processes"
else
    echo "PM2 not installed"
fi
echo ""

echo "=== Network Ports ==="
echo "Active connections:"
ss -tlnp | grep -E ':(22|80|443|3000|9090)' | head -10
echo ""

echo "=== Access URLs ==="
echo "Application: http://5.78.70.68:3000"
echo "Prometheus: http://5.78.70.68:9090"
echo "Grafana: http://5.78.70.68:3000"
EOF
}

# Update server packages
update_server() {
    log "🔄 Updating server packages..."
    
    ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP << 'EOF'
echo "📦 Updating package lists..."
sudo apt update

echo "⬆️ Upgrading packages..."
sudo apt upgrade -y

echo "🧹 Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean

echo "✅ Server updated successfully!"
EOF

    log "✅ Server packages updated"
}

# Backup application data
backup_data() {
    log "💾 Creating backup..."
    
    BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p $BACKUP_DIR
    
    # Backup application files
    scp -i $SSH_KEY -r $SERVER_USER@$SERVER_IP:~/projects $BACKUP_DIR/
    scp -i $SSH_KEY -r $SERVER_USER@$SERVER_IP:~/scripts $BACKUP_DIR/
    
    # Create backup info
    cat > $BACKUP_DIR/backup_info.txt << EOF
Backup created: $(date)
Server: $SERVER_IP
User: $SERVER_USER
Contents: ~/projects, ~/scripts
EOF

    log "✅ Backup created in $BACKUP_DIR"
}

# Show logs
show_logs() {
    log "📋 Showing server logs..."
    
    ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP << 'EOF'
echo "=== Recent System Logs ==="
sudo journalctl --since "1 hour ago" --lines=20

echo ""
echo "=== Docker Logs ==="
if docker ps -q | head -1 | xargs docker logs --tail=10 2>/dev/null; then
    echo "Docker logs shown above"
else
    echo "No Docker containers running"
fi

echo ""
echo "=== PM2 Logs ==="
if command -v pm2 &> /dev/null; then
    pm2 logs --lines 10 2>/dev/null || echo "No PM2 processes"
else
    echo "PM2 not installed"
fi
EOF
}

# Install additional tools
install_tools() {
    log "🔧 Installing additional development tools..."
    
    ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP << 'EOF'
echo "📦 Installing additional tools..."

# Development tools
sudo apt update
sudo apt install -y \
    vim \
    nano \
    htop \
    tree \
    jq \
    curl \
    wget \
    unzip \
    zip \
    git \
    build-essential

# Python tools
sudo apt install -y python3-pip python3-venv

# Install useful npm packages globally
npm install -g \
    nodemon \
    pm2 \
    yarn \
    typescript \
    @angular/cli \
    create-react-app \
    express-generator

echo "✅ Additional tools installed!"
EOF

    log "✅ Additional tools installed"
}

# Show usage
show_usage() {
    echo "🚀 Hetzner Quick Deploy Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  deploy-sample    Deploy sample Node.js application"
    echo "  deploy-docker    Deploy application with Docker"
    echo "  status          Check server status"
    echo "  update          Update server packages"
    echo "  backup          Backup application data"
    echo "  logs            Show server logs"
    echo "  install-tools   Install additional development tools"
    echo "  check           Check connection to server"
    echo ""
    echo "Examples:"
    echo "  $0 status"
    echo "  $0 deploy-sample"
    echo "  $0 deploy-docker"
}

# Main execution
main() {
    case "${1:-}" in
        "deploy-sample")
            check_connection
            deploy_sample_app
            ;;
        "deploy-docker")
            check_connection
            deploy_docker_app
            ;;
        "status")
            check_connection
            check_status
            ;;
        "update")
            check_connection
            update_server
            ;;
        "backup")
            check_connection
            backup_data
            ;;
        "logs")
            check_connection
            show_logs
            ;;
        "install-tools")
            check_connection
            install_tools
            ;;
        "check")
            check_connection
            ;;
        *)
            show_usage
            ;;
    esac
}

main "$@"