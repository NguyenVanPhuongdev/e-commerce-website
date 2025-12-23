#!/bin/bash

echo "🚀 Updating application with Nginx reverse proxy..."

# 1. Đổi port frontend sang 8080
echo "📝 Updating docker-compose.yml..."
sed -i 's/"80:80"/"8080:80"/' docker-compose.yml

# 2. Restart Docker containers
echo "🐳 Restarting Docker containers..."
docker compose down
docker compose up -d

# 3. Wait for containers
echo "⏳ Waiting for containers..."
sleep 5

# 4. Cấu hình Nginx
echo "🔧 Configuring Nginx..."
sudo tee /etc/nginx/sites-available/logistictransport.com.au > /dev/null <<'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name logistictransport.com.au www.logistictransport.com.au;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# 5. Enable site
sudo ln -sf /etc/nginx/sites-available/logistictransport.com.au /etc/nginx/sites-enabled/

# 6. Test và reload Nginx
echo "✅ Testing Nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "🔄 Reloading Nginx..."
    sudo systemctl reload nginx
    echo "✅ Nginx reloaded successfully!"
else
    echo "❌ Nginx configuration error!"
    exit 1
fi

# 7. Kiểm tra trạng thái
echo ""
echo "📊 Container status:"
docker compose ps

echo ""
echo "✅ Deployment complete!"
echo "🌐 Frontend: http://logistictransport.com.au"
echo "🔧 Backend: http://logistictransport.com.au/api"
