#!/bin/bash

# Script setup monitoring
set -e

echo "📊 Bắt đầu setup monitoring..."

# Màu sắc
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Kiểm tra kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl chưa được cài đặt"
    exit 1
fi

# Deploy Prometheus
echo -e "${YELLOW}Deploy Prometheus...${NC}"
kubectl apply -f monitoring/prometheus-deployment.yaml

# Deploy Grafana
echo -e "${YELLOW}Deploy Grafana...${NC}"
kubectl apply -f monitoring/grafana-deployment.yaml

# Đợi services ready
echo -e "${YELLOW}Đợi services sẵn sàng (có thể mất 2-3 phút)...${NC}"
sleep 10

# Kiểm tra status
echo ""
echo -e "${GREEN}📊 Monitoring services:${NC}"
kubectl get svc -n monitoring

echo ""
echo -e "${YELLOW}Đợi LoadBalancer được tạo...${NC}"
echo "   (Có thể mất 2-3 phút)"

# Lấy địa chỉ IP
echo ""
echo "🔍 Để lấy địa chỉ IP:"
echo "   kubectl get svc prometheus -n monitoring"
echo "   kubectl get svc grafana -n monitoring"
echo ""
echo "📝 Hoặc chạy:"
echo "   PROMETHEUS_IP=\$(kubectl get svc prometheus -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "   GRAFANA_IP=\$(kubectl get svc grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "   echo \"Prometheus: http://\$PROMETHEUS_IP:9090\""
echo "   echo \"Grafana: http://\$GRAFANA_IP (admin/admin)\""

