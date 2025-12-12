# Hướng dẫn chạy Backend và Frontend

## Trạng thái hiện tại:

-  **Backend**: Đang chạy tại `http://localhost:5000` (có thể truy cập từ mạng nội bộ)
-  **Frontend**: Đang chạy tại `http://localhost:3000` (có thể truy cập từ mạng nội bộ)

## Truy cập từ mạng nội bộ / Network Access

Sau khi khởi động servers, bạn sẽ thấy địa chỉ IP network trong console. Người khác có thể truy cập bằng:
- Frontend: `http://[YOUR_IP]:3000`
- Backend API: `http://[YOUR_IP]:5000`

**Lưu ý:** Đảm bảo firewall cho phép port 3000 và 5000.

Xem chi tiết trong file `NETWORK_ACCESS.md`

## Backend API Endpoints:

### Health Check
- `GET http://localhost:5000/health` - Kiểm tra trạng thái server

### Services
- `GET http://localhost:5000/api/services` - Lấy danh sách dịch vụ
- `GET http://localhost:5000/api/services/:id` - Lấy chi tiết dịch vụ
- `POST http://localhost:5000/api/services` - Tạo dịch vụ mới

### News
- `GET http://localhost:5000/api/news` - Lấy danh sách tin tức
- `GET http://localhost:5000/api/news/:id` - Lấy chi tiết tin tức
- `POST http://localhost:5000/api/news` - Tạo tin tức mới

### Tracking
- `GET http://localhost:5000/api/tracking/:trackingNumber` - Tra cứu vận đơn
- `POST http://localhost:5000/api/tracking` - Tạo tracking mới
- `PUT http://localhost:5000/api/tracking/:trackingNumber` - Cập nhật tracking

### Orders
- `GET http://localhost:5000/api/orders` - Lấy danh sách đơn hàng
- `GET http://localhost:5000/api/orders/:id` - Lấy chi tiết đơn hàng
- `POST http://localhost:5000/api/orders` - Tạo đơn hàng mới

## Frontend:

Mở trình duyệt và truy cập: **http://localhost:3000**

## Chạy lại servers:

### Backend (Terminal 1):
```bash
cd backend
npm start
# hoặc
npm run dev  # với nodemon (tự động restart)
```

### Frontend (Terminal 2):
```bash
cd frontend
npm run dev
```

## Dừng servers:

Nhấn `Ctrl + C` trong terminal đang chạy server để dừng.

## Kiểm tra servers đang chạy:

```bash
# Kiểm tra port 5000 (Backend)
netstat -ano | findstr "5000"

# Kiểm tra port 3000 (Frontend)
netstat -ano | findstr "3000"
```

## Test API:

### Test với curl:
```bash
# Health check
curl http://localhost:5000/health

# Lấy danh sách dịch vụ
curl http://localhost:5000/api/services

# Tra cứu vận đơn
curl http://localhost:5000/api/tracking/DHL1234567890
```

### Test với trình duyệt:
- Mở: `http://localhost:5000/api/services`
- Mở: `http://localhost:5000/api/news`
- Mở: `http://localhost:5000/api/tracking/DHL1234567890`

## Dữ liệu mẫu đã có:

-  6 dịch vụ (Services)
-  3 tin tức (News)
-  3 mã tracking mẫu:
  - `DHL1234567890` - In Transit
  - `DHL0987654321` - Delivered
  - `DHL1122334455` - Processing

