#!/bin/bash

# Script deploy tự động
set -e

echo "🚀 Bắt đầu deploy..."

# Màu sắc
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Kiểm tra kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl chưa được cài đặt"
    exit 1
fi

# Kiểm tra kết nối cluster
echo -e "${YELLOW}Kiểm tra kết nối Kubernetes cluster...${NC}"
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Không thể kết nối đến cluster. Hãy chạy:"
    echo "   aws eks update-kubeconfig --name simple-app-eks --region us-east-1"
    exit 1
fi

echo -e "${GREEN}✓ Kết nối cluster thành công${NC}"

# Deploy namespace
echo -e "${YELLOW}Deploy namespace...${NC}"
kubectl apply -f k8s/namespace.yaml

# Deploy application
echo -e "${YELLOW}Deploy ứng dụng...${NC}"
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/service-monitor.yaml

# Đợi deployment ready
echo -e "${YELLOW}Đợi deployment sẵn sàng...${NC}"
kubectl rollout status deployment/nodejs-app -n production --timeout=300s

echo -e "${GREEN}✓ Deploy thành công!${NC}"

# Hiển thị thông tin
echo ""
echo "📊 Thông tin deployment:"
kubectl get pods -n production
kubectl get svc -n production

echo ""
echo "🌐 Để xem logs:"
echo "   kubectl logs -f deployment/nodejs-app -n production"

