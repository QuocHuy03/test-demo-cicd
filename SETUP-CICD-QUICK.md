# ⚡ Setup CI/CD Nhanh - 5 Bước

Hướng dẫn nhanh để setup CI/CD trong 5 phút.

## 🎯 Mục tiêu

Tự động build và deploy khi push code lên GitHub.

## 📋 Bước 1: Tạo SSH Key (2 phút)

### Trên máy local:

```bash
# Tạo SSH key
ssh-keygen -t rsa -b 4096 -C "github-actions" -f ~/.ssh/github_actions -N ""

# Copy public key lên VPS
ssh-copy-id -i ~/.ssh/github_actions.pub root@62.171.131.164

# Xem private key (copy toàn bộ)
cat ~/.ssh/github_actions
```

**Lưu ý**: Copy toàn bộ output của private key (từ `-----BEGIN` đến `-----END`)

---

## 📋 Bước 2: Thêm GitHub Secrets (1 phút)

1. Vào GitHub repo → **Settings** → **Secrets and variables** → **Actions**
2. Thêm 5 secrets:

| Name | Value |
|------|-------|
| `DOCKER_USERNAME` | `huyde1626` |
| `DOCKER_PASSWORD` | (Password Docker Hub) |
| `VPS_HOST` | `62.171.131.164` |
| `VPS_USERNAME` | `root` |
| `VPS_SSH_KEY` | (Private key từ bước 1) |

---

## 📋 Bước 3: Tạo Workflow File (1 phút)

File đã có sẵn: `.github/workflows/deploy-vps.yml`

**Chỉ cần commit và push:**

```bash
git add .github/workflows/deploy-vps.yml
git commit -m "Add CI/CD pipeline"
git push origin main
```

---

## 📋 Bước 4: Kiểm tra Pipeline (1 phút)

1. Vào GitHub → Tab **Actions**
2. Bạn sẽ thấy workflow đang chạy
3. Đợi 2-3 phút để hoàn thành

**Kết quả**: ✅ Tất cả steps thành công!

---

## 📋 Bước 5: Test CI/CD

### Sửa code và push:

```bash
# Sửa file app.js (ví dụ: thêm dòng mới)
echo "// Updated by CI/CD" >> app.js

# Commit và push
git add app.js
git commit -m "Test CI/CD"
git push origin main
```

### Kiểm tra:

1. Vào **Actions** tab
2. Xem workflow mới chạy
3. Đợi hoàn thành
4. Kiểm tra VPS: Container đã được update!

---

## ✅ Hoàn thành!

Bây giờ mỗi khi push code:
- ✅ Tự động build image
- ✅ Tự động push lên Docker Hub
- ✅ Tự động deploy lên VPS
- ✅ Không cần làm gì thêm!

---

## 🔧 Tùy chỉnh

### Đổi port VPS:

Sửa trong `.github/workflows/deploy-vps.yml`:

```yaml
env:
  VPS_PORT: 3000  # Đổi thành port bạn muốn
```

### Chỉ deploy khi merge vào main:

Sửa trigger:

```yaml
on:
  push:
    branches: [ main ]
  # Xóa pull_request trigger
```

---

## 🆘 Troubleshooting

### Pipeline fail ở bước SSH:

- Kiểm tra SSH key đúng chưa
- Test SSH: `ssh -i ~/.ssh/github_actions root@62.171.131.164`

### Pipeline fail ở bước Docker login:

- Kiểm tra DOCKER_USERNAME và DOCKER_PASSWORD
- Test: `docker login` trên máy local

### Container không update:

- Kiểm tra logs trong GitHub Actions
- SSH vào VPS và kiểm tra: `docker ps`

---

**Xong! CI/CD đã sẵn sàng! 🚀**

