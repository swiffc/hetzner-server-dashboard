# GitHub Push Script
# Replace YOUR_USERNAME with your actual GitHub username

Write-Host "Pushing Hetzner Server Dashboard to GitHub..." -ForegroundColor Green

# Add the correct remote (replace YOUR_USERNAME with your GitHub username)
Write-Host "Please replace YOUR_USERNAME in the command below with your actual GitHub username:" -ForegroundColor Yellow
Write-Host "git remote add origin https://github.com/YOUR_USERNAME/hetzner-server-dashboard.git" -ForegroundColor Cyan

# Uncomment and modify the line below with your actual username:
# git remote add origin https://github.com/YOUR_USERNAME/hetzner-server-dashboard.git

# Set main branch and push
git branch -M main
# git push -u origin main

Write-Host "After adding the correct remote URL, uncomment the git push line and run this script again." -ForegroundColor Yellow
