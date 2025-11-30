#!/bin/bash

# Script deploy Docker container lên VPS

set -e

# Màu sắc
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Kiểm tra tham số
if [ -z "$1" ]; then
    echo -e "${RED}❌ Usage: $0 <dockerhub-username> [tag]${NC}"
    echo "Example: $0 huyde1626 latest"
    exit 1
fi

DOCKER_USERNAME=$1
TAG="${2:-latest}"
IMAGE_NAME="${DOCKER_USERNAME}/nodejs-app:${TAG}"
CONTAINER_NAME="nodejs-app"
PORT="${3:-80}"

echo -e "${YELLOW}🚀 Deploying container...${NC}"

# Kiểm tra Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker chưa được cài đặt${NC}"
    echo "Cài đặt: curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
    exit 1
fi

# Dừng container cũ nếu có
if docker ps -a | grep -q ${CONTAINER_NAME}; then
    echo -e "${YELLOW}Stopping old container...${NC}"
    docker stop ${CONTAINER_NAME} > /dev/null 2>&1
    docker rm ${CONTAINER_NAME} > /dev/null 2>&1
fi

# Pull image mới nhất
echo -e "${YELLOW}Pulling image: ${IMAGE_NAME}...${NC}"
docker pull ${IMAGE_NAME}

# Chạy container
echo -e "${YELLOW}Starting container...${NC}"
docker run -d \
  -p ${PORT}:3000 \
  --name ${CONTAINER_NAME} \
  --restart always \
  ${IMAGE_NAME}

# Đợi container start
sleep 3

# Kiểm tra container
if docker ps | grep -q ${CONTAINER_NAME}; then
    echo -e "${GREEN}✅ Container deployed successfully!${NC}"
    echo ""
    echo "Container info:"
    docker ps | grep ${CONTAINER_NAME}
    echo ""
    echo "Test:"
    echo "  curl http://localhost:${PORT}"
    echo ""
    echo "Logs:"
    echo "  docker logs -f ${CONTAINER_NAME}"
else
    echo -e "${RED}❌ Container failed to start${NC}"
    echo "Check logs: docker logs ${CONTAINER_NAME}"
    exit 1
fi

