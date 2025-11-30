# 🚀 Tutorial 02: CI/CD với GitHub Actions

Hướng dẫn setup CI/CD pipeline tự động: Build → Push → Deploy lên VPS

## 🎯 CI/CD là gì?

**CI/CD** = **Continuous Integration / Continuous Deployment**

- **CI**: Tự động build và test khi có code mới
- **CD**: Tự động deploy lên server

**Lợi ích**:
- ✅ Không cần build/deploy thủ công
- ✅ Tự động test code
- ✅ Deploy nhanh và nhất quán
- ✅ Giảm lỗi do thao tác thủ công

## 📋 Workflow CI/CD

```
1. Developer push code lên GitHub
   ↓
2. GitHub Actions tự động chạy:
   - Build Docker image
   - Test (nếu có)
   - Push lên Docker Hub
   - SSH vào VPS
   - Pull image mới
   - Restart container
   ↓
3. ✅ Ứng dụng đã được update tự động!
```

## 🚀 Bước 1: Tạo GitHub Repository

### Nếu chưa có repo:

```bash
# Trên máy local
cd /Users/huydev/Code/Devops

# Khởi tạo git (nếu chưa có)
git init

# Thêm remote
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Commit code
git add .
git commit -m "Initial commit"

# Push lên GitHub
git push -u origin main
```

## 🔐 Bước 2: Tạo GitHub Secrets

### Vào GitHub Repository:

1. Vào **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Thêm các secrets sau:

#### Secret 1: DOCKER_USERNAME
- **Name**: `DOCKER_USERNAME`
- **Value**: `huyde1626`

#### Secret 2: DOCKER_PASSWORD
- **Name**: `DOCKER_PASSWORD`
- **Value**: (Password Docker Hub của bạn)

#### Secret 3: VPS_HOST
- **Name**: `VPS_HOST`
- **Value**: `62.171.131.164`

#### Secret 4: VPS_USERNAME
- **Name**: `VPS_USERNAME`
- **Value**: `root`

#### Secret 5: VPS_SSH_KEY
- **Name**: `VPS_SSH_KEY`
- **Value**: (SSH private key - xem hướng dẫn bên dưới)

## 🔑 Bước 3: Tạo SSH Key cho VPS

### Trên máy local:

```bash
# Tạo SSH key (nếu chưa có)
ssh-keygen -t rsa -b 4096 -C "github-actions" -f ~/.ssh/github_actions

# Copy public key lên VPS
ssh-copy-id -i ~/.ssh/github_actions.pub root@62.171.131.164

# Hoặc copy thủ công:
cat ~/.ssh/github_actions.pub
# Copy output và paste vào VPS: ~/.ssh/authorized_keys
```

### Trên VPS:

```bash
# Tạo thư mục .ssh nếu chưa có
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Thêm public key vào authorized_keys
echo "YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### Copy Private Key vào GitHub Secret:

```bash
# Trên máy local, xem private key
cat ~/.ssh/github_actions

# Copy toàn bộ output (bao gồm -----BEGIN và -----END)
# Paste vào GitHub Secret: VPS_SSH_KEY
```

## 📝 Bước 4: Tạo GitHub Actions Workflow

### Tạo file `.github/workflows/deploy.yml`:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

env:
  DOCKER_IMAGE: nodejs-app
  CONTAINER_NAME: nodejs-app
  VPS_PORT: 3000

jobs:
  build-and-push:
    name: Build and Push Docker Image
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

    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ secrets.DOCKER_USERNAME }}/${{ env.DOCKER_IMAGE }}:latest
        cache-from: type=registry,ref=${{ secrets.DOCKER_USERNAME }}/${{ env.DOCKER_IMAGE }}:buildcache
        cache-to: type=registry,ref=${{ secrets.DOCKER_USERNAME }}/${{ env.DOCKER_IMAGE }}:buildcache,mode=max

    - name: Deploy to VPS
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.VPS_HOST }}
        username: ${{ secrets.VPS_USERNAME }}
        key: ${{ secrets.VPS_SSH_KEY }}
        script: |
          # Pull image mới nhất
          docker pull ${{ secrets.DOCKER_USERNAME }}/${{ env.DOCKER_IMAGE }}:latest
          
          # Stop và xóa container cũ
          docker stop ${{ env.CONTAINER_NAME }} || true
          docker rm ${{ env.CONTAINER_NAME }} || true
          
          # Chạy container mới
          docker run -d \
            -p ${{ env.VPS_PORT }}:3000 \
            --name ${{ env.CONTAINER_NAME }} \
            --restart always \
            ${{ secrets.DOCKER_USERNAME }}/${{ env.DOCKER_IMAGE }}:latest
          
          # Đợi container start
          sleep 3
          
          # Kiểm tra
          docker ps | grep ${{ env.CONTAINER_NAME }}
          echo "✅ Deployment complete!"
```

## 🚀 Bước 5: Test CI/CD Pipeline

### Push code lên GitHub:

```bash
# Commit workflow file
git add .github/workflows/deploy.yml
git commit -m "Add CI/CD pipeline"
git push origin main
```

### Kiểm tra:

1. Vào GitHub repository
2. Click tab **Actions**
3. Bạn sẽ thấy workflow đang chạy
4. Click vào workflow để xem chi tiết

**Kết quả mong đợi**:
- ✅ Build image thành công
- ✅ Push lên Docker Hub thành công
- ✅ Deploy lên VPS thành công
- ✅ Container đang chạy

## 🎯 Workflow Chi Tiết

### Khi nào pipeline chạy?

- ✅ **Push code** lên branch `main` hoặc `master`
- ✅ **Pull Request** vào branch `main` hoặc `master`

### Pipeline làm gì?

1. **Checkout code**: Lấy code từ GitHub
2. **Setup Docker**: Chuẩn bị môi trường build
3. **Login Docker Hub**: Đăng nhập để push image
4. **Build & Push**: Build image và push lên Docker Hub
5. **Deploy VPS**: SSH vào VPS và update container

## 🔧 Tùy chỉnh Pipeline

### Thêm Test Step:

```yaml
- name: Run tests
  run: |
    npm install
    npm test
```

### Chỉ deploy khi test pass:

```yaml
deploy:
  needs: build-and-push
  if: success()
  # ... deploy steps
```

### Deploy với version tag:

```yaml
- name: Build and push
  uses: docker/build-push-action@v5
  with:
    tags: |
      ${{ secrets.DOCKER_USERNAME }}/${{ env.DOCKER_IMAGE }}:latest
      ${{ secrets.DOCKER_USERNAME }}/${{ env.DOCKER_IMAGE }}:${{ github.sha }}
```

## 📊 Monitoring Pipeline

### Xem logs:

1. Vào GitHub → **Actions** tab
2. Click vào workflow run
3. Click vào job để xem logs chi tiết

### Badge Status:

Thêm vào README.md:

```markdown
![CI/CD](https://github.com/YOUR_USERNAME/YOUR_REPO/workflows/CI/CD%20Pipeline/badge.svg)
```

## 🆘 Troubleshooting

### Lỗi: "Permission denied (publickey)"

- Kiểm tra SSH key đã copy đúng chưa
- Kiểm tra VPS_SSH_KEY secret đúng format chưa
- Test SSH: `ssh -i ~/.ssh/github_actions root@62.171.131.164`

### Lỗi: "Docker login failed"

- Kiểm tra DOCKER_USERNAME và DOCKER_PASSWORD đúng chưa
- Test login: `docker login` trên máy local

### Lỗi: "Port already in use"

- Container cũ chưa được xóa
- Thêm `docker rm -f` trước khi chạy container mới

### Pipeline không chạy

- Kiểm tra file `.github/workflows/deploy.yml` đúng syntax chưa
- Kiểm tra branch name (`main` hoặc `master`)
- Kiểm tra file đã được commit và push chưa

## ✅ Checklist Setup CI/CD

- [ ] GitHub repository đã tạo
- [ ] Code đã push lên GitHub
- [ ] GitHub Secrets đã thêm (5 secrets)
- [ ] SSH key đã setup trên VPS
- [ ] Workflow file đã tạo (`.github/workflows/deploy.yml`)
- [ ] Workflow đã commit và push
- [ ] Pipeline chạy thành công
- [ ] Container đã update trên VPS

## 🎉 Hoàn thành!

Bây giờ mỗi khi bạn:
1. Sửa code
2. Commit và push lên GitHub
3. ✅ Tự động build, push và deploy!

**Không cần làm gì thêm!** 🚀

---

## 📚 Tài liệu tham khảo

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [SSH Action](https://github.com/appleboy/ssh-action)

