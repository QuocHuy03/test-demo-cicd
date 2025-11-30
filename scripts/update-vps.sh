#!/bin/bash

# Script update VPS từ local
# Usage: ./update-vps.sh [vps-ip] [vps-user]

set -e

# Màu sắc
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Tham số
VPS_IP="${1:-your-vps-ip}"
VPS_USER="${2:-root}"
IMAGE_NAME="huyde1626/nodejs-app"
CONTAINER_NAME="nodejs-app"
VERSION="${3:-latest}"

echo -e "${YELLOW}🔄 Updating VPS: ${VPS_IP}${NC}"

# Kiểm tra tham số
if [ "$VPS_IP" = "your-vps-ip" ]; then
    echo -e "${RED}❌ Usage: $0 <vps-ip> [vps-user] [version]${NC}"
    echo "Example: $0 192.168.1.100 root latest"
    exit 1
fi

# Bước 1: Build image mới
echo -e "${YELLOW}📦 Building new image...${NC}"
docker build -t ${IMAGE_NAME}:${VERSION} .
docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest

# Bước 2: Push lên Docker Hub
echo -e "${YELLOW}📤 Pushing to Docker Hub...${NC}"
docker push ${IMAGE_NAME}:${VERSION}
docker push ${IMAGE_NAME}:latest

# Bước 3: Deploy lên VPS
echo -e "${YELLOW}🚀 Deploying to VPS...${NC}"
ssh ${VPS_USER}@${VPS_IP} << ENDSSH
  set -e
  echo "📥 Pulling latest image..."
  docker pull ${IMAGE_NAME}:latest
  
  echo "🛑 Stopping old container..."
  docker stop ${CONTAINER_NAME} 2>/dev/null || true
  docker rm ${CONTAINER_NAME} 2>/dev/null || true
  
  echo "🚀 Starting new container..."
  docker run -d \
    -p 80:3000 \
    --name ${CONTAINER_NAME} \
    --restart always \
    ${IMAGE_NAME}:latest
  
  echo "⏳ Waiting for container to start..."
  sleep 3
  
  echo "📋 Container status:"
  docker ps | grep ${CONTAINER_NAME} || echo "Container not running!"
  
  echo "📝 Recent logs:"
  docker logs --tail 10 ${CONTAINER_NAME}
ENDSSH

echo ""
echo -e "${GREEN}✅ Update complete!${NC}"
echo ""
echo "Test your app:"
echo "  curl http://${VPS_IP}"
echo ""
echo "View logs:"
echo "  ssh ${VPS_USER}@${VPS_IP} 'docker logs -f ${CONTAINER_NAME}'"

