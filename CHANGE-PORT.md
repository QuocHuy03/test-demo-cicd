# 🔄 Đổi Port cho Docker Container

## ✅ Có thể đổi port bất kỳ!

Bạn có thể dùng port **8080**, **3000**, **5000**, hoặc bất kỳ port nào khác.

## 🚀 Cách 1: Dùng Port 8080 (Khuyến nghị)

### Trên VPS, chạy:

```bash
# Xóa container cũ (nếu có)
docker rm -f nodejs-app 2>/dev/null || true

# Chạy với port 8080
docker run -d \
  -p 8080:3000 \
  --name nodejs-app \
  --restart always \
  huyde1626/nodejs-app:latest
```

**Truy cập**: `http://62.171.131.164:8080`

---

## 🚀 Cách 2: Dùng Port 3000

```bash
# Xóa container cũ
docker rm -f nodejs-app 2>/dev/null || true

# Chạy với port 3000
docker run -d \
  -p 3000:3000 \
  --name nodejs-app \
  --restart always \
  huyde1626/nodejs-app:latest
```

**Truy cập**: `http://62.171.131.164:3000`

---

## 🚀 Cách 3: Dùng Port 5000

```bash
# Xóa container cũ
docker rm -f nodejs-app 2>/dev/null || true

# Chạy với port 5000
docker run -d \
  -p 5000:3000 \
  --name nodejs-app \
  --restart always \
  huyde1626/nodejs-app:latest
```

**Truy cập**: `http://62.171.131.164:5000`

---

## 📝 Giải thích cú pháp

```bash
-p 8080:3000
```

- **8080**: Port của VPS (port bên ngoài)
- **3000**: Port của container (port bên trong, ứng dụng chạy ở port 3000)

**Nghĩa là**: Khi truy cập `http://VPS-IP:8080` → sẽ forward đến port 3000 của container

---

## 🔍 Kiểm tra port đã dùng

Trước khi chọn port, kiểm tra port nào đang trống:

```bash
# Kiểm tra port 8080
netstat -tulpn | grep :8080

# Kiểm tra port 3000
netstat -tulpn | grep :3000

# Kiểm tra port 5000
netstat -tulpn | grep :5000
```

**Nếu không có kết quả** = Port trống, có thể dùng!

---

## ✅ Script nhanh - Dùng Port 8080

Copy và chạy script này trên VPS:

```bash
#!/bin/bash
# Deploy với port 8080

# Xóa container cũ
docker rm -f nodejs-app 2>/dev/null || true

# Chạy container mới với port 8080
docker run -d \
  -p 8080:3000 \
  --name nodejs-app \
  --restart always \
  huyde1626/nodejs-app:latest

# Đợi container start
sleep 3

# Kiểm tra
echo "✅ Container status:"
docker ps | grep nodejs-app

echo ""
echo "📋 Test local:"
curl http://localhost:8080

echo ""
echo "🌐 Truy cập từ internet:"
echo "http://62.171.131.164:8080"
```

---

## 🔥 Mở Firewall cho Port mới

Nếu dùng port khác 80, cần mở firewall:

```bash
# Mở port 8080
ufw allow 8080/tcp

# Hoặc mở port 3000
ufw allow 3000/tcp

# Reload firewall
ufw reload
```

---

## 📋 Các Port phổ biến

| Port | Mục đích | Ghi chú |
|------|----------|---------|
| **80** | HTTP | Cần quyền root, thường bị chiếm |
| **443** | HTTPS | Cần quyền root, cho SSL |
| **8080** | HTTP Alternative | Phổ biến, không cần root |
| **3000** | Development | Thường dùng cho dev |
| **5000** | Development | Flask default |
| **8000** | Development | Django default |

**Khuyến nghị**: Dùng **8080** vì:
- ✅ Không cần quyền root
- ✅ Ít bị conflict
- ✅ Phổ biến cho production
- ✅ Dễ nhớ

---

## 🎯 Ví dụ hoàn chỉnh: Port 8080

### Trên VPS:

```bash
# 1. Xóa container cũ
docker rm -f nodejs-app 2>/dev/null || true

# 2. Chạy với port 8080
docker run -d \
  -p 8080:3000 \
  --name nodejs-app \
  --restart always \
  huyde1626/nodejs-app:latest

# 3. Mở firewall
ufw allow 8080/tcp

# 4. Kiểm tra
docker ps
curl http://localhost:8080
```

### Từ máy local:

```bash
# Test từ máy bạn
curl http://62.171.131.164:8080

# Hoặc mở browser
# http://62.171.131.164:8080
```

---

## 🔄 Update container với port mới

Nếu container đã chạy với port cũ, muốn đổi port:

```bash
# Stop và xóa container cũ
docker stop nodejs-app
docker rm nodejs-app

# Chạy lại với port mới
docker run -d \
  -p 8080:3000 \
  --name nodejs-app \
  --restart always \
  huyde1626/nodejs-app:latest
```

---

## ✅ Tóm lại

**Bạn có thể dùng bất kỳ port nào!** 

**Khuyến nghị**: Dùng **port 8080** vì:
- Dễ dùng
- Không cần root
- Ít conflict

**Lệnh nhanh**:
```bash
docker rm -f nodejs-app 2>/dev/null || true
docker run -d -p 8080:3000 --name nodejs-app --restart always huyde1626/nodejs-app:latest
```

🎉 **Xong! Truy cập**: `http://62.171.131.164:8080`

