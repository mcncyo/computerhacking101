---
title: "Dockerfile Best Practices"
date: 2025-08-18
description: "Learn the best practices for writing secure, efficient, and maintainable Dockerfiles to optimize your container images."
keywords: ["dockerfile", "best practices", "container security", "image optimization", "docker build"]
tags: ["docker", "containers", "devops", "security"]
draft: false
---

# Dockerfile Best Practices

Writing efficient and secure Dockerfiles is crucial for building production-ready container images. This guide covers the best practices to follow when creating Dockerfiles.

## 1. Use Official Base Images

```dockerfile
# Good
FROM node:18-alpine

# Avoid
FROM ubuntu:latest
```

**Why?**
- Official images are regularly updated and scanned for vulnerabilities
- Alpine-based images are smaller and more secure
- Specific version tags ensure reproducibility

## 2. Multi-Stage Builds

```dockerfile
# Build stage
FROM node:18 AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine
WORKDIR /app
COPY --from=build /app/package*.json ./
COPY --from=build /app/dist ./dist
RUN npm ci --only=production

EXPOSE 3000
CMD ["node", "dist/main.js"]
```

**Benefits:**
- Smaller final image size
- No build tools in production
- Better security with fewer attack surfaces

## 3. Leverage Build Cache

```dockerfile
# Bad - invalidates cache on any file change
COPY . .
RUN npm install

# Good - leverages layer caching
COPY package*.json ./
RUN npm install
COPY . .
```

**Cache Invalidation Rules:**
- Docker caches each layer
- Changes to any layer invalidates all subsequent layers
- Order commands from least to most frequently changing

## 4. Use .dockerignore

```
# .dockerignore
node_modules
npm-debug.log
Dockerfile
.dockerignore
.git
.gitignore
.env
```

**Why?**
- Faster builds by excluding unnecessary files
- Prevents sensitive data from being included
- Smaller image sizes

## 5. Security Best Practices

### Run as Non-Root User

```dockerfile
# Create app directory
WORKDIR /app

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set ownership
RUN chown -R appuser:appgroup /app
USER appuser

# Copy and run as non-root
COPY --chown=appuser:appgroup . .
```

### Scan for Vulnerabilities

```bash
# Install Docker Scan
docker scan --version

# Scan an image
docker scan your-image-name
```

### Update Packages

```dockerfile
# For Debian/Ubuntu
RUN apt-get update && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# For Alpine
RUN apk --no-cache upgrade
```

## 6. Optimize Layers

### Combine Commands

```dockerfile
# Bad - creates multiple layers
RUN apt-get update
RUN apt-get install -y python
RUN rm -rf /var/lib/apt/lists/*

# Good - single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 && \
    rm -rf /var/lib/apt/lists/*
```

### Clean Up in Same Layer

```dockerfile
# Bad - cleanup in separate layer doesn't reduce image size
RUN apt-get update && apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*

# Good - cleanup in same layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*
```

## 7. Use Specific Tags

```dockerfile
# Good - specific version
FROM node:18.16.0-alpine3.17

# Avoid - latest can change unexpectedly
FROM node:latest
```

## 8. Health Checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/health || exit 1
```

## 9. Use Labels for Metadata

```dockerfile
LABEL maintainer="Your Name <email@example.com>"
LABEL version="1.0"
LABEL description="My awesome application"
```

## 10. Set Environment Variables

```dockerfile
# Good - one per line for readability
ENV NODE_ENV=production \
    PORT=3000 \
    API_URL=https://api.example.com

# Default values can be overridden at runtime
docker run -e PORT=4000 your-image
```

## 11. Use COPY Instead of ADD

```dockerfile
# Good - use COPY for local files
COPY ./app /app

# Only use ADD for remote URLs or tar extraction
ADD https://example.com/file.tar.gz /tmp/
```

## 12. Set Working Directory

```dockerfile
# Set working directory early
WORKDIR /app

# All subsequent commands will be relative to /app
COPY package.json .
```

## 13. Use Shell Form for CMD and ENTRYPOINT

```dockerfile
# Use JSON array syntax to avoid shell processing issues
CMD ["npm", "start"]

# For complex commands, use a shell script
COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
```

## 14. Optimize for BuildKit

```bash
# Enable BuildKit in Docker (Docker 18.09+)
export DOCKER_BUILDKIT=1

docker build --tag my-app .
```

## 15. Lint Your Dockerfile

```bash
# Install hadolint
# On macOS: brew install hadolint
# On Linux: 
wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
chmod +x /bin/hadolint

# Lint your Dockerfile
hadolint Dockerfile
```

## Example: Optimized Dockerfile

```dockerfile
# syntax=docker/dockerfile:1.4

# Stage 1: Build
FROM node:18-alpine AS build
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:18-alpine
WORKDIR /app

# Install production dependencies only
COPY --from=build /app/package*.json ./
RUN npm ci --only=production

# Copy built application
COPY --from=build /app/dist ./dist

# Create non-root user
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup && \
    chown -R appuser:appgroup /app
USER appuser

# Configure container
EXPOSE 3000
ENV NODE_ENV=production
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD node healthcheck.js

# Run the application
CMD ["node", "dist/main.js"]
```

## Next Steps

- [Docker Compose Guide](/tutorials/docker/docker-compose/)
- [Docker Security Best Practices](/tutorials/security/docker/)
- [Kubernetes Deployment Guide](/tutorials/kubernetes/)

{{< button "Back to Docker Tutorials" "/tutorials/docker/" >}}
