# Docker Deployment Guide for Kaitai Struct Web IDE

This guide explains how to build and deploy the Kaitai Struct Web IDE using Docker.

## Prerequisites

- Docker (version 20.10 or higher)
- Docker Compose (version 2.0 or higher) - optional, for easier management

## Quick Start

### Using Docker Compose (Recommended)

The easiest way to get started:

```bash
docker-compose up -d
```

Access the application at: http://localhost:8000

To stop the application:

```bash
docker-compose down
```

### Using Docker directly

Build the image:

```bash
docker build -t kaitai-webide .
```

Run the container:

```bash
docker run -d -p 8000:8000 --name kaitai-webide kaitai-webide
```

Access the application at: http://localhost:8000

## Deployment Options

### Option 1: Node.js Server (Default - Dockerfile)

This option uses Node.js with Express to serve the application.

**Pros:**
- Development server included
- Auto-refresh capability during development
- Dynamic route handling

**Cons:**
- Slightly larger image size
- More resource usage

**Build and run:**
```bash
docker build -t kaitai-webide .
docker run -d -p 8000:8000 --name kaitai-webide kaitai-webide
```

### Option 2: Nginx Server (Dockerfile.nginx)

This option uses nginx as a lightweight static file server.

**Pros:**
- Smaller image size
- Better performance for static files
- Production-ready with caching and compression
- Lower resource usage

**Cons:**
- No development features
- Static file serving only

**Build and run:**
```bash
docker build -f Dockerfile.nginx -t kaitai-webide-nginx .
docker run -d -p 8080:80 --name kaitai-webide-nginx kaitai-webide-nginx
```

Access at: http://localhost:8080

## Configuration

### Environment Variables

For the Node.js version (Dockerfile):

- `NODE_ENV`: Set to "production" for production deployment
- `SENTRY_DSN`: Sentry error tracking DSN (optional)
- `SENTRY_ENV`: Sentry environment name (optional)

Example:
```bash
docker run -d -p 8000:8000 \
  -e NODE_ENV=production \
  -e SENTRY_DSN=your-sentry-dsn \
  -e SENTRY_ENV=production \
  --name kaitai-webide \
  kaitai-webide
```

### Ports

- **Node.js version**: Port 8000 (can be mapped to any host port)
- **Nginx version**: Port 80 (can be mapped to any host port)

To use a different port:
```bash
docker run -d -p 3000:8000 --name kaitai-webide kaitai-webide
```

## Production Deployment

### Using Docker Compose with custom configuration

Create a `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  kaitai-webide:
    build:
      context: .
      dockerfile: Dockerfile.nginx
    ports:
      - "80:80"
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

Deploy:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Behind a Reverse Proxy (nginx/Traefik/Caddy)

When running behind a reverse proxy, you can use the internal network:

```yaml
version: '3.8'

services:
  kaitai-webide:
    build:
      context: .
      dockerfile: Dockerfile
    expose:
      - "8000"
    networks:
      - web
    restart: unless-stopped

networks:
  web:
    external: true
```

## Health Checks

Both Dockerfiles include health checks. To check the health status:

```bash
docker inspect --format='{{.State.Health.Status}}' kaitai-webide
```

## Troubleshooting

### Check logs

```bash
docker logs kaitai-webide
```

For continuous log monitoring:
```bash
docker logs -f kaitai-webide
```

### Access container shell

```bash
docker exec -it kaitai-webide sh
```

### Rebuild without cache

```bash
docker build --no-cache -t kaitai-webide .
```

### Check running processes

```bash
docker ps
```

### Check resource usage

```bash
docker stats kaitai-webide
```

## Advanced Usage

### Building for different architectures

Build for ARM (e.g., Raspberry Pi):
```bash
docker buildx build --platform linux/arm64 -t kaitai-webide:arm64 .
```

Build multi-platform image:
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t kaitai-webide:latest .
```

### Volume Mounts for Custom Files

Mount custom formats or samples:
```bash
docker run -d -p 8000:8000 \
  -v $(pwd)/my-formats:/app/formats \
  -v $(pwd)/my-samples:/app/samples \
  --name kaitai-webide \
  kaitai-webide
```

### Using with Docker Swarm

Create a stack file `kaitai-stack.yml`:

```yaml
version: '3.8'

services:
  kaitai-webide:
    image: kaitai-webide:latest
    ports:
      - "8000:8000"
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
      update_config:
        parallelism: 1
        delay: 10s
```

Deploy:
```bash
docker stack deploy -c kaitai-stack.yml kaitai
```

## Security Considerations

1. **Run as non-root**: Both Dockerfiles use non-root users where possible
2. **Update dependencies**: Regularly rebuild images to get security updates
3. **Use secrets**: For sensitive environment variables, use Docker secrets:
   ```bash
   echo "your-secret" | docker secret create sentry_dsn -
   ```

## Performance Optimization

### Build optimization

The Dockerfiles use multi-stage builds to minimize the final image size. The build stage includes all development dependencies, while the production stage only includes runtime dependencies.

### Runtime optimization

For the nginx version:
- Gzip compression is enabled
- Static assets are cached for 1 year
- HTML files are not cached to ensure updates are served

## Cleanup

Remove container:
```bash
docker rm -f kaitai-webide
```

Remove image:
```bash
docker rmi kaitai-webide
```

Remove all unused images and containers:
```bash
docker system prune -a
```

## Support

For issues related to:
- **Kaitai Struct Web IDE**: https://github.com/kaitai-io/kaitai_struct_webide/issues
- **Docker setup**: Check this guide or create an issue in the repository

## License

This Docker setup is part of the Kaitai Struct Web IDE project and follows the same GPL-3.0 license.

