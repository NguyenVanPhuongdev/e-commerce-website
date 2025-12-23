#!/bin/bash

echo "🚀 Starting deployment..."
echo "⚠️  Database will be preserved!"

# Pull latest code
echo "📥 Pulling latest code from GitHub..."
git pull origin main

# Check if using Docker
if [ -f "docker-compose.yml" ]; then
    echo "🐳 Deploying with Docker..."
    echo "📦 Stopping containers (keeping volumes)..."
    docker compose down
    echo "🔨 Building new images..."
    docker compose build --no-cache
    echo "🚀 Starting containers..."
    docker compose up -d
    echo "✅ Docker deployment complete!"
    echo "💾 Database preserved in volumes"
else
    echo "📦 Deploying without Docker..."
    
    # Backend
    echo "🔧 Updating backend..."
    cd backend
    npm install
    pm2 restart dhl-backend || npm start &
    cd ..
    
    # Frontend
    echo "🎨 Building frontend..."
    cd frontend
    npm install
    npm run build
    pm2 restart dhl-frontend || echo "Frontend built successfully"
    cd ..
    
    echo "✅ Deployment complete!"
fi

# Show status
echo "📊 Checking services status..."
if command -v docker &> /dev/null; then
    docker compose ps 2>/dev/null || docker ps
elif command -v pm2 &> /dev/null; then
    pm2 status
fi

echo "🎉 Deployment finished!"
