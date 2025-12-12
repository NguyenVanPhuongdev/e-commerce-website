# Hướng Dẫn Test với Docker Compose / Docker Compose Testing Guide

Hướng dẫn chi tiết cách chạy và test ứng dụng với Docker Compose trên máy cá nhân.
Detailed guide for running and testing the application with Docker Compose on your local machine.

---

## ✅ Kiểm Tra Trạng Thái Hiện Tại / Check Current Status

Containers đang chạy:
- **Backend**: `dhl-backend` trên port 5000
- **Frontend**: `dhl-frontend` trên port 80

---

## 🚀 Các Lệnh Cơ Bản / Basic Commands

### 1. Khởi Động Containers / Start Containers

```bash
# Build và start containers
docker-compose up -d --build

# Chỉ start (nếu đã build rồi)
docker-compose up -d
```

### 2. Xem Trạng Thái / View Status

```bash
# Xem trạng thái containers
docker-compose ps

# Xem logs real-time
docker-compose logs -f

# Xem logs của một service cụ thể
docker-compose logs -f backend
docker-compose logs -f frontend
```

### 3. Dừng Containers / Stop Containers

```bash
# Dừng containers (giữ lại data)
docker-compose stop

# Dừng và xóa containers (giữ lại data)
docker-compose down

# Dừng và xóa tất cả bao gồm volumes (XÓA DATABASE!)
docker-compose down -v
```

### 4. Restart Containers / Restart Containers

```bash
# Restart tất cả
docker-compose restart

# Restart một service cụ thể
docker-compose restart backend
docker-compose restart frontend
```

### 5. Rebuild Containers / Rebuild Containers

```bash
# Rebuild và restart
docker-compose up -d --build

# Rebuild không cache (build từ đầu)
docker-compose build --no-cache
docker-compose up -d
```

---

## 🔍 Kiểm Tra và Test / Check and Test

### Truy Cập Ứng Dụng / Access Application

- **Frontend**: http://localhost
- **Backend API**: http://localhost:5000
- **Health Check**: http://localhost:5000/health
- **API Services**: http://localhost:5000/api/services

### Kiểm Tra Health / Check Health

```bash
# Kiểm tra health của containers
docker-compose ps

# Kiểm tra health chi tiết
docker inspect dhl-backend --format='{{json .State.Health}}'
docker inspect dhl-frontend --format='{{json .State.Health}}'
```

### Test API / Test API

**Windows PowerShell:**
```powershell
# Health check
Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing

# Test API services
Invoke-WebRequest -Uri "http://localhost:5000/api/services" -UseBasicParsing
```

**Linux/Mac/Windows Git Bash:**
```bash
# Health check
curl http://localhost:5000/health

# Test API services
curl http://localhost:5000/api/services
```

---

## 🗄️ Quản Lý Database / Database Management

### Khởi Tạo Database / Initialize Database

```bash
# Chạy script init data trong container
docker exec dhl-backend npm run init-data
```

### Backup Database / Backup Database

```bash
# Copy database từ container ra máy local
docker cp dhl-backend:/app/database/database.sqlite ./backend/database/database.sqlite.backup
```

### Restore Database / Restore Database

```bash
# Copy database từ máy local vào container
docker cp ./backend/database/database.sqlite.backup dhl-backend:/app/database/database.sqlite

# Restart backend để load database mới
docker-compose restart backend
```

### Xem Database / View Database

```bash
# Vào trong container backend
docker exec -it dhl-backend sh

# Trong container, có thể dùng sqlite3 nếu có
sqlite3 /app/database/database.sqlite
```

---

## 📁 Quản Lý Files / File Management

### Xem Files trong Container / View Files in Container

```bash
# List files trong backend container
docker exec dhl-backend ls -la /app

# List uploads
docker exec dhl-backend ls -la /app/uploads
```

### Copy Files / Copy Files

```bash
# Copy file từ container ra máy local
docker cp dhl-backend:/app/database/database.sqlite ./backup.sqlite

# Copy file từ máy local vào container
docker cp ./some-file.txt dhl-backend:/app/some-file.txt
```

---

## 🔧 Troubleshooting / Xử Lý Sự Cố

### Containers Không Khởi Động / Containers Won't Start

```bash
# Xem logs chi tiết
docker-compose logs

# Xem logs của service cụ thể
docker-compose logs backend
docker-compose logs frontend

# Rebuild từ đầu
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Port Đã Được Sử Dụng / Port Already in Use

**Windows:**
```powershell
# Kiểm tra port 80
netstat -ano | findstr :80

# Kiểm tra port 5000
netstat -ano | findstr :5000

# Kill process (thay <PID> bằng Process ID)
taskkill /PID <PID> /F
```

**Linux/Mac:**
```bash
# Kiểm tra port
lsof -i :80
lsof -i :5000

# Kill process
kill -9 <PID>
```

**Hoặc đổi port trong docker-compose.yml:**
```yaml
ports:
  - "8080:80"      # Thay vì 80:80
  - "5001:5000"    # Thay vì 5000:5000
```

### Container Không Healthy / Container Not Healthy

```bash
# Xem health check logs
docker inspect dhl-backend --format='{{json .State.Health}}' | ConvertFrom-Json | Format-List

# Restart container
docker-compose restart backend

# Rebuild container
docker-compose up -d --build backend
```

### Database Errors / Lỗi Database

```bash
# Xóa database và khởi tạo lại
docker exec dhl-backend rm /app/database/database.sqlite
docker exec dhl-backend npm run init-data

# Hoặc restart container (database sẽ được mount từ host)
docker-compose restart backend
```

### Xóa Tất Cả và Bắt Đầu Lại / Clean Everything and Start Fresh

```bash
# Dừng và xóa tất cả
docker-compose down -v

# Xóa images
docker rmi dhlshipping-backend dhlshipping-frontend

# Build lại từ đầu
docker-compose build --no-cache
docker-compose up -d
```

---

## 📊 Monitoring / Giám Sát

### Xem Resource Usage / View Resource Usage

```bash
# Xem CPU, Memory usage của containers
docker stats

# Xem disk usage
docker system df
```

### Xem Logs / View Logs

```bash
# Xem logs real-time của tất cả
docker-compose logs -f

# Xem logs của backend (last 100 lines)
docker-compose logs --tail=100 backend

# Xem logs của frontend
docker-compose logs --tail=100 frontend
```

---

## 🔄 Workflow Test Thông Thường / Common Testing Workflow

### 1. Lần Đầu Chạy / First Time Setup

```bash
# Clone repository
git clone https://github.com/PNreal/dropshiping.git
cd dropshiping

# Build và start
docker-compose up -d --build

# Khởi tạo database
docker exec dhl-backend npm run init-data

# Kiểm tra
docker-compose ps
```

### 2. Sau Khi Sửa Code / After Code Changes

```bash
# Rebuild và restart
docker-compose up -d --build

# Hoặc chỉ restart nếu không thay đổi dependencies
docker-compose restart
```

### 3. Test Trước Khi Commit / Test Before Commit

```bash
# Kiểm tra containers đang chạy
docker-compose ps

# Test API
curl http://localhost:5000/health
curl http://localhost:5000/api/services

# Mở browser test frontend
# http://localhost
```

---

## 📝 Checklist Test / Testing Checklist

Trước khi deploy lên production, đảm bảo:

- [ ] Containers đang chạy và healthy
- [ ] Frontend load được tại http://localhost
- [ ] Backend API hoạt động tại http://localhost:5000
- [ ] Health check trả về OK
- [ ] API endpoints hoạt động đúng
- [ ] File upload hoạt động
- [ ] Database operations hoạt động
- [ ] Không có lỗi trong logs

---

## 🎯 So Sánh với Production / Comparison with Production

| Tính Năng / Feature | Local Docker | Production |
|---------------------|--------------|------------|
| Frontend URL | http://localhost | https://logistictransport.au |
| Backend URL | http://localhost:5000 | https://api.logistictransport.au |
| SSL | ❌ Không | ✅ Có |
| Domain | localhost | logistictransport.au |
| Nginx Reverse Proxy | ❌ Không | ✅ Có |

**Lưu ý:** Local Docker giống production về cấu trúc containers nhưng khác về network và SSL.

---

## 🚀 Next Steps / Bước Tiếp Theo

Sau khi test thành công với Docker Compose trên máy cá nhân:

1. ✅ Test tất cả tính năng
2. ✅ Commit code lên GitHub
3. ✅ Deploy lên production server theo `PRODUCTION_DEPLOYMENT.md`
4. ✅ Test lại trên production domain

---

**Lưu ý / Note:** Docker Compose trên máy cá nhân giúp bạn test trong môi trường giống production trước khi deploy thực tế!
Docker Compose on your local machine helps you test in a production-like environment before actual deployment!

