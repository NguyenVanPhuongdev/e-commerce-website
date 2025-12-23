# PowerShell script để deploy lên VPS từ Windows

param(
    [string]$VpsHost = "",
    [string]$VpsUser = "root",
    [string]$ProjectPath = "/root/DHLSHIPPING"
)

Write-Host "🚀 Starting VPS deployment..." -ForegroundColor Green

if ([string]::IsNullOrEmpty($VpsHost)) {
    $VpsHost = Read-Host "Nhập địa chỉ IP VPS"
}

Write-Host "📡 Connecting to VPS: $VpsUser@$VpsHost" -ForegroundColor Cyan

# Tạo script deploy trên VPS
$deployScript = @"
cd $ProjectPath
echo '📥 Pulling latest code...'
git pull origin main

if [ -f 'docker-compose.yml' ]; then
    echo '🐳 Restarting Docker containers...'
    docker-compose down
    docker-compose build --no-cache
    docker-compose up -d
    docker-compose ps
else
    echo '📦 Restarting services...'
    cd backend && npm install && pm2 restart dhl-backend
    cd ../frontend && npm install && npm run build && pm2 restart dhl-frontend
    pm2 status
fi

echo '✅ Deployment complete!'
"@

# Thực thi script trên VPS qua SSH
Write-Host "🔧 Executing deployment on VPS..." -ForegroundColor Yellow
ssh "$VpsUser@$VpsHost" $deployScript

Write-Host "🎉 Deployment finished!" -ForegroundColor Green
Write-Host "🌐 Check your website: http://$VpsHost" -ForegroundColor Cyan
