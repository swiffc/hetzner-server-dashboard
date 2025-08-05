import { useState } from 'react';
import Head from 'next/head';

export default function CentOSAccess() {
  const [serverIp, setServerIp] = useState('5.78.70.68');

  const openCentOSDesktop = () => {
    if (serverIp) {
      const desktopUrl = `http://${serverIp}:6080/vnc.html`;
      window.open(desktopUrl, '_blank', 'width=1280,height=1024');
    }
  };

  const openCentOSTerminal = () => {
    if (serverIp) {
      const terminalUrl = `http://${serverIp}:7681`;
      window.open(terminalUrl, '_blank', 'width=1200,height=800');
    }
  };

  const copySetupCommands = () => {
    const commands = `# CentOS GUI Setup Commands
wget https://raw.githubusercontent.com/swiffc/hetzner-server-dashboard/main/centos-gui-setup.sh
chmod +x centos-gui-setup.sh
./centos-gui-setup.sh

# CentOS Web Terminal Setup
wget https://raw.githubusercontent.com/swiffc/hetzner-server-dashboard/main/centos-web-terminal.sh
chmod +x centos-web-terminal.sh
./centos-web-terminal.sh

# Reboot server
sudo reboot`;
    
    navigator.clipboard.writeText(commands).then(() => {
      alert('Setup commands copied to clipboard!');
    });
  };

  return (
    <div className="container">
      <Head>
        <title>CentOS Direct Access - Hetzner Server</title>
        <meta name="description" content="Direct access to your CentOS desktop and terminal" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className="main">
        <h1 className="title">
          🖥️ CentOS Direct Access
        </h1>

        <p className="description">
          Access your CentOS desktop and terminal directly through your browser
        </p>

        <div className="access-card">
          <h2>Enter Your CentOS Server IP</h2>
          <div className="input-group">
            <input
              type="text"
              placeholder="e.g., 192.168.1.100 or your-server.com"
              value={serverIp}
              onChange={(e) => setServerIp(e.target.value)}
              className="server-input"
            />
          </div>

          <div className="access-section">
            <h2>🌐 CentOS Cockpit Access</h2>
            <p>Access your full CentOS system management interface through Cockpit:</p>
            
            <div className="access-option">
              <h3>Cockpit Web Interface</h3>
              <p>Full system management with terminal, file manager, monitoring, and more:</p>
              <button 
                className="access-btn cockpit-btn"
                onClick={() => window.open(`/api/proxy?target=http://${serverIp}:9090`, '_blank')}
              >
                🌐 Open Cockpit Interface
              </button>
              <p className="access-url">Via Vercel Proxy: /api/proxy?target=http://{serverIp}:9090</p>
              <p className="direct-url">Direct URL: http://{serverIp}:9090</p>
            </div>
          </div>

          <div className="access-section">
            <h2>🔐 Login Information</h2>
            <p>Use your CentOS system credentials to log into Cockpit:</p>
            <div className="login-info">
              <p><strong>Username:</strong> root</p>
              <p><strong>Password:</strong> Your root password</p>
              <p><strong>Features:</strong> Terminal, File Manager, System Monitoring, Service Management</p>
            </div>
          </div>

          <div className="access-buttons">
            <button 
              onClick={openCentOSTerminal} 
              className="access-btn terminal"
              disabled={!serverIp}
            >
              💻 Open CentOS Terminal
              <span className="port-info">Port: 7681</span>
            </button>
          </div>
        </div>

        <div className="setup-card">
          <h2>🚀 First Time Setup Required</h2>
          <p>Run these commands on your CentOS server to enable GUI and terminal access:</p>
          
          <div className="setup-steps">
            <div className="step">
              <h3>Step 1: Install GUI Desktop</h3>
              <div className="code-block">
                <code>
                  wget https://raw.githubusercontent.com/swiffc/hetzner-server-dashboard/main/centos-gui-setup.sh<br/>
                  chmod +x centos-gui-setup.sh<br/>
                  ./centos-gui-setup.sh
                </code>
              </div>
            </div>
            
            <div className="step">
              <h3>Step 2: Install Web Terminal</h3>
              <div className="code-block">
                <code>
                  wget https://raw.githubusercontent.com/swiffc/hetzner-server-dashboard/main/centos-web-terminal.sh<br/>
                  chmod +x centos-web-terminal.sh<br/>
                  ./centos-web-terminal.sh
                </code>
              </div>
            </div>
            
            <div className="step">
              <h3>Step 3: Reboot Server</h3>
              <div className="code-block">
                <code>sudo reboot</code>
              </div>
            </div>
          </div>
          
          <button onClick={copySetupCommands} className="copy-btn">
            📋 Copy All Commands
          </button>
        </div>

        <div className="info-card">
          <h2>ℹ️ What You'll Get</h2>
          <div className="features">
            <div className="feature">
              <strong>🖥️ Full CentOS Desktop:</strong> Complete GNOME desktop environment with file manager, applications, and GUI tools
            </div>
            <div className="feature">
              <strong>💻 Web Terminal:</strong> Full-featured terminal with command history, colors, and all Linux commands
            </div>
            <div className="feature">
              <strong>🌐 Browser Access:</strong> No VPN or special software needed - works directly in your browser
            </div>
            <div className="feature">
              <strong>🔒 Secure Connection:</strong> Direct connection to your server bypassing company restrictions
            </div>
          </div>
        </div>
      </main>

      <style jsx>{`
        .container {
          min-height: 100vh;
          padding: 0 0.5rem;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .main {
          padding: 2rem 0;
          flex: 1;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          max-width: 1000px;
          width: 100%;
        }

        .title {
          margin: 0 0 1rem 0;
          line-height: 1.15;
          font-size: 3rem;
          text-align: center;
          color: white;
          text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }

        .description {
          text-align: center;
          line-height: 1.5;
          font-size: 1.2rem;
          color: rgba(255,255,255,0.8);
          margin-bottom: 2rem;
        }

        .access-card, .setup-card, .info-card {
          padding: 2rem;
          margin: 1rem 0;
          background: rgba(255,255,255,0.1);
          backdrop-filter: blur(10px);
          border-radius: 15px;
          border: 1px solid rgba(255,255,255,0.2);
          width: 100%;
          max-width: 800px;
        }

        .access-card h2, .setup-card h2, .info-card h2 {
          color: white;
          margin-bottom: 1rem;
          text-align: center;
        }

        .input-group {
          margin-bottom: 2rem;
        }

        .server-input {
          width: 100%;
          padding: 1rem;
          border: 1px solid rgba(255,255,255,0.3);
          border-radius: 8px;
          background: rgba(255,255,255,0.1);
          color: white;
          font-size: 1.1rem;
          text-align: center;
        }

        .server-input::placeholder {
          color: rgba(255,255,255,0.6);
        }

        .access-buttons {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 1rem;
        }

        .access-btn {
          padding: 1.5rem;
          border: none;
          border-radius: 10px;
          font-size: 1.1rem;
          font-weight: bold;
          cursor: pointer;
          transition: all 0.3s ease;
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 0.5rem;
        }

        .access-btn.desktop {
          background: linear-gradient(135deg, #4CAF50, #45a049);
          color: white;
        }

        .access-btn.terminal {
          background: linear-gradient(135deg, #2196F3, #1976D2);
          color: white;
        }

        .access-btn:hover:not(:disabled) {
          transform: translateY(-3px);
          box-shadow: 0 10px 25px rgba(0,0,0,0.3);
        }

        .access-btn:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }

        .port-info {
          font-size: 0.9rem;
          opacity: 0.8;
        }

        .setup-steps {
          margin: 1.5rem 0;
        }

        .step {
          margin-bottom: 2rem;
        }

        .step h3 {
          color: white;
          margin-bottom: 0.5rem;
        }

        .code-block {
          background: rgba(0,0,0,0.3);
          border-radius: 8px;
          padding: 1rem;
          margin: 0.5rem 0;
        }

        .code-block code {
          color: #00ff00;
          font-family: 'Courier New', monospace;
          font-size: 0.9rem;
          line-height: 1.4;
        }

        .copy-btn {
          background: linear-gradient(135deg, #FF9800, #F57C00);
          color: white;
          border: none;
          padding: 1rem 2rem;
          border-radius: 8px;
          font-size: 1rem;
          cursor: pointer;
          transition: all 0.3s ease;
          display: block;
          margin: 1rem auto 0;
        }

        .copy-btn:hover {
          transform: translateY(-2px);
          box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }

        .features {
          display: grid;
          gap: 1rem;
        }

        .feature {
          color: white;
          padding: 1rem;
          background: rgba(255,255,255,0.05);
          border-radius: 8px;
          border-left: 4px solid #4CAF50;
        }

        @media (max-width: 768px) {
          .access-buttons {
            grid-template-columns: 1fr;
          }
          
          .title {
            font-size: 2rem;
          }
          
          .access-card, .setup-card, .info-card {
            padding: 1rem;
            margin: 0.5rem;
          }
        }
      `}</style>
    </div>
  );
}
