# Vercel Deployment Script for Hetzner Server Dashboard
Write-Host "Deploying Hetzner Server Dashboard to Vercel..." -ForegroundColor Green

# Check if Vercel CLI is installed
try {
    $vercelVersion = npx vercel --version
    Write-Host "Vercel CLI found: $vercelVersion" -ForegroundColor Green
} catch {
    Write-Host "Installing Vercel CLI..." -ForegroundColor Yellow
    npm install -g vercel
}

# Deploy to Vercel
Write-Host "Starting deployment..." -ForegroundColor Yellow
npx vercel --prod --yes --name "hetzner-server-dashboard"

Write-Host "Deployment complete! Your dashboard should be available at the provided URL." -ForegroundColor Green
Write-Host "You can now access your CentOS Hetzner server through this Vercel deployment." -ForegroundColor Cyan
