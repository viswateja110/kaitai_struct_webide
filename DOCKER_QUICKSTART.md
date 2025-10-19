# Docker Quick Start Guide

## 🚀 Fastest Way to Deploy

### Using Docker Compose (Recommended)
```bash
docker-compose up -d
```
**Access:** http://localhost:8000

### Using Make commands
```bash
make build
make run
```
**Access:** http://localhost:8000

---

## 📋 Common Commands

### Docker Compose Commands
| Command | Description |
|---------|-------------|
| `docker-compose up -d` | Start in background |
| `docker-compose up` | Start with logs |
| `docker-compose down` | Stop and remove |
| `docker-compose logs -f` | View logs |
| `docker-compose restart` | Restart services |

### Make Commands  
| Command | Description |
|---------|-------------|
| `make help` | Show all available commands |
| `make build` | Build Node.js version |
| `make build-nginx` | Build nginx version |
| `make run` | Run Node.js version (port 8000) |
| `make run-nginx` | Run nginx version (port 8080) |
| `make logs` | View logs |
| `make clean` | Stop and remove containers |

### Direct Docker Commands
| Command | Description |
|---------|-------------|
| `docker build -t kaitai-webide .` | Build image |
| `docker run -d -p 8000:8000 kaitai-webide` | Run container |
| `docker ps` | List running containers |
| `docker logs -f kaitai-webide` | View logs |
| `docker stop kaitai-webide` | Stop container |

---

## 🔧 Two Deployment Options

### Option 1: Node.js (Default)
- **File:** `Dockerfile`
- **Port:** 8000
- **Use case:** Development and production
- **Start:** `docker-compose up -d`

### Option 2: Nginx (Lightweight)
- **File:** `Dockerfile.nginx`  
- **Port:** 80 (mapped to 8080)
- **Use case:** Production static hosting
- **Start:** `docker-compose -f docker-compose.nginx.yml up -d`

---

## 🆘 Troubleshooting

### View Logs
```bash
docker logs kaitai-webide
# or
docker-compose logs -f
```

### Check Health
```bash
docker inspect --format='{{.State.Health.Status}}' kaitai-webide
```

### Rebuild from Scratch
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Container Won't Start
1. Check port is not in use: `netstat -an | grep 8000`
2. Check Docker daemon is running
3. View error logs: `docker logs kaitai-webide`

---

## 📊 Verify Deployment

After starting, check:
1. **Container is running:** `docker ps`
2. **Health check passes:** `make health`
3. **Application loads:** Open http://localhost:8000 in browser

---

## 🧹 Cleanup

### Stop containers
```bash
make stop
# or
docker-compose down
```

### Remove everything (containers + images)
```bash
make docker-clean
# or
docker-compose down --rmi all
```

---

## 📚 More Information

For detailed documentation, see [DOCKER.md](DOCKER.md)

