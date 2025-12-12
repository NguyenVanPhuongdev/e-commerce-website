# Hướng Dẫn Triển Khai Nhanh / Quick Deployment Guide

Hướng dẫn nhanh để triển khai ứng dụng DHL Shipping lên server production.
Quick guide to deploy DHL Shipping application to production server.

## 🚀 Triển Khai Nhanh / Quick Deploy

### Bước 1: Chuẩn Bị Server / Prepare Server

```bash
# Upload script setup lên server
scp scripts/setup-server.sh user@34.124.152.52:/tmp/

# SSH vào server và chạy script
ssh user@34.124.152.52
sudo bash /tmp/setup-server.sh
```

### Bước 2: Upload Code / Upload Code

```bash
# Cách 1: Sử dụng Git (Khuyến nghị)
cd /opt
sudo git clone https://github.com/PNreal/dropshiping.git dhlshipping
cd dhlshipping

# Cách 2: Sử dụng SCP
scp -r . user@34.124.152.52:/opt/dhlshipping/
```

### Bước 3: Cấu Hình / Configuration

```bash
cd /opt/dhlshipping

# Copy file docker-compose mẫu
cp docker-compose.prod.yml.example docker-compose.prod.yml

# Tạo file .env
nano .env
# (Nhập các biến môi trường cần thiết)
```

### Bước 4: Triển Khai / Deploy

```bash
# Cấp quyền thực thi cho script
chmod +x scripts/deploy.sh

# Chạy script triển khai
./scripts/deploy.sh
# Chọn option 1 để build và start
```

### Bước 5: Cấu Hình Nginx & SSL / Configure Nginx & SSL

```bash
# Copy cấu hình Nginx (xem PRODUCTION_DEPLOYMENT.md)
sudo nano /etc/nginx/sites-available/dhl-frontend
sudo nano /etc/nginx/sites-available/dhl-api

# Enable sites
sudo ln -s /etc/nginx/sites-available/dhl-frontend /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/dhl-api /etc/nginx/sites-enabled/

# Test và reload
sudo nginx -t
sudo systemctl reload nginx

# Lấy SSL certificate
sudo certbot --nginx -d logistictransport.au -d www.logistictransport.au
sudo certbot --nginx -d api.logistictransport.au
```

## 📋 Checklist / Checklist

- [ ] Server đã được setup (Docker, Nginx)
- [ ] Code đã được upload
- [ ] File .env đã được cấu hình
- [ ] Containers đã được build và start
- [ ] Database đã được khởi tạo
- [ ] Nginx đã được cấu hình
- [ ] SSL certificate đã được cài đặt
- [ ] Firewall đã được cấu hình
- [ ] Backup đã được setup

## 🔧 Các Lệnh Thường Dùng / Common Commands

```bash
# Xem trạng thái
docker compose -f docker-compose.prod.yml ps

# Xem logs
docker compose -f docker-compose.prod.yml logs -f

# Restart
docker compose -f docker-compose.prod.yml restart

# Update và rebuild
git pull
docker compose -f docker-compose.prod.yml up -d --build

# Backup database
./scripts/backup.sh
```

## 📚 Tài Liệu Chi Tiết / Detailed Documentation

Xem file `PRODUCTION_DEPLOYMENT.md` để biết hướng dẫn chi tiết.
See `PRODUCTION_DEPLOYMENT.md` for detailed guide.

## 🆘 Hỗ Trợ / Support

Nếu gặp vấn đề, xem phần Troubleshooting trong `PRODUCTION_DEPLOYMENT.md`
If you encounter issues, see Troubleshooting section in `PRODUCTION_DEPLOYMENT.md`

