#!/bin/bash

echo "🔍 Finding project directory..."

# Tìm thư mục project
PROJECT_DIR=""
for dir in /root/dhlshipping /root/DHLSHIPPING /root/dhl-shipping-react-nodejs /var/www/dhlshipping /opt/dhlshipping; do
    if [ -f "$dir/docker-compose.yml" ]; then
        PROJECT_DIR="$dir"
        echo "✅ Found project at: $PROJECT_DIR"
        break
    fi
done

if [ -z "$PROJECT_DIR" ]; then
    echo "❌ Project directory not found!"
    echo "🔎 Searching entire system..."
    PROJECT_DIR=$(find / -name "docker-compose.yml" -path "*/dhl*" -type f 2>/dev/null | head -1 | xargs dirname)
    if [ -n "$PROJECT_DIR" ]; then
        echo "✅ Found project at: $PROJECT_DIR"
    else
        echo "❌ Could not find project directory"
        exit 1
    fi
fi

cd "$PROJECT_DIR" || exit 1

echo ""
echo "📂 Working directory: $(pwd)"
echo ""
echo "🚀 Starting deployment..."
echo "⚠️  Database will be preserved!"
echo ""

# Pull latest code
echo "📥 Pulling latest code from GitHub..."
git pull origin main

if [ $? -ne 0 ]; then
    echo "❌ Git pull failed!"
    exit 1
fi

echo ""
echo "🐳 Restarting Docker containers..."
echo "📦 Stopping containers (keeping volumes)..."
docker compose down

echo "🔨 Building new images..."
docker compose build --no-cache

echo "🚀 Starting containers..."
docker compose up -d

echo ""
echo "⏳ Waiting for containers to be healthy..."
sleep 10

echo ""
echo "📊 Container status:"
docker compose ps

echo ""
echo "✅ Deployment complete!"
echo "💾 Database preserved"
echo "🌐 Frontend: http://your-domain:8080"
echo "🔧 Backend: http://localhost:5000"
