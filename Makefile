.PHONY: help build build-nginx run run-nginx stop stop-nginx logs clean docker-clean

# Default target
help:
	@echo "Kaitai Struct Web IDE - Docker Commands"
	@echo ""
	@echo "Available targets:"
	@echo "  build         - Build Docker image with Node.js server"
	@echo "  build-nginx   - Build Docker image with nginx server"
	@echo "  run           - Run container with Node.js server (port 8000)"
	@echo "  run-nginx     - Run container with nginx server (port 8080)"
	@echo "  stop          - Stop Node.js container"
	@echo "  stop-nginx    - Stop nginx container"
	@echo "  logs          - Show logs from Node.js container"
	@echo "  logs-nginx    - Show logs from nginx container"
	@echo "  clean         - Stop and remove containers"
	@echo "  docker-clean  - Remove containers and images"
	@echo "  compose-up    - Start services using docker-compose (Node.js)"
	@echo "  compose-up-nginx - Start services using docker-compose (nginx)"
	@echo "  compose-down  - Stop docker-compose services"
	@echo ""

# Build Docker images
build:
	docker build -t kaitai-webide:latest .

build-nginx:
	docker build -f Dockerfile.nginx -t kaitai-webide-nginx:latest .

# Run containers
run:
	docker run -d -p 8000:8000 --name kaitai-webide kaitai-webide:latest
	@echo "Kaitai Web IDE is running at http://localhost:8000"

run-nginx:
	docker run -d -p 8080:80 --name kaitai-webide-nginx kaitai-webide-nginx:latest
	@echo "Kaitai Web IDE is running at http://localhost:8080"

# Stop containers
stop:
	docker stop kaitai-webide || true

stop-nginx:
	docker stop kaitai-webide-nginx || true

# View logs
logs:
	docker logs -f kaitai-webide

logs-nginx:
	docker logs -f kaitai-webide-nginx

# Clean up
clean:
	docker stop kaitai-webide kaitai-webide-nginx || true
	docker rm kaitai-webide kaitai-webide-nginx || true

docker-clean: clean
	docker rmi kaitai-webide:latest kaitai-webide-nginx:latest || true

# Docker Compose commands
compose-up:
	docker-compose up -d
	@echo "Kaitai Web IDE is running at http://localhost:8000"

compose-up-nginx:
	docker-compose -f docker-compose.nginx.yml up -d
	@echo "Kaitai Web IDE is running at http://localhost:8080"

compose-down:
	docker-compose down
	docker-compose -f docker-compose.nginx.yml down || true

# Development commands
dev-build-run: build run

dev-build-run-nginx: build-nginx run-nginx

# Health check
health:
	@echo "Checking Node.js container health..."
	@docker inspect --format='{{.State.Health.Status}}' kaitai-webide 2>/dev/null || echo "Container not running"

health-nginx:
	@echo "Checking nginx container health..."
	@docker inspect --format='{{.State.Health.Status}}' kaitai-webide-nginx 2>/dev/null || echo "Container not running"

