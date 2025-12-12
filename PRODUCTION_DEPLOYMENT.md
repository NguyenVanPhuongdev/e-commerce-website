# Hướng Dẫn Triển Khai Production - Docker Deployment Guide
# Production Deployment Guide - Docker

Hướng dẫn chi tiết triển khai ứng dụng DHL Shipping lên server production thực tế sử dụng Docker.
Detailed guide for deploying DHL Shipping application to production server using Docker.

## 🔗 Repository / Repository

**GitHub**: [https://github.com/PNreal/dropshiping](https://github.com/PNreal/dropshiping)

**Production Domain**: 
- Frontend: https://logistictransport.au
- Backend API: https://api.logistictransport.au
- Server IP: 34.124.152.52

---

## 📋 Mục Lục / Table of Contents

1. [Chuẩn Bị Server / Server Preparation](#1-chuẩn-bị-server)
2. [Cài Đặt Docker / Docker Installation](#2-cài-đặt-docker)
3. [Triển Khai Ứng Dụng / Deploy Application](#3-triển-khai-ứng-dụng)
4. [Cấu Hình Domain & SSL / Domain & SSL Setup](#4-cấu-hình-domain--ssl)
5. [Reverse Proxy với Nginx / Nginx Reverse Proxy](#5-reverse-proxy-với-nginx)
6. [Backup & Monitoring / Backup & Monitoring](#6-backup--monitoring)
7. [Security Best Practices / Security](#7-security-best-practices)
8. [Troubleshooting / Troubleshooting](#8-troubleshooting)

---

## 1. Chuẩn Bị Server / Server Preparation

### Yêu Cầu Tối Thiểu / Minimum Requirements

- **OS**: Ubuntu 20.04+ hoặc Debian 11+ (Linux)
- **RAM**: Tối thiểu 2GB (khuyến nghị 4GB+)
- **CPU**: 2 cores trở lên
- **Disk**: 20GB trống
- **Network**: Public IP và domain name

### Cập Nhật Hệ Thống / System Update

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y curl wget git ufw
```

---

## 2. Cài Đặt Docker / Docker Installation

### Cài Đặt Docker Engine / Install Docker Engine

```bash
# Remove old versions
sudo apt-get remove docker docker-engine docker.io containerd runc

# Install prerequisites
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Setup repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group (optional, để chạy docker không cần sudo)
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker compose version
```

### Cấu Hình Docker / Docker Configuration

```bash
# Enable Docker to start on boot
sudo systemctl enable docker
sudo systemctl start docker

# Verify Docker is running
sudo systemctl status docker
```

---

## 3. Triển Khai Ứng Dụng / Deploy Application

### Bước 1: Upload Code Lên Server / Upload Code to Server

**Cách 1: Sử dụng Git (Khuyến nghị) / Using Git (Recommended)**

```bash
# Clone repository từ GitHub
cd /opt
sudo git clone https://github.com/PNreal/dropshiping.git dhlshipping
cd dhlshipping
```

**Cách 2: Sử dụng SCP / Using SCP**

```bash
# Từ máy local, upload code lên server
scp -r /path/to/DHLSHIPPING user@34.124.152.52:/opt/dhlshipping
```

### Bước 2: Tạo File Environment / Create Environment File

```bash
cd /opt/dhlshipping

# Tạo file .env cho docker-compose
sudo nano .env
```

Nội dung file `.env`:

```env
# Backend Configuration
NODE_ENV=production
PORT=5000
DATABASE_PATH=./database/database.sqlite

# Domain Configuration (production)
DOMAIN=logistictransport.au
FRONTEND_URL=https://logistictransport.au
BACKEND_URL=https://api.logistictransport.au

# Security (Generate strong secrets)
SESSION_SECRET=your-very-long-random-secret-key-here
JWT_SECRET=your-jwt-secret-key-here

# Database Backup
BACKUP_ENABLED=true
BACKUP_INTERVAL=24h
```

### Bước 3: Cấu Hình Docker Compose Production / Configure Docker Compose

Tạo file `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: dhl-backend-prod
    restart: unless-stopped
    environment:
      - NODE_ENV=production
      - PORT=5000
    volumes:
      - ./backend/database:/app/database
      - ./backend/uploads:/app/uploads
      - ./logs/backend:/app/logs
    networks:
      - dhl-network
    healthcheck:
      test: ["CMD", "wget", "--spider", "--quiet", "-T", "5", "http://127.0.0.1:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: dhl-frontend-prod
    restart: unless-stopped
    depends_on:
      - backend
    networks:
      - dhl-network
    healthcheck:
      test: ["CMD", "wget", "--spider", "--quiet", "-T", "5", "http://127.0.0.1:80"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

networks:
  dhl-network:
    driver: bridge
```

### Bước 4: Build và Chạy Containers / Build and Run Containers

```bash
cd /opt/dhlshipping

# Build images
docker compose -f docker-compose.prod.yml build

# Start containers
docker compose -f docker-compose.prod.yml up -d

# Check status
docker compose -f docker-compose.prod.yml ps

# View logs
docker compose -f docker-compose.prod.yml logs -f
```

### Bước 5: Khởi Tạo Database / Initialize Database

```bash
# Chạy script init data trong container
docker exec dhl-backend-prod npm run init-data
```

---

## 4. Cấu Hình Domain & SSL / Domain & SSL Setup

### Bước 1: Cấu Hình DNS / Configure DNS

Thêm các bản ghi DNS (IP public của bạn: `34.124.152.52`):

```
A     logistictransport.au        34.124.152.52
A     www                         34.124.152.52
A     api                         34.124.152.52
# Nếu cần CNAME cho api sang root (không bắt buộc khi đã dùng A):
# CNAME api logistictransport.au
```

### Bước 2: Cài Đặt Certbot / Install Certbot

```bash
# Install Certbot
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx

# Verify installation
certbot --version
```

---

## 5. Reverse Proxy với Nginx / Nginx Reverse Proxy

### Bước 1: Cài Đặt Nginx / Install Nginx

```bash
sudo apt-get install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

### Bước 2: Cấu Hình Nginx cho Frontend / Configure Nginx for Frontend

Tạo file `/etc/nginx/sites-available/dhl-frontend`:

```nginx
# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name logistictransport.au www.logistictransport.au;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS Configuration
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name logistictransport.au www.logistictransport.au;

    # SSL Configuration (will be updated by Certbot)
    ssl_certificate /etc/letsencrypt/live/logistictransport.au/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/logistictransport.au/privkey.pem;
    
    # SSL Security Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Proxy to Frontend Container
    location / {
        proxy_pass http://127.0.0.1:80;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # API Proxy
    location /api {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Increase timeouts for API
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }

    # Uploads Proxy
    location ^~ /uploads {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Increase upload size limit
        client_max_body_size 50M;
    }

    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://127.0.0.1:80;
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
}
```

### Bước 3: Cấu Hình Nginx cho Backend API / Configure Nginx for Backend API

Tạo file `/etc/nginx/sites-available/dhl-api`:

```nginx
# API Subdomain
server {
    listen 80;
    listen [::]:80;
    server_name api.logistictransport.au;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name api.logistictransport.au;

    ssl_certificate /etc/letsencrypt/live/logistictransport.au/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/logistictransport.au/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Content-Type-Options "nosniff" always;

    # CORS Headers (adjust as needed)
    add_header Access-Control-Allow-Origin "https://logistictransport.au" always;
    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Authorization, Content-Type" always;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        client_max_body_size 50M;
    }
}
```

### Bước 4: Enable Sites và Test / Enable Sites and Test

```bash
# Enable sites
sudo ln -s /etc/nginx/sites-available/dhl-frontend /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/dhl-api /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### Bước 5: Lấy SSL Certificate / Get SSL Certificate

```bash
# Get certificate for main domain
sudo certbot --nginx -d logistictransport.au -d www.logistictransport.au

# Get certificate for API subdomain
sudo certbot --nginx -d api.logistictransport.au

# Test auto-renewal
sudo certbot renew --dry-run

# Setup auto-renewal cron (usually already configured)
sudo systemctl status certbot.timer
```

---

## 6. Backup & Monitoring / Backup & Monitoring

### Tự Động Backup Database / Automated Database Backup

Tạo script `/opt/dhlshipping/scripts/backup.sh`:

```bash
#!/bin/bash

# Configuration
BACKUP_DIR="/opt/dhlshipping/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_PATH="/opt/dhlshipping/backend/database/database.sqlite"
RETENTION_DAYS=7

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
cp $DB_PATH "$BACKUP_DIR/database_$DATE.sqlite"

# Compress backup
gzip "$BACKUP_DIR/database_$DATE.sqlite"

# Remove old backups (keep last 7 days)
find $BACKUP_DIR -name "database_*.sqlite.gz" -mtime +$RETENTION_DAYS -delete

# Backup uploads directory
tar -czf "$BACKUP_DIR/uploads_$DATE.tar.gz" -C /opt/dhlshipping/backend uploads/

# Remove old upload backups
find $BACKUP_DIR -name "uploads_*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup completed: $DATE"
```

Cấp quyền thực thi:

```bash
chmod +x /opt/dhlshipping/scripts/backup.sh
```

Thêm vào Crontab (chạy hàng ngày lúc 2 giờ sáng):

```bash
sudo crontab -e

# Add this line:
0 2 * * * /opt/dhlshipping/scripts/backup.sh >> /var/log/dhl-backup.log 2>&1
```

### Monitoring với Docker Stats / Monitoring with Docker Stats

Tạo script `/opt/dhlshipping/scripts/monitor.sh`:

```bash
#!/bin/bash

# Check container health
BACKEND_STATUS=$(docker inspect dhl-backend-prod --format='{{.State.Health.Status}}')
FRONTEND_STATUS=$(docker inspect dhl-frontend-prod --format='{{.State.Health.Status}}')

if [ "$BACKEND_STATUS" != "healthy" ]; then
    echo "ALERT: Backend container is not healthy!"
    # Send notification (email, Slack, etc.)
fi

if [ "$FRONTEND_STATUS" != "healthy" ]; then
    echo "ALERT: Frontend container is not healthy!"
    # Send notification
fi

# Check disk space
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "ALERT: Disk usage is above 80%!"
fi
```

### Log Rotation / Log Rotation

Docker đã được cấu hình log rotation trong `docker-compose.prod.yml`. Để xem logs:

```bash
# View backend logs
docker logs dhl-backend-prod --tail 100 -f

# View frontend logs
docker logs dhl-frontend-prod --tail 100 -f

# View all logs
docker compose -f docker-compose.prod.yml logs -f
```

---

## 7. Security Best Practices / Security Best Practices

### Firewall Configuration / Cấu Hình Firewall

```bash
# Enable UFW
sudo ufw enable

# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Deny direct access to Docker ports
sudo ufw deny 5000/tcp

# Check status
sudo ufw status
```

### Update Docker Images / Cập Nhật Docker Images

```bash
# Pull latest base images
docker compose -f docker-compose.prod.yml pull

# Rebuild and restart
docker compose -f docker-compose.prod.yml up -d --build
```

### Regular Updates / Cập Nhật Định Kỳ

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Update Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Restart Docker
sudo systemctl restart docker
```

### Environment Variables Security / Bảo Mật Biến Môi Trường

- Không commit file `.env` vào Git
- Sử dụng secrets management (Docker secrets, HashiCorp Vault)
- Rotate secrets định kỳ
- Sử dụng strong passwords và keys

---

## 8. Troubleshooting / Troubleshooting

### Containers Không Khởi Động / Containers Won't Start

```bash
# Check logs
docker compose -f docker-compose.prod.yml logs

# Check container status
docker compose -f docker-compose.prod.yml ps

# Restart containers
docker compose -f docker-compose.prod.yml restart

# Rebuild and restart
docker compose -f docker-compose.prod.yml up -d --build
```

### Port Đã Được Sử Dụng / Port Already in Use

```bash
# Check what's using the port
sudo netstat -tulpn | grep :5000
sudo netstat -tulpn | grep :80

# Kill process if needed
sudo kill -9 <PID>
```

### Database Errors / Lỗi Database

```bash
# Check database file permissions
ls -la /opt/dhlshipping/backend/database/

# Fix permissions
sudo chmod 644 /opt/dhlshipping/backend/database/database.sqlite
sudo chown $USER:$USER /opt/dhlshipping/backend/database/database.sqlite

# Check database integrity
docker exec dhl-backend-prod sqlite3 /app/database/database.sqlite "PRAGMA integrity_check;"
```

### SSL Certificate Issues / Vấn Đề SSL

```bash
# Check certificate status
sudo certbot certificates

# Renew certificate manually
sudo certbot renew

# Check Nginx SSL configuration
sudo nginx -t
```

### Performance Issues / Vấn Đề Hiệu Suất

```bash
# Check container resources
docker stats

# Check disk space
df -h

# Check memory
free -h

# Check logs for errors
docker compose -f docker-compose.prod.yml logs | grep -i error
```

---

## 📝 Checklist Triển Khai / Deployment Checklist

### Trước Khi Triển Khai / Pre-Deployment

- [ ] Server đã được cấu hình và cập nhật
- [ ] Docker và Docker Compose đã được cài đặt
- [ ] Domain name đã được cấu hình DNS
- [ ] Firewall đã được cấu hình
- [ ] SSH key đã được setup
- [ ] Backup strategy đã được lên kế hoạch

### Trong Khi Triển Khai / During Deployment

- [ ] Code đã được upload lên server
- [ ] Environment variables đã được cấu hình
- [ ] Docker images đã được build
- [ ] Containers đã được khởi động và healthy
- [ ] Database đã được khởi tạo
- [ ] Nginx đã được cấu hình
- [ ] SSL certificate đã được cài đặt

### Sau Khi Triển Khai / Post-Deployment

- [ ] Ứng dụng có thể truy cập qua HTTPS
- [ ] API endpoints hoạt động đúng
- [ ] File uploads hoạt động
- [ ] Database backup đang chạy tự động
- [ ] Monitoring đã được setup
- [ ] Logs đang được ghi đúng
- [ ] Performance đạt yêu cầu

---

## 🔗 Quick Reference Commands / Lệnh Tham Khảo Nhanh

```bash
# Start application
cd /opt/dhlshipping
docker compose -f docker-compose.prod.yml up -d

# Stop application
docker compose -f docker-compose.prod.yml down

# View logs
docker compose -f docker-compose.prod.yml logs -f

# Restart services
docker compose -f docker-compose.prod.yml restart

# Update application
git pull
docker compose -f docker-compose.prod.yml up -d --build

# Backup database
/opt/dhlshipping/scripts/backup.sh

# Check status
docker compose -f docker-compose.prod.yml ps
docker stats
```

---

**Lưu ý / Note:** Luôn test trên staging environment trước khi deploy lên production!
Always test on staging environment before deploying to production!

