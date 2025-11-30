#!/bin/bash

# Script push Docker image lên Docker Hub

set -e

# Màu sắc
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Kiểm tra tham số
if [ -z "$1" ]; then
    echo -e "${RED}❌ Usage: $0 <dockerhub-username> [version]${NC}"
    echo "Example: $0 myusername v1.0.0"
    exit 1
fi

DOCKER_USERNAME=$1
VERSION="${2:-latest}"
IMAGE_NAME="nodejs-app"
FULL_IMAGE_NAME="${DOCKER_USERNAME}/${IMAGE_NAME}"

echo -e "${YELLOW}🐳 Preparing to push image...${NC}"

# Kiểm tra đã login chưa
if ! docker info | grep -q "Username"; then
    echo -e "${YELLOW}Please login to Docker Hub first:${NC}"
    docker login
fi

# Tag image
echo -e "${YELLOW}Tagging image...${NC}"
docker tag ${IMAGE_NAME}:latest ${FULL_IMAGE_NAME}:${VERSION}
docker tag ${IMAGE_NAME}:latest ${FULL_IMAGE_NAME}:latest

# Push image
echo -e "${YELLOW}Pushing image to Docker Hub...${NC}"
docker push ${FULL_IMAGE_NAME}:${VERSION}
docker push ${FULL_IMAGE_NAME}:latest

echo ""
echo -e "${GREEN}✅ Image pushed successfully!${NC}"
echo ""
echo "Image URL: https://hub.docker.com/r/${FULL_IMAGE_NAME}"
echo ""
echo "To pull and run:"
echo "  docker pull ${FULL_IMAGE_NAME}:${VERSION}"
echo "  docker run -d -p 3000:3000 ${FULL_IMAGE_NAME}:${VERSION}"

