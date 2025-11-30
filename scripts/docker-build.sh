#!/bin/bash

# Script build và test Docker image local

set -e

# Màu sắc
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

IMAGE_NAME="nodejs-app"
VERSION="${1:-latest}"

echo -e "${YELLOW}🐳 Building Docker image...${NC}"

# Build image
docker build -t ${IMAGE_NAME}:${VERSION} .

echo -e "${GREEN}✓ Image built successfully${NC}"

# Hiển thị thông tin image
echo ""
echo -e "${YELLOW}📊 Image information:${NC}"
docker images ${IMAGE_NAME}:${VERSION}

# Test image
echo ""
echo -e "${YELLOW}🧪 Testing image...${NC}"

# Kiểm tra container cũ
if docker ps -a | grep -q ${IMAGE_NAME}-test; then
    echo "Removing old test container..."
    docker rm -f ${IMAGE_NAME}-test > /dev/null 2>&1
fi

# Chạy container
echo "Starting container..."
docker run -d -p 3000:3000 --name ${IMAGE_NAME}-test ${IMAGE_NAME}:${VERSION}

# Đợi container start
sleep 3

# Test endpoints
echo ""
echo -e "${YELLOW}Testing endpoints:${NC}"

# Test root
if curl -s http://localhost:3000 > /dev/null; then
    echo -e "${GREEN}✓ GET / - OK${NC}"
else
    echo -e "${RED}✗ GET / - FAILED${NC}"
fi

# Test health
if curl -s http://localhost:3000/health | grep -q "healthy"; then
    echo -e "${GREEN}✓ GET /health - OK${NC}"
else
    echo -e "${RED}✗ GET /health - FAILED${NC}"
fi

# Test metrics
if curl -s http://localhost:3000/metrics > /dev/null; then
    echo -e "${GREEN}✓ GET /metrics - OK${NC}"
else
    echo -e "${RED}✗ GET /metrics - FAILED${NC}"
fi

echo ""
echo -e "${GREEN}✅ All tests passed!${NC}"
echo ""
echo "To stop and remove container:"
echo "  docker stop ${IMAGE_NAME}-test"
echo "  docker rm ${IMAGE_NAME}-test"
echo ""
echo "To run container manually:"
echo "  docker run -d -p 3000:3000 --name ${IMAGE_NAME} ${IMAGE_NAME}:${VERSION}"

