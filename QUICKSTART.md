# 🚀 Quick Start Guide

Hướng dẫn nhanh để triển khai dự án trong 5 bước.

## Bước 1: Cấu hình AWS (5 phút)

```bash
# Cài đặt AWS CLI (nếu chưa có)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# Cấu hình credentials
aws configure
# Nhập: Access Key ID, Secret Access Key, Region (ví dụ: us-east-1)
```

## Bước 2: Tạo hạ tầng với Terraform (20 phút)

```bash
# Cài đặt Terraform (nếu chưa có)
# macOS: brew install terraform
# Linux: xem README.md

# Tạo hạ tầng
cd terraform
terraform init
terraform plan
terraform apply  # Nhập "yes"

# Lưu outputs
terraform output -json > ../terraform-outputs.json

# Cấu hình kubectl
aws eks update-kubeconfig --name simple-app-eks --region us-east-1
```

## Bước 3: Cấu hình GitHub Secrets (2 phút)

1. Vào GitHub repository → **Settings** → **Secrets and variables** → **Actions**
2. Thêm 2 secrets:
   - `AWS_ACCESS_KEY_ID`: AWS Access Key của bạn
   - `AWS_SECRET_ACCESS_KEY`: AWS Secret Key của bạn

## Bước 4: Push code và deploy tự động (5 phút)

```bash
# Push code lên GitHub
git add .
git commit -m "Initial deployment"
git push origin main

# GitHub Actions sẽ tự động:
# - Build Docker image
# - Push lên ECR
# - Deploy lên EKS
```

## Bước 5: Cài đặt Monitoring (5 phút)

```bash
# Deploy Prometheus và Grafana
kubectl apply -f monitoring/prometheus-deployment.yaml
kubectl apply -f monitoring/grafana-deployment.yaml

# Đợi LoadBalancer được tạo (2-3 phút)
kubectl get svc -n monitoring -w

# Lấy địa chỉ IP
PROMETHEUS_IP=$(kubectl get svc prometheus -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
GRAFANA_IP=$(kubectl get svc grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "Prometheus: http://$PROMETHEUS_IP:9090"
echo "Grafana: http://$GRAFANA_IP (admin/admin)"
```

## Kiểm tra deployment

```bash
# Kiểm tra pods
kubectl get pods -n production
kubectl get pods -n monitoring

# Kiểm tra services
kubectl get svc -n production
kubectl get svc -n monitoring

# Xem logs
kubectl logs -f deployment/nodejs-app -n production
```

## Truy cập ứng dụng

```bash
# Lấy địa chỉ LoadBalancer của ứng dụng
APP_IP=$(kubectl get svc nodejs-app-service -n production -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test
curl http://$APP_IP
curl http://$APP_IP/health
curl http://$APP_IP/metrics
```

## Sử dụng Makefile

```bash
# Xem tất cả lệnh
make help

# Các lệnh thường dùng
make terraform-init
make terraform-apply
make deploy-k8s
make deploy-monitoring
```

## Troubleshooting nhanh

### Lỗi: "Unable to connect to the server"
```bash
aws eks update-kubeconfig --name simple-app-eks --region us-east-1
```

### Lỗi: "ImagePullBackOff"
- Kiểm tra ECR repository đã được tạo
- Kiểm tra image đã được push lên ECR
- Cập nhật deployment.yaml với đúng image URL

### Lỗi: "Pod không start"
```bash
kubectl describe pod <pod-name> -n production
kubectl logs <pod-name> -n production
```

## Cleanup

```bash
# Xóa tất cả
make clean
cd terraform && terraform destroy
```

---

**Lưu ý**: Quá trình tạo EKS cluster mất khoảng 15-20 phút. Hãy kiên nhẫn! 😊

