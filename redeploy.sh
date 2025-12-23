#!/bin/bash

echo "🚀 Redeploying application..."

# Pull code mới
echo "📥 Pulling latest code..."
git pull origin main

# Đảm bảo docker-compose.yml dùng port 8080
echo "� Eensuring frontend uses port 8080..."
sed -i 's/"80:80"/"8080:80"/' docker-compose.yml

# Dừng containers và xóa network cũ
echo "🛑 Stopping containers..."
docker compose down
docker rm -f dhl-frontend dhl-backend 2>/dev/null
docker network rm dhl-network 2>/dev/null

# Rebuild và restart containers
echo "🐳 Rebuilding Docker containers..."
docker compose build --no-cache
docker compose up -d

# Đợi containers khởi động
echo "⏳ Waiting for containers to start..."
sleep 10

# Kiểm tra trạng thái
echo ""
echo "📊 Container status:"
docker compose ps

echo ""
echo "🔍 Testing containers..."
curl -s http://localhost:8080 > /dev/null && echo "✅ Frontend OK" || echo "❌ Frontend failed"
curl -s http://localhost:5000/health > /dev/null && echo "✅ Backend OK" || echo "❌ Backend failed"

echo ""
echo "✅ Deployment complete!"
echo "🌐 Website: https://logistictransport.com.au"
echo "💾 Database preserved"
