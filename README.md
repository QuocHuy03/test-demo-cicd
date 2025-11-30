# CI/CD Pipeline với Docker, Kubernetes, Terraform và Monitoring

Dự án tutorial đơn giản để học cách triển khai ứng dụng Node.js lên AWS EKS với CI/CD pipeline tự động và giám sát bằng Prometheus + Grafana.

## 🚀 Bắt đầu nhanh

**Mới bắt đầu?** Hãy làm theo từng tutorial:

1. **[Tutorial 01: Docker + CI/CD](TUTORIAL-01-DOCKER-CICD.md)** ← Bắt đầu từ đây!
2. [Tutorial 02: Kubernetes Local](TUTORIAL-INDEX.md) (sẽ tạo sau)
3. [Tutorial 03: AWS EKS](TUTORIAL-INDEX.md) (sẽ tạo sau)
4. [Tutorial 04: CI/CD hoàn chỉnh](TUTORIAL-INDEX.md) (sẽ tạo sau)
5. [Tutorial 05: Monitoring](TUTORIAL-INDEX.md) (sẽ tạo sau)

👉 **[Xem mục lục đầy đủ](TUTORIAL-INDEX.md)**

## 📋 Mục lục

1. [Tổng quan](#tổng-quan)
2. [Kiến trúc](#kiến-trúc)
3. [Yêu cầu](#yêu-cầu)
4. [Hướng dẫn triển khai](#hướng-dẫn-triển-khai)
5. [Cấu trúc dự án](#cấu-trúc-dự-án)

## 🎯 Tổng quan

Dự án này bao gồm:
- **Ứng dụng Node.js** đơn giản với Express
- **Docker** containerization
- **Kubernetes** deployment trên AWS EKS
- **Terraform** để tạo hạ tầng tự động
- **CI/CD Pipeline** với GitHub Actions
- **Monitoring** với Prometheus và Grafana

## 🏗️ Kiến trúc

```
GitHub → GitHub Actions → ECR → EKS → Prometheus → Grafana
         (CI/CD)         (Docker)  (K8s)  (Metrics)  (Dashboard)
```

## 📦 Yêu cầu

### Công cụ cần cài đặt:

1. **AWS CLI**
   ```bash
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   ```

2. **Terraform**
   ```bash
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

3. **kubectl**
   ```bash
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
   ```

4. **eksctl** (tùy chọn, để quản lý EKS)
   ```bash
   curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
   sudo mv /tmp/eksctl /usr/local/bin
   ```

5. **Docker**
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install docker.io
   ```

6. **Node.js** (để test local)
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

## 🚀 Hướng dẫn triển khai

### Bước 1: Cấu hình AWS

1. Tạo AWS account và IAM user với quyền:
   - EKS Full Access
   - ECR Full Access
   - EC2 Full Access
   - VPC Full Access
   - IAM (để tạo roles)

2. Cấu hình AWS credentials:
   ```bash
   aws configure
   # Nhập: AWS Access Key ID, Secret Access Key, Region
   ```

3. Tạo S3 bucket cho Terraform state (tùy chọn):
   ```bash
   aws s3 mb s3://your-terraform-state-bucket
   ```

### Bước 2: Tạo hạ tầng với Terraform

1. Di chuyển vào thư mục terraform:
   ```bash
   cd terraform
   ```

2. Khởi tạo Terraform:
   ```bash
   terraform init
   ```

3. Xem kế hoạch triển khai:
   ```bash
   terraform plan
   ```

4. Tạo hạ tầng:
   ```bash
   terraform apply
   # Nhập "yes" để xác nhận
   ```

   **Lưu ý:** Quá trình này mất khoảng 15-20 phút để tạo EKS cluster.

5. Lưu outputs:
   ```bash
   terraform output -json > ../terraform-outputs.json
   ```

6. Cấu hình kubectl:
   ```bash
   aws eks update-kubeconfig --name simple-app-eks --region us-east-1
   ```

### Bước 3: Cấu hình GitHub Secrets

Vào GitHub repository → Settings → Secrets and variables → Actions, thêm:

- `AWS_ACCESS_KEY_ID`: AWS Access Key
- `AWS_SECRET_ACCESS_KEY`: AWS Secret Key

### Bước 4: Cập nhật CI/CD Pipeline

1. Mở file `.github/workflows/ci-cd.yml`
2. Cập nhật các biến môi trường nếu cần:
   - `AWS_REGION`
   - `ECR_REPOSITORY`
   - `EKS_CLUSTER_NAME`

### Bước 5: Deploy ứng dụng

1. Push code lên GitHub:
   ```bash
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

2. GitHub Actions sẽ tự động:
   - Build Docker image
   - Push lên ECR
   - Deploy lên EKS

3. Kiểm tra deployment:
   ```bash
   kubectl get pods -n production
   kubectl get services -n production
   ```

### Bước 6: Cài đặt Monitoring

1. Deploy Prometheus:
   ```bash
   kubectl apply -f monitoring/prometheus-deployment.yaml
   ```

2. Deploy Grafana:
   ```bash
   kubectl apply -f monitoring/grafana-deployment.yaml
   ```

3. Lấy địa chỉ LoadBalancer:
   ```bash
   # Prometheus
   kubectl get svc prometheus -n monitoring
   
   # Grafana
   kubectl get svc grafana -n monitoring
   ```

4. Truy cập:
   - **Prometheus**: `http://<prometheus-loadbalancer-ip>:9090`
   - **Grafana**: `http://<grafana-loadbalancer-ip>` (admin/admin)

### Bước 7: Cấu hình Grafana Dashboard

1. Đăng nhập Grafana với admin/admin
2. Vào Configuration → Data Sources
3. Thêm Prometheus data source:
   - URL: `http://prometheus:9090`
   - Save & Test

4. Tạo dashboard mới hoặc import dashboard có sẵn:
   - Dashboard ID: 6417 (Node Exporter Full)
   - Hoặc tạo dashboard tùy chỉnh với metrics từ `/metrics` endpoint

## 📁 Cấu trúc dự án

```
.
├── app.js                          # Ứng dụng Node.js chính
├── package.json                    # Dependencies Node.js
├── Dockerfile                      # Docker image definition
├── .dockerignore                  # Files to ignore khi build Docker
├── .gitignore                     # Git ignore file
├── README.md                       # File này
│
├── k8s/                           # Kubernetes manifests
│   ├── namespace.yaml             # Namespace definition
│   ├── deployment.yaml            # Deployment cho ứng dụng
│   ├── service.yaml               # Service để expose ứng dụng
│   └── service-monitor.yaml       # ServiceMonitor cho Prometheus
│
├── terraform/                     # Terraform infrastructure
│   ├── main.tf                    # Main Terraform config
│   ├── variables.tf               # Variables
│   ├── outputs.tf                 # Outputs
│   └── .gitignore                 # Terraform ignore
│
├── monitoring/                    # Monitoring setup
│   ├── prometheus-deployment.yaml # Prometheus deployment
│   └── grafana-deployment.yaml    # Grafana deployment
│
└── .github/
    └── workflows/
        └── ci-cd.yml              # GitHub Actions CI/CD pipeline
```

## 🧪 Test ứng dụng local

1. Cài đặt dependencies:
   ```bash
   npm install
   ```

2. Chạy ứng dụng:
   ```bash
   npm start
   ```

3. Test endpoints:
   ```bash
   curl http://localhost:3000
   curl http://localhost:3000/health
   curl http://localhost:3000/metrics
   ```

## 🐳 Build và test Docker image

1. Build image:
   ```bash
   docker build -t nodejs-app:latest .
   ```

2. Chạy container:
   ```bash
   docker run -p 3000:3000 nodejs-app:latest
   ```

3. Test:
   ```bash
   curl http://localhost:3000
   ```

## 📊 Monitoring

### Metrics có sẵn

Ứng dụng expose metrics tại `/metrics` endpoint:
- `http_requests_total`: Tổng số HTTP requests
- `http_request_duration_seconds`: Thời gian xử lý requests

### Prometheus Queries

```promql
# Tổng số requests
sum(http_requests_total)

# Requests per second
rate(http_requests_total[5m])

# Request duration
histogram_quantile(0.95, http_request_duration_seconds_bucket)
```

## 🔧 Troubleshooting

### Lỗi khi deploy lên EKS

1. Kiểm tra kết nối:
   ```bash
   kubectl cluster-info
   ```

2. Kiểm tra pods:
   ```bash
   kubectl get pods -A
   kubectl describe pod <pod-name> -n production
   kubectl logs <pod-name> -n production
   ```

### Lỗi CI/CD Pipeline

1. Kiểm tra GitHub Actions logs
2. Xác nhận AWS credentials đúng
3. Kiểm tra ECR repository đã được tạo
4. Xác nhận EKS cluster name đúng

### Lỗi Terraform

1. Kiểm tra AWS credentials:
   ```bash
   aws sts get-caller-identity
   ```

2. Xem logs chi tiết:
   ```bash
   terraform apply -debug
   ```

## 💰 Chi phí AWS (ước tính)

- **EKS Cluster**: ~$0.10/giờ (~$73/tháng)
- **EC2 t3.medium instances** (2 nodes): ~$0.0416/giờ mỗi node (~$60/tháng)
- **NAT Gateway**: ~$0.045/giờ (~$32/tháng)
- **Load Balancer**: ~$0.0225/giờ (~$16/tháng)
- **ECR Storage**: ~$0.10/GB/tháng

**Tổng ước tính**: ~$200-250/tháng (có thể giảm bằng cách dùng spot instances)

## 🧹 Cleanup

Để xóa tất cả resources:

```bash
# Xóa Kubernetes resources
kubectl delete -f monitoring/
kubectl delete -f k8s/

# Xóa Terraform infrastructure
cd terraform
terraform destroy
```

## 📚 Tài liệu tham khảo

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)

## 📝 License

MIT

---

**Lưu ý**: Đây là dự án tutorial đơn giản. Trong môi trường production, cần:
- Bảo mật tốt hơn (secrets management, RBAC)
- Backup và disaster recovery
- Auto-scaling policies
- Logging tập trung (ELK stack)
- SSL/TLS certificates
- Network policies
- Resource quotas và limits

