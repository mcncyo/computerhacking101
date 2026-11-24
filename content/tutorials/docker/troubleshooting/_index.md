---
title: "Docker Troubleshooting Guide"
date: 2025-08-18
description: "Common Docker issues and how to solve them, including container, networking, and storage problems."
keywords: ["docker troubleshooting", "docker issues", "container errors", "docker logs", "debugging docker"]
tags: ["docker", "containers", "devops", "debugging"]
draft: false
---

Encountering issues with Docker? This guide covers common problems and their solutions to help you get back on track quickly.

## Common Issues and Solutions

### 1. Container Won't Start

**Symptoms:**
- Container exits immediately after starting
- `docker ps -a` shows Exited (1) status

**Solutions:**
```bash
# Check container logs
docker logs <container_id>

# Run container interactively to see errors
docker run -it <image> /bin/sh

# Check container exit code
docker inspect <container_id> --format='{{.State.ExitCode}}'
```

### 2. Port Already in Use

**Error:** `Bind for 0.0.0.0:80 failed: port is already allocated`

**Solutions:**
```bash
# Find the process using the port
sudo lsof -i :80

# Kill the process
kill <process_id>

# Or stop the container using the port
docker ps
docker stop <container_id>
```

### 3. Out of Memory Errors

**Error:** `Killed` or `OOMKilled` in container status

**Solutions:**
```bash
# Check container memory usage
docker stats

# Set memory limits in docker-compose.yml
services:
  app:
    mem_limit: 1g
    mem_reservation: 512m

# Or when running a container
docker run -m 1g --memory-reservation=512m <image>
```

### 4. Docker Daemon Not Running

**Error:** `Cannot connect to the Docker daemon`

**Solutions:**
```bash
# Start Docker service
sudo systemctl start docker

# Enable on boot
sudo systemctl enable docker

# Check status
sudo systemctl status docker
```

### 5. Permission Denied Errors

**Error:** `Got permission denied while trying to connect to the Docker daemon socket`

**Solutions:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes (log out and back in, or run:)
newgrp docker

# Or use sudo (not recommended for production)
sudo docker <command>
```

## Debugging Techniques

### View Container Logs
```bash
# Follow logs in real-time
docker logs -f <container_id>

# Show last N lines
docker logs --tail=100 <container_id>

# Show logs with timestamps
docker logs -t <container_id>
```

### Inspect Containers
```bash
# Show detailed container information
docker inspect <container_id>

# Check container processes
docker top <container_id>

# View container resource usage
docker stats
```

### Network Troubleshooting
```bash
# List networks
docker network ls

# Inspect a network
docker network inspect <network_name>

# Check container's network
docker exec -it <container_id> ip addr

# Test network connectivity between containers
docker run --rm --network=<network_name> \
  nicolaka/netshoot curl http://service-name:port
```

### Volume Issues
```bash
# List volumes
docker volume ls

# Inspect a volume
docker volume inspect <volume_name>

# Check volume contents
docker run --rm -v <volume_name>:/vol busybox ls -la /vol
```

## Common Docker Compose Issues

### 1. Environment Variables Not Loading

**Solution:**
```yaml
# In docker-compose.yml
services:
  app:
    env_file: .env
    environment:
      - ENV_VAR=${ENV_VAR}
```

### 2. Containers Not Starting in Correct Order

**Solution:**
```yaml
services:
  app:
    depends_on:
      - db
      - redis
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 40s
```

### 3. Build Context Too Large

**Solution:**
```dockerignore
# .dockerignore
.git
node_modules
*.log
.env
Dockerfile
.dockerignore
```

## Performance Issues

### Slow Builds
```bash
# Check build output for slow stages
docker build --progress=plain .

# Use BuildKit for better performance
export DOCKER_BUILDKIT=1
docker build .

# Use build cache from previous builds
docker build --cache-from <previous_image> .
```

### High Disk Usage
```bash
# Show disk usage
docker system df

# Remove unused containers, networks, images
docker system prune

# Remove all unused images
docker image prune -a

# Remove build cache
docker builder prune
```

## Windows-Specific Issues

### Volume Mounting Problems
- Use absolute paths with forward slashes: `C:/path/to/folder:/app`
- Enable shared drives in Docker Desktop settings
- Check for path case sensitivity

### Line Endings (CRLF vs LF)
```dockerfile
# Add to Dockerfile
RUN sed -i 's/\r$//' /entrypoint.sh \
    && chmod +x /entrypoint.sh
```

## Common Error Messages

### "No space left on device"
```bash
# Clean up unused data
docker system prune -a --volumes

# Check disk space
df -h /var/lib/docker
```

### "exec format error"
- Ensure the image architecture matches your host
- Rebuild the image for the correct platform:
  ```bash
  docker build --platform linux/amd64 .
  ```

### "port is already allocated"
```bash
# Find the process using the port
sudo lsof -i :<port>

# Or find the container
sudo docker ps | grep <port>
```

## Getting Help

### Enable Debug Mode
```bash
# Edit docker daemon config
sudo nano /etc/docker/daemon.json

# Add these lines
{
  "debug": true,
  "log-level": "debug"
}

# Restart docker
sudo systemctl restart docker
```

### Check Docker Logs
```bash
# On Linux
journalctl -u docker.service

# On macOS
~/Library/Containers/com.docker.docker/Data/log/vm/dockerd.log
```

## Next Steps

- [Docker Compose Guide](/tutorials/docker/docker-compose/)
- [Dockerfile Best Practices](/tutorials/docker/dockerfile-best-practices/)
- [Docker Security Guide](/tutorials/security/docker/)

{{< button "Back to Docker Tutorials" "/tutorials/docker/" >}}
