#!/bin/bash

# Script chạy trên VPS để update container
# Đặt file này trên VPS và chạy: ./vps-update.sh

set -e

# Màu sắc
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

IMAGE_NAME="${1:-huyde1626/nodejs-app:latest}"
CONTAINER_NAME="nodejs-app"
PORT=80

echo -e "${YELLOW}🔄 Updating container on VPS...${NC}"

# Kiểm tra Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not installed${NC}"
    exit 1
fi

# Pull image mới nhất
echo -e "${YELLOW}📥 Pulling latest image: ${IMAGE_NAME}${NC}"
docker pull ${IMAGE_NAME}

# Kiểm tra image có tồn tại không
if ! docker images | grep -q "$(echo ${IMAGE_NAME} | cut -d: -f1)"; then
    echo -e "${RED}❌ Failed to pull image${NC}"
    exit 1
fi

# Stop container cũ
echo -e "${YELLOW}🛑 Stopping old container...${NC}"
if docker ps -a | grep -q ${CONTAINER_NAME}; then
    docker stop ${CONTAINER_NAME} 2>/dev/null || true
    docker rm ${CONTAINER_NAME} 2>/dev/null || true
fi

# Start container mới
echo -e "${YELLOW}🚀 Starting new container...${NC}"
docker run -d \
  -p ${PORT}:3000 \
  --name ${CONTAINER_NAME} \
  --restart always \
  ${IMAGE_NAME}

# Đợi container start
sleep 3

# Kiểm tra container
if docker ps | grep -q ${CONTAINER_NAME}; then
    echo -e "${GREEN}✅ Container started successfully!${NC}"
    echo ""
    echo "Container info:"
    docker ps | grep ${CONTAINER_NAME}
    echo ""
    echo "Recent logs:"
    docker logs --tail 20 ${CONTAINER_NAME}
    echo ""
    echo "Health check:"
    sleep 2
    if curl -f http://localhost:${PORT}/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Health check passed!${NC}"
    else
        echo -e "${YELLOW}⚠️  Health check failed, but container is running${NC}"
    fi
else
    echo -e "${RED}❌ Container failed to start${NC}"
    echo "Check logs: docker logs ${CONTAINER_NAME}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Update complete!${NC}"

