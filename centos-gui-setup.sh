#!/bin/bash

# CentOS GUI Remote Desktop Setup Script
# This will allow you to access your CentOS desktop through a web browser

echo "🖥️  Setting up CentOS GUI Remote Desktop Access..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Step 1: Install Desktop Environment
print_status "Installing GNOME Desktop Environment..."
sudo yum groupinstall -y "GNOME Desktop" "Graphical Administration Tools"

# Step 2: Set graphical target as default
print_status "Setting graphical interface as default..."
sudo systemctl set-default graphical.target

# Step 3: Install VNC Server
print_status "Installing TigerVNC Server..."
sudo yum install -y tigervnc-server tigervnc-server-module

# Step 4: Install noVNC (Web-based VNC client)
print_status "Installing noVNC for web browser access..."
cd /opt
sudo git clone https://github.com/novnc/noVNC.git
sudo git clone https://github.com/novnc/websockify.git noVNC/utils/websockify

# Step 5: Create VNC user configuration
print_status "Configuring VNC for current user..."
mkdir -p ~/.vnc

# Create VNC password (you'll need to set this)
echo "Please set a VNC password when prompted:"
vncpasswd

# Create VNC startup script
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec /etc/X11/xinit/xinitrc
EOF

chmod +x ~/.vnc/xstartup

# Step 6: Create systemd service for VNC
print_status "Creating VNC systemd service..."
sudo tee /etc/systemd/system/vncserver@.service > /dev/null << EOF
[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=forking
User=$USER
ExecStartPre=/bin/sh -c '/usr/bin/vncserver -kill %i > /dev/null 2>&1 || :'
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x1024 %i
ExecStop=/usr/bin/vncserver -kill %i
PIDFile=/home/$USER/.vnc/%H%i.pid
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Step 7: Enable and start VNC service
print_status "Starting VNC server on display :1..."
sudo systemctl daemon-reload
sudo systemctl enable vncserver@:1.service
sudo systemctl start vncserver@:1.service

# Step 8: Create noVNC startup script
print_status "Creating noVNC web server script..."
cat > ~/start-novnc.sh << 'EOF'
#!/bin/bash
# Start noVNC web server
cd /opt/noVNC
./utils/launch.sh --vnc localhost:5901 --listen 6080
EOF

chmod +x ~/start-novnc.sh

# Step 9: Create systemd service for noVNC
sudo tee /etc/systemd/system/novnc.service > /dev/null << EOF
[Unit]
Description=noVNC Web Server
After=vncserver@:1.service
Requires=vncserver@:1.service

[Service]
Type=simple
User=$USER
ExecStart=/home/$USER/start-novnc.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Step 10: Enable and start noVNC service
sudo systemctl daemon-reload
sudo systemctl enable novnc.service
sudo systemctl start novnc.service

# Step 11: Configure firewall
print_status "Configuring firewall for VNC and noVNC..."
sudo firewall-cmd --permanent --add-port=5901/tcp  # VNC
sudo firewall-cmd --permanent --add-port=6080/tcp  # noVNC web interface
sudo firewall-cmd --reload

# Step 12: Install additional useful applications
print_status "Installing additional desktop applications..."
sudo yum install -y firefox chromium gedit file-roller

print_status "✅ CentOS GUI Remote Desktop Setup Complete!"
echo ""
echo "🌐 Access your CentOS desktop through web browser:"
echo "   http://YOUR_SERVER_IP:6080/vnc.html"
echo ""
echo "🔧 VNC Direct Access (if needed):"
echo "   VNC Server: YOUR_SERVER_IP:5901"
echo ""
echo "📋 Next Steps:"
echo "1. Reboot your server: sudo reboot"
echo "2. Wait 2-3 minutes for services to start"
echo "3. Open browser and go to: http://YOUR_SERVER_IP:6080/vnc.html"
echo "4. Enter your VNC password when prompted"
echo "5. You'll see the full CentOS desktop!"
echo ""
print_warning "Replace YOUR_SERVER_IP with your actual Hetzner server IP address"
