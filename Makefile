.PHONY: help install test build docker-build docker-test docker-push docker-run terraform-init terraform-plan terraform-apply terraform-destroy deploy-monitoring clean

help: ## Hiển thị help message
	@echo "Các lệnh có sẵn:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Cài đặt dependencies Node.js
	npm install

test: ## Chạy ứng dụng local để test
	npm start

build: ## Build Docker image
	docker build -t nodejs-app:latest .

docker-build: ## Build và test Docker image
	./scripts/docker-build.sh

docker-test: ## Test Docker image local
	./scripts/docker-build.sh

docker-push: ## Push Docker image lên Docker Hub (usage: make docker-push USERNAME=yourname VERSION=v1.0.0)
	@if [ -z "$(USERNAME)" ]; then \
		echo "❌ Usage: make docker-push USERNAME=yourname [VERSION=v1.0.0]"; \
		exit 1; \
	fi
	./scripts/docker-push.sh $(USERNAME) $(VERSION)

docker-run: ## Chạy Docker container
	docker run -p 3000:3000 nodejs-app:latest

update-vps: ## Update VPS từ local (usage: make update-vps VPS_IP=192.168.1.100 VPS_USER=root)
	@if [ -z "$(VPS_IP)" ]; then \
		echo "❌ Usage: make update-vps VPS_IP=your-ip [VPS_USER=root] [VERSION=latest]"; \
		exit 1; \
	fi
	./scripts/update-vps.sh $(VPS_IP) $(VPS_USER) $(VERSION)

terraform-init: ## Khởi tạo Terraform
	cd terraform && terraform init

terraform-plan: ## Xem kế hoạch Terraform
	cd terraform && terraform plan

terraform-apply: ## Tạo hạ tầng với Terraform
	cd terraform && terraform apply

terraform-destroy: ## Xóa hạ tầng Terraform
	cd terraform && terraform destroy

deploy-k8s: ## Deploy ứng dụng lên Kubernetes
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/deployment.yaml
	kubectl apply -f k8s/service.yaml
	kubectl apply -f k8s/service-monitor.yaml

deploy-monitoring: ## Deploy Prometheus và Grafana
	kubectl apply -f monitoring/prometheus-deployment.yaml
	kubectl apply -f monitoring/grafana-deployment.yaml

clean: ## Xóa tất cả Kubernetes resources
	kubectl delete -f k8s/ || true
	kubectl delete -f monitoring/ || true

