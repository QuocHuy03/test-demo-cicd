# 🚀 Hướng dẫn Deploy lên VPS Ubuntu - Từng Bước

VPS của bạn:
- **IP**: 62.171.131.164
- **User**: root
- **Password**: botngu123
- **Image**: huyde1626/nodejs-app:latest (đã push lên Docker Hub)

## 📋 Bước 1: Kiểm tra kết nối SSH

### Trên máy local của bạn:

```bash
# Test kết nối SSH
ssh root@62.171.131.164
```

**Nhập password khi được hỏi**: `botngu123`

Nếu kết nối thành công, bạn sẽ thấy prompt của VPS:
```
root@server:~#
```

**Nếu lỗi kết nối**, kiểm tra:
- VPS đã bật chưa
- Firewall có chặn SSH không
- IP đúng chưa

---

## 📋 Bước 2: Cài đặt Docker trên VPS

### SSH vào VPS và chạy:

```bash
# Cập nhật hệ thống
apt update

# Cài các package cần thiết
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Thêm Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Thêm Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Cài Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io

# Khởi động Docker
systemctl start docker
systemctl enable docker

# Kiểm tra Docker đã cài đặt
docker --version
```

**Kết quả mong đợi**: `Docker version 24.x.x` hoặc tương tự

---

## 📋 Bước 3: Login Docker Hub trên VPS

### Trên VPS, chạy:

```bash
# Login Docker Hub
docker login
```

**Nhập thông tin:**
- Username: `huyde1626`
- Password: (password Docker Hub của bạn)

**Kết quả**: `Login Succeeded`

---

## 📋 Bước 4: Pull Image từ Docker Hub

### Trên VPS, chạy:

```bash
# Pull image đã push
docker pull huyde1626/nodejs-app:latest
```

**Kết quả mong đợi**:
```
latest: Pulling from huyde1626/nodejs-app
...
Status: Downloaded newer image for huyde1626/nodejs-app:latest
```

### Kiểm tra image đã có:

```bash
docker images | grep nodejs-app
```

**Kết quả**: Sẽ thấy `huyde1626/nodejs-app   latest   ...`

---

## 📋 Bước 5: Chạy Container

### Trên VPS, chạy:

```bash
# Chạy container
docker run -d \
  -p 80:3000 \
  --name nodejs-app \
  --restart always \
  huyde1626/nodejs-app:latest
```

**Giải thích các tham số:**
- `-d`: Chạy ở background (detached mode)
- `-p 80:3000`: Map port 80 của VPS → port 3000 của container
- `--name nodejs-app`: Tên container
- `--restart always`: Tự động restart khi VPS reboot
- `huyde1626/nodejs-app:latest`: Image name

### Kiểm tra container đang chạy:

```bash
docker ps
```

**Kết quả mong đợi**:
```
CONTAINER ID   IMAGE                          STATUS         PORTS
abc123def456   huyde1626/nodejs-app:latest    Up 2 seconds   0.0.0.0:80->3000/tcp
```

---

## 📋 Bước 6: Kiểm tra ứng dụng

### Trên VPS, test local:

```bash
# Test endpoint
curl http://localhost:80
curl http://localhost:80/health
```

**Kết quả mong đợi**: JSON response từ ứng dụng

### Xem logs:

```bash
docker logs nodejs-app
```

### Xem logs real-time:

```bash
docker logs -f nodejs-app
```

**Nhấn Ctrl+C để thoát**

---

## 📋 Bước 7: Mở Firewall (Nếu cần)

### Kiểm tra firewall:

```bash
# Kiểm tra UFW status
ufw status
```

### Nếu firewall đang bật, mở port 80:

```bash
# Mở port 80 (HTTP)
ufw allow 80/tcp

# Mở port 443 (HTTPS - cho tương lai)
ufw allow 443/tcp

# Reload firewall
ufw reload
```

---

## 📋 Bước 8: Test từ máy local

### Từ máy local của bạn:

```bash
# Test từ máy bạn
curl http://62.171.131.164

# Hoặc mở browser
# http://62.171.131.164
```

**Kết quả mong đợi**: Trang web hiển thị JSON response

---

## ✅ Hoàn thành!

Bây giờ ứng dụng của bạn đã chạy trên VPS và có thể truy cập từ internet!

**URL**: http://62.171.131.164

---

## 🔄 Cách Update khi có code mới

### Bước 1: Build và Push (Trên máy local)

```bash
# Build image mới
docker build -t huyde1626/nodejs-app:latest .

# Push lên Docker Hub
docker push huyde1626/nodejs-app:latest
```

### Bước 2: Update trên VPS

```bash
# SSH vào VPS
ssh root@62.171.131.164

# Pull image mới
docker pull huyde1626/nodejs-app:latest

# Stop container cũ
docker stop nodejs-app
docker rm nodejs-app

# Start container mới
docker run -d \
  -p 80:3000 \
  --name nodejs-app \
  --restart always \
  huyde1626/nodejs-app:latest
```

---

## 🛠️ Các lệnh hữu ích

### Xem container đang chạy:
```bash
docker ps
```

### Xem logs:
```bash
docker logs nodejs-app
docker logs -f nodejs-app  # real-time
```

### Restart container:
```bash
docker restart nodejs-app
```

### Stop container:
```bash
docker stop nodejs-app
```

### Start container:
```bash
docker start nodejs-app
```

### Xóa container:
```bash
docker stop nodejs-app
docker rm nodejs-app
```

### Xem thông tin container:
```bash
docker inspect nodejs-app
```

---

## 🆘 Troubleshooting

### Container không start

```bash
# Xem logs để biết lỗi
docker logs nodejs-app

# Kiểm tra port đã dùng chưa
netstat -tulpn | grep 80
```

### Port 80 đã được dùng

```bash
# Tìm process đang dùng port 80
lsof -i :80

# Hoặc dùng port khác (ví dụ: 8080)
docker run -d -p 8080:3000 --name nodejs-app huyde1626/nodejs-app:latest
```

### Không truy cập được từ internet

1. Kiểm tra firewall: `ufw status`
2. Kiểm tra container đang chạy: `docker ps`
3. Test local trên VPS: `curl http://localhost:80`
4. Kiểm tra VPS có public IP không

### Container tự động dừng

```bash
# Xem logs để biết lỗi
docker logs nodejs-app

# Kiểm tra resource
docker stats nodejs-app
```

---

## 📝 Checklist

- [ ] SSH vào VPS thành công
- [ ] Cài Docker thành công
- [ ] Login Docker Hub thành công
- [ ] Pull image thành công
- [ ] Container đang chạy
- [ ] Test local trên VPS thành công
- [ ] Mở firewall (nếu cần)
- [ ] Test từ máy local thành công
- [ ] Truy cập được từ internet

---

## 🎯 Bước tiếp theo (Tùy chọn)

1. **Cấu hình Domain**: Trỏ domain về IP 62.171.131.164
2. **SSL/HTTPS**: Cài Let's Encrypt với Certbot
3. **Nginx Reverse Proxy**: Để quản lý nhiều apps
4. **Monitoring**: Cài monitoring tools
5. **Backup**: Setup backup strategy

---

**Chúc bạn deploy thành công! 🚀**

