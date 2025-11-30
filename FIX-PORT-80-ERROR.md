# 🔧 Fix Lỗi: Port 80 đã được sử dụng

## ❌ Lỗi hiện tại:
```
Error: failed to bind host port 0.0.0.0:80/tcp: address already in use
```

**Nguyên nhân**: Port 80 đã được một service khác sử dụng (thường là Apache, Nginx, hoặc container cũ).

## 🔍 Bước 1: Tìm process đang dùng port 80

### Trên VPS, chạy:

```bash
# Cách 1: Dùng netstat
netstat -tulpn | grep :80

# Cách 2: Dùng lsof
lsof -i :80

# Cách 3: Dùng ss
ss -tulpn | grep :80
```

**Kết quả sẽ hiển thị process đang dùng port 80**

## 🔧 Bước 2: Xử lý

### Option A: Dừng service đang dùng port 80

Nếu là Apache:
```bash
systemctl stop apache2
systemctl disable apache2
```

Nếu là Nginx:
```bash
systemctl stop nginx
systemctl disable nginx
```

Nếu là container Docker cũ:
```bash
# Xem tất cả containers (kể cả đã dừng)
docker ps -a

# Xóa container cũ
docker stop <container-id>
docker rm <container-id>
```

### Option B: Dùng port khác (8080)

Nếu không muốn dừng service hiện tại, dùng port 8080:

```bash
# Xóa container đã tạo (nếu có)
docker rm nodejs-app 2>/dev/null || true

# Chạy với port 8080
docker run -d \
  -p 8080:3000 \
  --name nodejs-app \
  --restart always \
  huyde1626/nodejs-app:latest
```

Sau đó truy cập: `http://62.171.131.164:8080`

## ✅ Bước 3: Chạy lại container

Sau khi đã xử lý port 80, chạy lại:

```bash
# Chạy container
docker run -d \
  -p 80:3000 \
  --name nodejs-app \
  --restart always \
  huyde1626/nodejs-app:latest
```

## 🔍 Kiểm tra

```bash
# Xem container đang chạy
docker ps

# Test local
curl http://localhost:80

# Xem logs
docker logs nodejs-app
```

## 📋 Script tự động fix

Chạy script này trên VPS:

```bash
#!/bin/bash
# Fix port 80 và chạy container

# Tìm và dừng process dùng port 80
PID=$(lsof -t -i:80)
if [ ! -z "$PID" ]; then
    echo "🛑 Stopping process using port 80 (PID: $PID)"
    kill -9 $PID 2>/dev/null || true
fi

# Xóa container cũ nếu có
docker stop nodejs-app 2>/dev/null || true
docker rm nodejs-app 2>/dev/null || true

# Chạy container mới
echo "🚀 Starting container..."
docker run -d \
  -p 80:3000 \
  --name nodejs-app \
  --restart always \
  huyde1626/nodejs-app:latest

# Đợi container start
sleep 3

# Kiểm tra
echo "✅ Container status:"
docker ps | grep nodejs-app

echo ""
echo "📋 Test:"
curl http://localhost:80
```

