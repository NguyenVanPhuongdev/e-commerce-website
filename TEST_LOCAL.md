# Hướng Dẫn Test Trên Máy Cá Nhân / Local Testing Guide

Hướng dẫn chạy và test ứng dụng trên máy cá nhân trước khi deploy lên production.
Guide for running and testing the application on your local machine before deploying to production.

---

## 🚀 Cách 1: Development Mode (Khuyến Nghị) / Development Mode (Recommended)

Cách này phù hợp để phát triển và test nhanh.
This method is suitable for development and quick testing.

### Bước 1: Cài Đặt Dependencies / Install Dependencies

```bash
# Cài đặt Backend dependencies
cd backend
npm install

# Cài đặt Frontend dependencies
cd ../frontend
npm install
```

### Bước 2: Khởi Tạo Database / Initialize Database

```bash
cd backend
npm run init-data
```

### Bước 3: Chạy Backend / Run Backend

Mở Terminal 1:

```bash
cd backend
npm run dev
```

Backend sẽ chạy tại: `http://localhost:5000`

### Bước 4: Chạy Frontend / Run Frontend

Mở Terminal 2:

```bash
cd frontend
npm run dev
```

Frontend sẽ chạy tại: `http://localhost:3000` (theo cấu hình trong vite.config.js)

### Kiểm Tra / Check

- Frontend: http://localhost:3000
- Backend API: http://localhost:5000
- Health Check: http://localhost:5000/health
- API Services: http://localhost:5000/api/services

---

## 🐳 Cách 2: Docker Compose (Giống Production) / Docker Compose (Like Production)

Cách này giống với môi trường production, tốt để test trước khi deploy.
This method is similar to production environment, good for testing before deployment.

### Yêu Cầu / Requirements

- Docker Desktop đã được cài đặt và đang chạy
- Docker Desktop installed and running

### Chạy với Docker / Run with Docker

```bash
# Build và start containers
docker-compose up -d --build

# Xem logs
docker-compose logs -f

# Kiểm tra trạng thái
docker-compose ps
```

### Truy Cập / Access

- Frontend: http://localhost
- Backend API: http://localhost:5000
- Health Check: http://localhost:5000/health

### Dừng Containers / Stop Containers

```bash
# Dừng containers
docker-compose down

# Dừng và xóa volumes (xóa database)
docker-compose down -v
```

---

## ⚙️ Cấu Hình Port / Port Configuration

### Thay Đổi Port Frontend / Change Frontend Port

Nếu port 3000 đã được sử dụng, bạn có thể:

**Cách 1: Chạy với port khác**
```bash
cd frontend
npm run dev -- --port 3001
```

**Cách 2: Sửa file `frontend/vite.config.js`**
```javascript
server: {
  port: 3001, // Thay đổi port ở đây
  // ...
}
```

### Thay Đổi Port Backend / Change Backend Port

**Cách 1: Sử dụng biến môi trường**
```bash
cd backend
PORT=5001 npm run dev
```

**Cách 2: Tạo file `.env` trong thư mục `backend/`**
```env
PORT=5001
NODE_ENV=development
```

Sau đó cập nhật `frontend/vite.config.js` để proxy đúng port:
```javascript
proxy: {
  '/api': {
    target: 'http://localhost:5001', // Cập nhật port ở đây
    changeOrigin: true,
  }
}
```

---

## 🔧 Troubleshooting / Xử Lý Sự Cố

### Port Đã Được Sử Dụng / Port Already in Use

**Windows:**
```powershell
# Kiểm tra port nào đang sử dụng
netstat -ano | findstr :3000
netstat -ano | findstr :5000

# Kill process (thay <PID> bằng Process ID)
taskkill /PID <PID> /F
```

**Linux/Mac:**
```bash
# Kiểm tra port
lsof -i :3000
lsof -i :5000

# Kill process
kill -9 <PID>
```

### Database Errors / Lỗi Database

```bash
# Xóa database cũ và khởi tạo lại
cd backend
rm database/database.sqlite
npm run init-data
```

### Frontend Không Kết Nối Được Backend / Frontend Can't Connect to Backend

1. Kiểm tra backend đã chạy chưa: http://localhost:5000/health
2. Kiểm tra proxy trong `frontend/vite.config.js`
3. Kiểm tra CORS trong backend (đã được enable mặc định)

### Docker Containers Không Khởi Động / Docker Containers Won't Start

```bash
# Xem logs chi tiết
docker-compose logs

# Rebuild containers
docker-compose up -d --build --force-recreate

# Xóa tất cả và bắt đầu lại
docker-compose down -v
docker-compose up -d --build
```

---

## 📝 So Sánh Development vs Docker / Development vs Docker Comparison

| Tính Năng / Feature | Development Mode | Docker Compose |
|---------------------|-----------------|----------------|
| Tốc độ khởi động / Startup Speed | ⚡ Nhanh / Fast | 🐌 Chậm hơn / Slower |
| Hot Reload | ✅ Có / Yes | ❌ Không / No |
| Giống Production | ❌ Không / No | ✅ Có / Yes |
| Dễ debug | ✅ Dễ / Easy | ⚠️ Khó hơn / Harder |
| Cần Docker | ❌ Không / No | ✅ Có / Yes |

**Khuyến nghị / Recommendation:**
- Phát triển tính năng mới: Dùng **Development Mode**
- Test trước khi deploy: Dùng **Docker Compose**

---

## ✅ Checklist Test / Testing Checklist

Trước khi deploy lên production, đảm bảo test các tính năng sau:

- [ ] Frontend load được và hiển thị đúng
- [ ] Backend API hoạt động (test `/health` và `/api/services`)
- [ ] File upload hoạt động
- [ ] Database operations hoạt động (CRUD)
- [ ] Tracking functionality hoạt động
- [ ] Responsive design trên mobile/tablet
- [ ] Không có lỗi trong console (F12)
- [ ] Performance acceptable

---

## 🎯 Next Steps / Bước Tiếp Theo

Sau khi test thành công trên máy cá nhân:

1. ✅ Commit code lên GitHub
2. ✅ Deploy lên server production theo hướng dẫn trong `PRODUCTION_DEPLOYMENT.md`
3. ✅ Test lại trên production domain

---

**Lưu ý / Note:** Luôn test kỹ trên máy cá nhân trước khi deploy lên production!
Always test thoroughly on your local machine before deploying to production!

