# Hetzner Server Dashboard

A Next.js web application deployed on Vercel to access and manage your Hetzner server remotely, bypassing company network restrictions.

## Features

- 🖥️ Server connection interface
- 🔧 Server management tools
- 📊 System status monitoring
- 🚀 Quick action buttons
- 🔒 Secure proxy API for server communication

## Deployment to Vercel

### Prerequisites
- GitHub account
- Vercel account (free)
- Your Hetzner server IP/domain

### Quick Deploy Steps

1. **Push to GitHub**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit: Hetzner server dashboard"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/hetzner-dashboard.git
   git push -u origin main
   ```

2. **Deploy to Vercel**:
   - Go to [vercel.com](https://vercel.com)
   - Click "New Project"
   - Import your GitHub repository
   - Click "Deploy"

3. **Access Your Dashboard**:
   - Your app will be available at: `https://your-project-name.vercel.app`
   - Enter your Hetzner server IP/domain to connect

## Usage

1. Open your Vercel deployment URL
2. Enter your Hetzner server IP or domain name
3. Click "Connect" to establish connection
4. Use the management buttons to interact with your server

## API Proxy

The app includes a proxy API (`/api/proxy`) that helps bypass CORS restrictions and company firewalls by routing requests through Vercel's servers.

## Local Development

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the app.

## Environment Variables

No environment variables are required for basic functionality. The app connects directly to your server through the proxy API.

## Security Notes

- Always use HTTPS for your Hetzner server endpoints
- Consider implementing authentication for production use
- Monitor your server logs for any unusual activity

## Troubleshooting

- If connection fails, check your server's firewall settings
- Ensure your server is accessible from external networks
- Verify the server URL format (include http:// or https://)

## Next Steps

- Add authentication system
- Implement real-time server monitoring
- Add SSH terminal functionality
- Create file management interface
