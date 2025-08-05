# Hetzner Quick Deploy PowerShell Script
# Windows version of deployment automation for Hetzner DevOps server

param(
    [Parameter(Position=0)]
    [ValidateSet("deploy-sample", "deploy-docker", "status", "update", "backup", "logs", "install-tools", "check", "help")]
    [string]$Command = "help"
)

# Configuration
$ServerIP = "5.78.70.68"
$ServerUser = "devopsuser"
$SSHKey = "$env:USERPROFILE\.ssh\id_ed25519"

# Colors for output
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Info { param($Message) Write-Host "ℹ️ $Message" -ForegroundColor Blue }
function Write-Warning { param($Message) Write-Host "⚠️ $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }

function Test-Connection {
    Write-Info "Checking connection to Hetzner server..."
    
    $result = ssh -i $SSHKey -o ConnectTimeout=10 -o BatchMode=yes "$ServerUser@$ServerIP" "echo 'Connection successful'" 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Connection to $ServerIP successful"
        return $true
    } else {
        Write-Error "Cannot connect to $ServerIP"
        Write-Host "Make sure:" -ForegroundColor Yellow
        Write-Host "1. Server is running" -ForegroundColor Yellow
        Write-Host "2. SSH key exists: $SSHKey" -ForegroundColor Yellow
        Write-Host "3. User exists: $ServerUser" -ForegroundColor Yellow
        return $false
    }
}

function Deploy-SampleApp {
    Write-Info "Deploying sample application..."
    
    $script = @'
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
'@

    ssh -i $SSHKey "$ServerUser@$ServerIP" $script
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Sample application deployed"
    } else {
        Write-Error "Deployment failed"
    }
}

function Deploy-DockerApp {
    Write-Info "Deploying application with Docker..."
    
    $script = @'
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
'@

    ssh -i $SSHKey "$ServerUser@$ServerIP" $script
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Docker application deployed"
    } else {
        Write-Error "Docker deployment failed"
    }
}

function Get-ServerStatus {
    Write-Info "Checking server status..."
    
    $script = @'
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

echo "=== Access URLs ==="
echo "Application: http://5.78.70.68:3000"
echo "Prometheus: http://5.78.70.68:9090"
echo "Grafana: http://5.78.70.68:3000"
'@

    ssh -i $SSHKey "$ServerUser@$ServerIP" $script
}

function Update-Server {
    Write-Info "Updating server packages..."
    
    $script = @'
echo "📦 Updating package lists..."
sudo apt update

echo "⬆️ Upgrading packages..."
sudo apt upgrade -y

echo "🧹 Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean

echo "✅ Server updated successfully!"
'@

    ssh -i $SSHKey "$ServerUser@$ServerIP" $script
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Server packages updated"
    } else {
        Write-Error "Update failed"
    }
}

function Backup-Data {
    Write-Info "Creating backup..."
    
    $BackupDir = ".\backups\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
    
    # Backup application files
    scp -i $SSHKey -r "$ServerUser@${ServerIP}:~/projects" "$BackupDir\"
    scp -i $SSHKey -r "$ServerUser@${ServerIP}:~/scripts" "$BackupDir\"
    
    # Create backup info
    $backupInfo = @"
Backup created: $(Get-Date)
Server: $ServerIP
User: $ServerUser
Contents: ~/projects, ~/scripts
"@
    
    $backupInfo | Out-File -FilePath "$BackupDir\backup_info.txt"
    
    Write-Success "Backup created in $BackupDir"
}

function Show-Logs {
    Write-Info "Showing server logs..."
    
    $script = @'
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
'@

    ssh -i $SSHKey "$ServerUser@$ServerIP" $script
}

function Install-Tools {
    Write-Info "Installing additional development tools..."
    
    $script = @'
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
'@

    ssh -i $SSHKey "$ServerUser@$ServerIP" $script
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Additional tools installed"
    } else {
        Write-Error "Installation failed"
    }
}

function Show-Usage {
    Write-Host "🚀 Hetzner Quick Deploy PowerShell Script" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\hetzner-quick-deploy.ps1 [command]" -ForegroundColor White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  deploy-sample    Deploy sample Node.js application" -ForegroundColor White
    Write-Host "  deploy-docker    Deploy application with Docker" -ForegroundColor White
    Write-Host "  status          Check server status" -ForegroundColor White
    Write-Host "  update          Update server packages" -ForegroundColor White
    Write-Host "  backup          Backup application data" -ForegroundColor White
    Write-Host "  logs            Show server logs" -ForegroundColor White
    Write-Host "  install-tools   Install additional development tools" -ForegroundColor White
    Write-Host "  check           Check connection to server" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\hetzner-quick-deploy.ps1 status" -ForegroundColor Cyan
    Write-Host "  .\hetzner-quick-deploy.ps1 deploy-sample" -ForegroundColor Cyan
    Write-Host "  .\hetzner-quick-deploy.ps1 deploy-docker" -ForegroundColor Cyan
}

# Main execution
switch ($Command) {
    "deploy-sample" {
        if (Test-Connection) { Deploy-SampleApp }
    }
    "deploy-docker" {
        if (Test-Connection) { Deploy-DockerApp }
    }
    "status" {
        if (Test-Connection) { Get-ServerStatus }
    }
    "update" {
        if (Test-Connection) { Update-Server }
    }
    "backup" {
        if (Test-Connection) { Backup-Data }
    }
    "logs" {
        if (Test-Connection) { Show-Logs }
    }
    "install-tools" {
        if (Test-Connection) { Install-Tools }
    }
    "check" {
        Test-Connection | Out-Null
    }
    "help" {
        Show-Usage
    }
    default {
        Show-Usage
    }
}