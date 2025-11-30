# 🔍 Tìm Port Trống và Deploy

Port 80 và 8080 đều đã bị chiếm. Hãy tìm port trống!

## 🔍 Bước 1: Kiểm tra port nào trống

### Trên VPS, chạy lệnh này để tìm port trống:

```bash
# Kiểm tra các port phổ biến
for port in 3000 5000 8000 9000 3001 5001; do
  if ! netstat -tuln | grep -q ":$port "; then
    echo "✅ Port $port is FREE"
  else
    echo "❌ Port $port is IN USE"
  fi
done
```

**Hoặc kiểm tra từng port:**

```bash
# Kiểm tra port 3000
netstat -tuln | grep :3000

# Kiểm tra port 5000
netstat -tuln | grep :5000

# Kiểm tra port 8000
netstat -tuln | grep :8000

# Kiểm tra port 9000
netstat -tuln | grep :9000
```

**Nếu không có kết quả** = Port trống, có thể dùng!

---

## 🚀 Bước 2: Dừng process đang dùng port 8080 (Nếu muốn dùng 8080)

```bash
# Tìm process đang dùng port 8080
sudo lsof -i :8080

# Dừng process (thay PID bằng số thực tế)
sudo kill -9 <PID>
```

---

## ✅ Bước 3: Deploy với port trống

### Option A: Dùng Port 3000 (Nếu trống)

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

### Option B: Dùng Port 5000 (Nếu trống)

```bash
docker rm -f nodejs-app 2>/dev/null || true
docker run -d \
  -p 5000:3000 \
  --name nodejs-app \
  --restart always \
  huyde1626/nodejs-app:latest
```

**Truy cập**: `http://62.171.131.164:5000`

---

### Option C: Dùng Port 8000 (Nếu trống)

```bash
docker rm -f nodejs-app 2>/dev/null || true
docker run -d \
  -p 8000:3000 \
  --name nodejs-app \
  --restart always \
  huyde1626/nodejs-app:latest
```

**Truy cập**: `http://62.171.131.164:8000`

---

## 🎯 Script Tự Động Tìm Port Trống

Copy và chạy script này trên VPS:

```bash
#!/bin/bash
# Tìm port trống và deploy

# Danh sách port để thử
PORTS=(3000 5000 8000 9000 3001 5001 8001)

for port in "${PORTS[@]}"; do
  if ! netstat -tuln | grep -q ":$port "; then
    echo "✅ Found free port: $port"
    
    # Xóa container cũ
    docker rm -f nodejs-app 2>/dev/null || true
    
    # Deploy với port trống
    echo "🚀 Deploying on port $port..."
    docker run -d \
      -p $port:3000 \
      --name nodejs-app \
      --restart always \
      huyde1626/nodejs-app:latest
    
    sleep 3
    
    # Kiểm tra
    if docker ps | grep -q nodejs-app; then
      echo ""
      echo "✅ Success! Container is running on port $port"
      echo "🌐 Access: http://62.171.131.164:$port"
      echo ""
      docker ps | grep nodejs-app
      echo ""
      echo "📋 Test:"
      curl http://localhost:$port
      break
    else
      echo "❌ Failed to start container on port $port"
    fi
  else
    echo "❌ Port $port is in use"
  fi
done
```

---

## 🔥 Nhanh nhất: Dùng Port 3000

Nếu port 3000 trống, chạy ngay:

```bash
docker rm -f nodejs-app 2>/dev/null || true
docker run -d -p 3000:3000 --name nodejs-app --restart always huyde1626/nodejs-app:latest
docker ps | grep nodejs-app
curl http://localhost:3000
```

---

## 📋 Checklist

1. [ ] Kiểm tra port nào trống
2. [ ] Chọn port (3000, 5000, 8000, ...)
3. [ ] Deploy container với port đó
4. [ ] Test local: `curl http://localhost:PORT`
5. [ ] Test từ internet: `http://62.171.131.164:PORT`
6. [ ] Mở firewall nếu cần: `ufw allow PORT/tcp`

---

**Chạy script trên để tự động tìm port trống và deploy! 🚀**

