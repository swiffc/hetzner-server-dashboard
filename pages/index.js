import { useState } from 'react';
import Head from 'next/head';

export default function Home() {
  const [serverUrl, setServerUrl] = useState('');
  const [isConnected, setIsConnected] = useState(false);

  const connectToServer = () => {
    if (serverUrl) {
      setIsConnected(true);
    }
  };

  return (
    <div className="container">
      <Head>
        <title>Hetzner Server Dashboard</title>
        <meta name="description" content="Access your Hetzner server through Vercel" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className="main">
        <h1 className="title">
          Hetzner Server Dashboard
        </h1>

        <p className="description">
          Access your Hetzner server securely through this Vercel deployment
        </p>

        <div className="grid">
          <div className="card">
            <h2>Server Connection</h2>
            <div className="input-group">
              <input
                type="text"
                placeholder="Enter your Hetzner server IP or domain"
                value={serverUrl}
                onChange={(e) => setServerUrl(e.target.value)}
                className="server-input"
              />
              <button onClick={connectToServer} className="connect-btn">
                Connect
              </button>
            </div>
            {isConnected && (
              <div className="status">
                <span className="status-indicator connected"></span>
                Connected to: {serverUrl}
              </div>
            )}
          </div>

          <div className="card">
            <h2>Server Management</h2>
            <div className="button-group">
              <button className="action-btn">SSH Terminal</button>
              <button className="action-btn">File Manager</button>
              <button className="action-btn">System Monitor</button>
              <button className="action-btn">Docker Containers</button>
            </div>
          </div>

          <div className="card">
            <h2>Quick Actions</h2>
            <div className="button-group">
              <button className="action-btn secondary">Restart Services</button>
              <button className="action-btn secondary">View Logs</button>
              <button className="action-btn secondary">Backup Data</button>
              <button className="action-btn secondary">Update System</button>
            </div>
          </div>

          <div className="card">
            <h2>Server Status</h2>
            <div className="status-grid">
              <div className="status-item">
                <span>CPU Usage</span>
                <span className="status-value">--</span>
              </div>
              <div className="status-item">
                <span>Memory</span>
                <span className="status-value">--</span>
              </div>
              <div className="status-item">
                <span>Disk Space</span>
                <span className="status-value">--</span>
              </div>
              <div className="status-item">
                <span>Uptime</span>
                <span className="status-value">--</span>
              </div>
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
          padding: 5rem 0;
          flex: 1;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          max-width: 1200px;
          width: 100%;
        }

        .title {
          margin: 0;
          line-height: 1.15;
          font-size: 4rem;
          text-align: center;
          color: white;
          text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }

        .description {
          text-align: center;
          line-height: 1.5;
          font-size: 1.5rem;
          color: rgba(255,255,255,0.8);
          margin-bottom: 2rem;
        }

        .grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
          gap: 2rem;
          width: 100%;
          max-width: 1000px;
        }

        .card {
          padding: 1.5rem;
          text-align: left;
          color: inherit;
          text-decoration: none;
          border: 1px solid rgba(255,255,255,0.2);
          border-radius: 10px;
          background: rgba(255,255,255,0.1);
          backdrop-filter: blur(10px);
          transition: all 0.3s ease;
        }

        .card:hover {
          transform: translateY(-5px);
          box-shadow: 0 10px 25px rgba(0,0,0,0.2);
        }

        .card h2 {
          margin: 0 0 1rem 0;
          font-size: 1.5rem;
          color: white;
        }

        .input-group {
          display: flex;
          gap: 0.5rem;
          margin-bottom: 1rem;
        }

        .server-input {
          flex: 1;
          padding: 0.75rem;
          border: 1px solid rgba(255,255,255,0.3);
          border-radius: 5px;
          background: rgba(255,255,255,0.1);
          color: white;
          font-size: 1rem;
        }

        .server-input::placeholder {
          color: rgba(255,255,255,0.6);
        }

        .connect-btn {
          padding: 0.75rem 1.5rem;
          background: #4CAF50;
          color: white;
          border: none;
          border-radius: 5px;
          cursor: pointer;
          font-size: 1rem;
          transition: background 0.3s ease;
        }

        .connect-btn:hover {
          background: #45a049;
        }

        .button-group {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
          gap: 0.5rem;
        }

        .action-btn {
          padding: 0.75rem;
          background: rgba(255,255,255,0.2);
          color: white;
          border: 1px solid rgba(255,255,255,0.3);
          border-radius: 5px;
          cursor: pointer;
          transition: all 0.3s ease;
          font-size: 0.9rem;
        }

        .action-btn:hover {
          background: rgba(255,255,255,0.3);
          transform: translateY(-2px);
        }

        .action-btn.secondary {
          background: rgba(255,255,255,0.1);
        }

        .status {
          display: flex;
          align-items: center;
          gap: 0.5rem;
          color: white;
          margin-top: 1rem;
        }

        .status-indicator {
          width: 10px;
          height: 10px;
          border-radius: 50%;
          background: #4CAF50;
          animation: pulse 2s infinite;
        }

        .status-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 1rem;
        }

        .status-item {
          display: flex;
          justify-content: space-between;
          color: white;
          padding: 0.5rem 0;
          border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .status-value {
          font-weight: bold;
          color: #4CAF50;
        }

        @keyframes pulse {
          0% {
            box-shadow: 0 0 0 0 rgba(76, 175, 80, 0.7);
          }
          70% {
            box-shadow: 0 0 0 10px rgba(76, 175, 80, 0);
          }
          100% {
            box-shadow: 0 0 0 0 rgba(76, 175, 80, 0);
          }
        }

        @media (max-width: 600px) {
          .grid {
            grid-template-columns: 1fr;
          }
          
          .title {
            font-size: 2.5rem;
          }
          
          .input-group {
            flex-direction: column;
          }
        }
      `}</style>
    </div>
  );
}
