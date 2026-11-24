---
title: "Docker Compose: Multi-Container Applications"
date: 2025-08-18
description: "Learn how to define and run multi-container Docker applications with Docker Compose, including networking, volumes, and environment configuration."
keywords: ["docker compose", "docker-compose", "multi-container", "container orchestration", "docker networking"]
tags: ["docker", "containers", "devops", "deployment"]
draft: false
---

## Docker Compose: Simplifying Multi-Container Applications

Docker Compose is a tool for defining and running multi-container Docker applications. With a single `docker-compose.yml` file, you can configure all your application's services, networks, and volumes, then start everything with a single command.

## Why Use Docker Compose?

- **Single Command Setup**: Start all services with `docker-compose up`
- **Isolated Environments**: Each service runs in its own container
- **Reproducible Builds**: Configurations are version controlled
- **Service Dependencies**: Define and manage service relationships
- **Development/Production Parity**: Use the same configuration across environments

## Getting Started

### Installation

Docker Compose is included with Docker Desktop for Windows and macOS. For Linux, you may need to install it separately:

```bash
# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
```

### Basic Example: Web Application with Redis

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - .:/code
    environment:
      FLASK_ENV: development
    depends_on:
      - redis

  redis:
    image: "redis:alpine"
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"

volumes:
  redis_data:
```

### Common Commands

```bash
# Start services in detached mode
docker-compose up -d

# View running services
docker-compose ps

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild containers
docker-compose build

# Run a one-off command
docker-compose run web python manage.py test
```

## Key Concepts

### Services

Each service runs in its own container and can be configured with:
- Build context and Dockerfile
- Port mappings
- Volume mounts
- Environment variables
- Dependencies
- Resource limits

### Networks

Docker Compose creates a default network for your services. You can also define custom networks:

```yaml
networks:
  app_network:
    driver: bridge
    driver_opts:
      encrypted: "yes"
```

### Volumes

Persist data between container restarts:

```yaml
volumes:
  db_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /path/on/host
```

## Advanced Features

### Environment Variables

Use `.env` files for environment-specific configurations:

```env
# .env
DB_USER=admin
DB_PASS=secret
```

Reference in `docker-compose.yml`:

```yaml
environment:
  - DB_USER=${DB_USER}
  - DB_PASS=${DB_PASS}
```

### Health Checks

```yaml
services:
  web:
    # ...
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### Multiple Compose Files

Use different files for different environments:

```bash
# Base configuration
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Production Best Practices

1. **Use Specific Image Tags**: Avoid `latest` in production
2. **Resource Limits**: Set CPU and memory constraints
3. **Restart Policies**: Configure appropriate restart behavior
4. **Secrets Management**: Use Docker secrets or environment files
5. **Logging**: Configure log rotation and collection
6. **Networking**: Use custom networks and proper security groups
7. **Updates**: Implement a rolling update strategy

## Example: Full-Stack Application

```yaml
version: '3.8'

services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - API_URL=/api
    depends_on:
      - api

  api:
    build: ./api
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/app
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis

  db:
    image: postgres:13
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=app
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d app"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:6
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - frontend
      - api

volumes:
  postgres_data:
  redis_data:
```

## Monitoring and Maintenance

```bash
# View resource usage
docker stats

# View container metrics
docker-compose top

# List volumes
docker volume ls

# Clean up unused resources
docker system prune
```

## Next Steps

- [Dockerfile Best Practices](/tutorials/docker/dockerfile-best-practices/)
- [Docker Networking](/tutorials/docker/networking/)
- [Docker Security](/tutorials/security/docker/)
- [Kubernetes for Production](/tutorials/kubernetes/)

{{< button "Back to Docker Tutorials" "/tutorials/docker/" >}}
