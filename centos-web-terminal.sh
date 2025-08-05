#!/bin/bash

# CentOS Web Terminal Setup
# This creates a web-based terminal you can access through your browser

echo "💻 Setting up Web Terminal for CentOS..."

# Install Node.js if not already installed
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
    sudo yum install -y nodejs
fi

# Create web terminal directory
mkdir -p ~/web-terminal
cd ~/web-terminal

# Initialize npm project
npm init -y

# Install required packages
npm install express socket.io node-pty cors

# Create web terminal server
cat > server.js << 'EOF'
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const pty = require('node-pty');
const cors = require('cors');
const path = require('path');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

app.use(cors());
app.use(express.static(path.join(__dirname, 'public')));

// Store terminal sessions
const terminals = {};

io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  // Create new terminal session
  const term = pty.spawn('bash', [], {
    name: 'xterm-color',
    cols: 80,
    rows: 30,
    cwd: process.env.HOME,
    env: process.env
  });

  terminals[socket.id] = term;

  // Send terminal output to client
  term.on('data', (data) => {
    socket.emit('output', data);
  });

  // Handle input from client
  socket.on('input', (data) => {
    term.write(data);
  });

  // Handle resize
  socket.on('resize', (size) => {
    term.resize(size.cols, size.rows);
  });

  // Clean up on disconnect
  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
    if (terminals[socket.id]) {
      terminals[socket.id].kill();
      delete terminals[socket.id];
    }
  });
});

const PORT = process.env.PORT || 7681;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Web Terminal Server running on port ${PORT}`);
  console.log(`Access at: http://localhost:${PORT}`);
});
EOF

# Create public directory for web interface
mkdir -p public

# Create HTML interface
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CentOS Web Terminal</title>
    <script src="/socket.io/socket.io.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/xterm@4.19.0/lib/xterm.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/xterm-addon-fit@0.5.0/lib/xterm-addon-fit.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/xterm@4.19.0/css/xterm.css" />
    <style>
        body {
            margin: 0;
            padding: 20px;
            background: #1e1e1e;
            font-family: 'Courier New', monospace;
            color: #ffffff;
        }
        .header {
            text-align: center;
            margin-bottom: 20px;
        }
        .terminal-container {
            border: 2px solid #333;
            border-radius: 8px;
            padding: 10px;
            background: #000;
            max-width: 100%;
            overflow: hidden;
        }
        .status {
            text-align: center;
            margin-bottom: 10px;
            color: #00ff00;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🖥️ CentOS Web Terminal</h1>
        <div class="status" id="status">Connecting...</div>
    </div>
    
    <div class="terminal-container">
        <div id="terminal"></div>
    </div>

    <script>
        // Initialize terminal
        const term = new Terminal({
            cursorBlink: true,
            theme: {
                background: '#000000',
                foreground: '#ffffff',
                cursor: '#ffffff',
                selection: '#ffffff'
            }
        });

        const fitAddon = new FitAddon.FitAddon();
        term.loadAddon(fitAddon);
        
        term.open(document.getElementById('terminal'));
        fitAddon.fit();

        // Connect to server
        const socket = io();
        const statusEl = document.getElementById('status');

        socket.on('connect', () => {
            statusEl.textContent = 'Connected to CentOS Server';
            statusEl.style.color = '#00ff00';
        });

        socket.on('disconnect', () => {
            statusEl.textContent = 'Disconnected from Server';
            statusEl.style.color = '#ff0000';
        });

        // Handle terminal output
        socket.on('output', (data) => {
            term.write(data);
        });

        // Handle terminal input
        term.onData((data) => {
            socket.emit('input', data);
        });

        // Handle resize
        window.addEventListener('resize', () => {
            fitAddon.fit();
            socket.emit('resize', {
                cols: term.cols,
                rows: term.rows
            });
        });

        // Initial resize
        setTimeout(() => {
            fitAddon.fit();
            socket.emit('resize', {
                cols: term.cols,
                rows: term.rows
            });
        }, 100);
    </script>
</body>
</html>
EOF

# Create systemd service for web terminal
sudo tee /etc/systemd/system/web-terminal.service > /dev/null << EOF
[Unit]
Description=Web Terminal Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/home/$USER/web-terminal
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable web-terminal.service
sudo systemctl start web-terminal.service

# Configure firewall
sudo firewall-cmd --permanent --add-port=7681/tcp
sudo firewall-cmd --reload

echo "✅ Web Terminal Setup Complete!"
echo ""
echo "🌐 Access your CentOS terminal through web browser:"
echo "   http://YOUR_SERVER_IP:7681"
echo ""
echo "🔧 Service Management:"
echo "   Start:   sudo systemctl start web-terminal"
echo "   Stop:    sudo systemctl stop web-terminal"
echo "   Status:  sudo systemctl status web-terminal"
echo ""
echo "Replace YOUR_SERVER_IP with your actual Hetzner server IP address"
