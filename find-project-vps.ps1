# Script để tìm thư mục project trên VPS

param(
    [string]$VpsHost = "",
    [string]$VpsUser = "root"
)

if ([string]::IsNullOrEmpty($VpsHost)) {
    $VpsHost = Read-Host "Nhập địa chỉ IP VPS"
}

Write-Host "🔍 Searching for project on VPS: $VpsUser@$VpsHost" -ForegroundColor Cyan

$searchScript = @"
echo '🔍 Searching for DHL Shipping project...'
echo ''
echo '📁 Checking common locations:'
echo ''

# Check common directories
for dir in /root/dhl-shipping-react-nodejs /root/DHLSHIPPING /home/*/dhl-shipping-react-nodejs /var/www/dhl-shipping-react-nodejs /opt/dhl-shipping-react-nodejs; do
    if [ -d "\$dir" ]; then
        echo "✅ Found: \$dir"
        if [ -f "\$dir/docker-compose.yml" ]; then
            echo "   - Has docker-compose.yml"
        fi
        if [ -d "\$dir/backend" ]; then
            echo "   - Has backend folder"
        fi
        if [ -d "\$dir/frontend" ]; then
            echo "   - Has frontend folder"
        fi
        echo ''
    fi
done

echo '🐳 Checking Docker containers:'
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null || echo 'Docker not running or not installed'
echo ''

echo '📦 Checking PM2 processes:'
pm2 list 2>/dev/null || echo 'PM2 not installed'
echo ''

echo '🌐 Checking Nginx config:'
if [ -f /etc/nginx/sites-enabled/default ]; then
    grep -i 'root\|proxy_pass' /etc/nginx/sites-enabled/default | head -5
fi
echo ''

echo '🔎 Finding all docker-compose.yml files:'
find / -name 'docker-compose.yml' -type f 2>/dev/null | grep -v node_modules
echo ''

echo '📂 Current directory:'
pwd
"@

ssh "$VpsUser@$VpsHost" $searchScript

Write-Host "`n✅ Search complete!" -ForegroundColor Green
Write-Host "💡 Tip: Thư mục project thường ở /root/ hoặc /var/www/" -ForegroundColor Yellow
