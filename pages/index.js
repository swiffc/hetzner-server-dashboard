import { useState } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';

export default function Home() {
  const router = useRouter();
  const [serverIp, setServerIp] = useState('');

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

  const goToCentOSAccess = () => {
    router.push('/centos-access');
  };

  return (
    <div className="container">
      <Head>
        <title>CentOS Server Access - Hetzner Dashboard</title>
        <meta name="description" content="Direct access to your CentOS server desktop and terminal" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className="main">
        <h1 className="title">
          🖥️ CentOS Server Access
        </h1>

        <p className="description">
          Access your CentOS server desktop and terminal directly through your browser
        </p>

        <div className="access-card">
          <h2>Quick Access</h2>
          <div className="input-group">
            <input
              type="text"
              placeholder="Enter your CentOS server IP (e.g., 192.168.1.100)"
              value={serverIp}
              onChange={(e) => setServerIp(e.target.value)}
              className="server-input"
            />
          </div>

          <div className="button-group">
            <button 
              onClick={openCentOSDesktop} 
              className="access-btn desktop"
              disabled={!serverIp}
            >
              🖥️ Open Desktop
            </button>
            
            <button 
              onClick={openCentOSTerminal} 
              className="access-btn terminal"
              disabled={!serverIp}
            >
              💻 Open Terminal
            </button>
            
            <button 
              onClick={goToCentOSAccess} 
              className="access-btn setup"
            >
              ⚙️ Setup Guide
            </button>
          </div>
        </div>

        <div className="info-card">
          <h2>ℹ️ How It Works</h2>
          <p>This dashboard provides direct browser access to your CentOS server:</p>
          <ul>
            <li><strong>Desktop Access:</strong> Full GNOME desktop environment (Port 6080)</li>
            <li><strong>Terminal Access:</strong> Web-based terminal interface (Port 7681)</li>
            <li><strong>Setup Guide:</strong> Complete installation instructions</li>
          </ul>
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
          max-width: 800px;
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

        .access-card, .info-card {
          padding: 2rem;
          margin: 1rem 0;
          background: rgba(255,255,255,0.1);
          backdrop-filter: blur(10px);
          border-radius: 15px;
          border: 1px solid rgba(255,255,255,0.2);
          width: 100%;
        }

        .access-card h2, .info-card h2 {
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

        .button-group {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
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
          color: white;
        }

        .access-btn.desktop {
          background: linear-gradient(135deg, #4CAF50, #45a049);
        }

        .access-btn.terminal {
          background: linear-gradient(135deg, #2196F3, #1976D2);
        }

        .access-btn.setup {
          background: linear-gradient(135deg, #FF9800, #F57C00);
        }

        .access-btn:hover:not(:disabled) {
          transform: translateY(-3px);
          box-shadow: 0 10px 25px rgba(0,0,0,0.3);
        }

        .access-btn:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }

        .info-card {
          color: white;
        }

        .info-card ul {
          text-align: left;
          margin: 1rem 0;
        }

        .info-card li {
          margin: 0.5rem 0;
        }

        @media (max-width: 768px) {
          .button-group {
            grid-template-columns: 1fr;
          }
          
          .title {
            font-size: 2rem;
          }
          
          .access-card, .info-card {
            padding: 1rem;
            margin: 0.5rem;
          }
        }
      `}</style>
    </div>
  );
}
