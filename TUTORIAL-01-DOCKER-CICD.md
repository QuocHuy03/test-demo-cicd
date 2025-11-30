# 📦 Tutorial 01: Docker + CI/CD Cơ bản

Hướng dẫn từng bước để build Docker image và tự động hóa với CI/CD pipeline.

## 🎯 Mục tiêu

- Build Docker image từ ứng dụng Node.js
- Push image lên Docker Hub
- Tự động hóa với GitHub Actions
- Test image local

## 📋 Bước 1: Chuẩn bị

### 1.1. Kiểm tra ứng dụng

```bash
# Test ứng dụng local
npm install
npm start

# Mở terminal khác và test
curl http://localhost:3000
curl http://localhost:3000/health
```

### 1.2. Tạo Docker Hub account và repository

#### Bước 1: Đăng ký Docker Hub
1. Truy cập https://hub.docker.com
2. Click **Sign Up** (hoặc **Sign In** nếu đã có tài khoản)
3. Điền thông tin và tạo tài khoản
4. Xác nhận email nếu cần

#### Bước 2: Tạo repository trên Docker Hub
1. Đăng nhập vào https://hub.docker.com
2. Click nút **Create Repository** (hoặc vào **Repositories** → **Create Repository**)
3. Điền thông tin:
   - **Repository Name**: `nodejs-app` (hoặc tên bạn muốn)
   - **Visibility**: 
     - **Public**: Miễn phí, ai cũng có thể pull
     - **Private**: Có phí, chỉ bạn mới thấy
   - **Description**: (tùy chọn) Mô tả về repository
4. Click **Create**

#### Bước 3: Lưu thông tin
Sau khi tạo xong, bạn sẽ có:
- **Repository URL**: `your-username/nodejs-app`
- **Full image name**: `your-username/nodejs-app:tag`

**Ví dụ**: Nếu username của bạn là `john`, repository sẽ là:
- `john/nodejs-app:latest`
- `john/nodejs-app:v1.0.0`

**Lưu ý**: 
- Repository sẽ tự động được tạo khi bạn push image lần đầu (không cần tạo trước)
- Nhưng nên tạo trước để dễ quản lý và xem cấu trúc

## 📋 Bước 2: Build Docker Image Local

### 2.1. Build image

```bash
# Build image
docker build -t nodejs-app:latest .

# Hoặc với tag cụ thể
docker build -t nodejs-app:v1.0.0 .
```

### 2.2. Kiểm tra image

```bash
# Xem danh sách images
docker images

# Xem chi tiết image
docker inspect nodejs-app:latest
```

### 2.3. Test image local

```bash
# Chạy container
docker run -d -p 3000:3000 --name nodejs-app nodejs-app:latest

# Test
curl http://localhost:3000
curl http://localhost:3000/health

# Xem logs
docker logs nodejs-app

# Dừng và xóa container
docker stop nodejs-app
docker rm nodejs-app
```

## 📋 Bước 3: Push lên Docker Hub

### 3.1. Tag image với Docker Hub username

```bash
# Thay YOUR_USERNAME bằng username Docker Hub của bạn
docker tag nodejs-app:latest YOUR_USERNAME/nodejs-app:latest
docker tag nodejs-app:latest YOUR_USERNAME/nodejs-app:v1.0.0
```

### 3.2. Login Docker Hub

```bash
docker login
# Nhập username và password
```

### 3.3. Push image

```bash
# Push image
docker push YOUR_USERNAME/nodejs-app:latest
docker push YOUR_USERNAME/nodejs-app:v1.0.0
```

### 3.4. Kiểm tra trên Docker Hub

Vào https://hub.docker.com và kiểm tra repository của bạn.

## 📋 Bước 4: Tự động hóa với GitHub Actions

### 4.1. Tạo GitHub Secrets

1. Vào GitHub repository → **Settings** → **Secrets and variables** → **Actions**
2. Thêm 2 secrets:
   - `DOCKER_USERNAME`: Username Docker Hub của bạn
   - `DOCKER_PASSWORD`: Password Docker Hub của bạn

### 4.2. Tạo CI/CD Pipeline đơn giản

File `.github/workflows/docker-cicd.yml`:

```yaml
name: Docker Build and Push

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

env:
  DOCKER_IMAGE: nodejs-app

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ secrets.DOCKER_USERNAME }}/${{ env.DOCKER_IMAGE }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
          type=sha,prefix={{branch}}-
          type=raw,value=latest,enable={{is_default_branch}}

    - name: Build and push
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=registry,ref=${{ secrets.DOCKER_USERNAME }}/${{ env.DOCKER_IMAGE }}:buildcache
        cache-to: type=registry,ref=${{ secrets.DOCKER_USERNAME }}/${{ env.DOCKER_IMAGE }}:buildcache,mode=max
```

### 4.3. Push code và xem kết quả

```bash
git add .
git commit -m "Add Docker CI/CD pipeline"
git push origin main
```

Vào **Actions** tab trên GitHub để xem pipeline chạy.

## 📋 Bước 5: Test Image từ Docker Hub

### 5.1. Pull và chạy image

```bash
# Xóa image local cũ
docker rmi YOUR_USERNAME/nodejs-app:latest

# Pull image từ Docker Hub
docker pull YOUR_USERNAME/nodejs-app:latest

# Chạy container
docker run -d -p 3000:3000 --name nodejs-app YOUR_USERNAME/nodejs-app:latest

# Test
curl http://localhost:3000
```

## 🧪 Bài tập thực hành

### Bài tập 1: Tối ưu Dockerfile
- Giảm kích thước image
- Thêm multi-stage build
- Tối ưu layer caching

### Bài tập 2: Thêm health check
- Kiểm tra Dockerfile đã có health check chưa
- Test health check với `docker inspect`

### Bài tập 3: Versioning
- Tạo tags với version numbers
- Sử dụng semantic versioning

### Bài tập 4: Security scanning
- Thêm step scan image trong CI/CD
- Sử dụng Trivy hoặc Snyk

## 🔍 Troubleshooting

### Lỗi: "denied: requested access to the resource is denied"
- Kiểm tra đã login Docker Hub chưa: `docker login`
- Kiểm tra username và repository name đúng chưa

### Lỗi: "unauthorized: authentication required"
- Kiểm tra GitHub Secrets đã đúng chưa
- Thử login lại Docker Hub

### Lỗi: "no space left on device"
```bash
# Dọn dẹp Docker
docker system prune -a
```

### Image quá lớn
```bash
# Xem kích thước image
docker images

# Xem layers
docker history nodejs-app:latest
```

## 📚 Tài liệu tham khảo

- [Docker Documentation](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## ✅ Checklist

- [ ] Ứng dụng chạy được local
- [ ] Build Docker image thành công
- [ ] Test container local
- [ ] Push image lên Docker Hub
- [ ] Tạo GitHub Secrets
- [ ] CI/CD pipeline chạy thành công
- [ ] Pull và test image từ Docker Hub

## 🎉 Hoàn thành!

Sau khi hoàn thành tutorial này, bạn đã biết:
- ✅ Build Docker images
- ✅ Push images lên registry
- ✅ Tự động hóa với CI/CD
- ✅ Best practices cơ bản

**Bước tiếp theo**: Tutorial 02 - Deploy lên Kubernetes

