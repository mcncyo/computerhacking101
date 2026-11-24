---
title: "Docker Container Networking: A Complete Guide"
date: 2025-08-18
description: "Master Docker networking concepts, from basic container communication to advanced networking configurations for production environments."
keywords: ["docker networking", "container networking", "docker network types", "docker-compose networking", "container communication"]
tags: ["docker", "networking", "containers", "devops"]
draft: false
---

## Docker Container Networking: The Complete Guide

Docker networking enables containers to communicate with each other and with external networks. This comprehensive guide will help you understand and master Docker's networking capabilities, from basic concepts to advanced configurations for production environments.

## Table of Contents
- [Docker Network Types](#docker-network-types)
- [Basic Networking Commands](#basic-networking-commands)
- [Container-to-Container Communication](#container-to-container-communication)
- [Docker Compose Networking](#docker-compose-networking)
- [Advanced Networking Scenarios](#advanced-networking-scenarios)
- [Network Security Best Practices](#network-security-best-practices)
- [Troubleshooting Network Issues](#troubleshooting-network-issues)
- [Performance Considerations](#performance-considerations)
- [Real-World Example](#real-world-example-multi-tier-application)

## Docker Network Types

Docker provides several network drivers that determine how containers communicate. Each type serves different use cases and offers various levels of isolation and performance characteristics.

### 1. Bridge Network (Default)
The default network driver that creates an internal, private network on the host. Containers on the same bridge can communicate with each other by default.

**When to use:**
- Running multiple containers that need to communicate on a single Docker host
- When you need network isolation between containers
- For development and testing environments

**Example:**
```bash
# Create a custom bridge network
docker network create my-bridge-network

# Run a container on the custom bridge
docker run -d --name web --network my-bridge-network nginx
```

**Key Points:**
- Each container gets its own IP address
- Containers can resolve each other by container name
- External access must be explicitly published using `-p` or `--publish`
- Provides network isolation from other bridge networks

### 2. Host Network
Removes network isolation between the container and the Docker host. The container shares the host's networking namespace.

**When to use:**
- When you need maximum network performance
- For network-intensive applications
- When you don't need network isolation from the host

**Example:**
```bash
# Run a container using the host's network stack
docker run -d --network host nginx
```

**Key Points:**
- No network isolation from the host
- No port mapping needed (use host ports directly)
- Better performance than bridge networking
- Less secure due to shared network namespace

### 3. Overlay Network
Enables communication between containers across multiple Docker daemons (Docker Swarm or Kubernetes).

**When to use:**
- For container communication across multiple Docker hosts
- In Docker Swarm mode
- For distributed applications

**Example:**
```bash
# Initialize swarm if not already done
docker swarm init

# Create an overlay network
docker network create -d overlay my-overlay
```

**Key Points:**
- Enables multi-host container networking
- Uses VXLAN for secure communication
- Automatically handles routing between hosts
- Requires Docker Swarm or Kubernetes

### 4. Macvlan Network
Allows containers to have MAC addresses, making them appear as physical devices on your network.

**When to use:**
- When containers need to be on the same network as the host
- For legacy applications that expect to be directly on the physical network
- When you need containers to have their own MAC addresses

**Example:**
```bash
# Create a macvlan network
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  my-macvlan
```

**Key Points:**
- Containers get their own MAC and IP addresses
- Appear as physical devices on the network
- Bypasses Docker's port mapping
- Requires promiscuous mode on the host network interface

### 5. None Network
Completely disables networking for a container.

**When to use:**
- For containers that don't need network access
- For security-sensitive applications
- For batch processing jobs that only interact with volumes

**Example:**
```bash
# Run a container without network access
docker run -d --network none alpine sleep 3600
```

**Key Points:**
- No network interfaces (except loopback)
- Maximum isolation
- Can only communicate with the host via volumes

## Basic Networking Commands

### List Networks
View all Docker networks on your system.

```bash
docker network ls
```

**Output Example:**
```
NETWORK ID     NAME              DRIVER    SCOPE
abc123         bridge            bridge    local
def456         host              host      local
789abc         my-bridge         bridge    local
```

### Inspect a Network
Get detailed information about a specific network, including connected containers, IPAM configuration, and more.

```bash
docker network inspect bridge
```

**Key Information in Output:**
- Containers connected to the network
- IP address management (IPAM) configuration
- Network driver and options
- Subnet and gateway information

### Connect/Disconnect Containers
Dynamically connect or disconnect running containers from networks.

**Connect a container to a network:**
```bash
docker network connect my-network container-name
```

**Disconnect a container from a network:**
```bash
docker network disconnect my-network container-name
```

**Common Use Cases:**
- Adding a container to an existing network without restarting
- Temporarily isolating a container for debugging
- Connecting containers to multiple networks

**Example Workflow:**
```bash
# Create a new network
docker network create app-network

# Start a container
docker run -d --name web nginx

# Connect the running container to the network
docker network connect app-network web

# Verify the connection
docker network inspect app-network
```

## Container-to-Container Communication

### Using Container Names (DNS)
Docker provides automatic DNS resolution between containers on the same network using container names as hostnames.

**Example:**
```bash
# Start a web server container
docker run -d --name web --network my-network nginx

# Start an alpine container and ping the web server
docker run -it --network my-network alpine ping web
```

**Key Points:**
- Containers can resolve each other by name
- No need to know container IP addresses
- Works across all network types except 'none'
- Uses Docker's embedded DNS server

**Advanced DNS Features:**
- Automatic service discovery
- Round-robin DNS for containers with the same service name
- Custom hostname and domain settings

### Using IP Addresses
While DNS is preferred, you can also use direct IP addressing.

**Get a container's IP address:**
```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container-name
```

**Example Workflow:**
```bash
# Get the IP address of the 'web' container
WEB_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web)

# Use the IP address to connect from another container
docker run -it --network my-network alpine ping $WEB_IP
```

**When to Use IP Addresses:**
- When DNS resolution is not available
- For debugging network issues
- When you need to verify connectivity
- In scripts where DNS resolution might be problematic

**Important Notes:**
- IP addresses are not stable across container restarts
- Using container names is more reliable in dynamic environments
- IP-based communication requires containers to be on the same network

## Docker Compose Networking

Docker Compose simplifies networking between multiple containers by automatically creating a default network for your services. You can also define custom networks for more control.

### Basic Example
This example shows a simple web application with a database.

```yaml
version: '3.8'

services:
  web:
    image: nginx
    ports:
      - "8080:80"  # Map host port 8080 to container port 80
    networks:
      - app-network  # Connect to the app-network
    depends_on:
      - db  # Ensure db starts before web

  db:
    image: postgres
    environment:
      POSTGRES_PASSWORD: example
      POSTGRES_DB: myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network  # Same network as web
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

networks:
  app-network:
    driver: bridge  # Default network driver

volumes:
  postgres_data:  # Named volume for database persistence
```

**Key Points:**
- Services on the same network can communicate using their service names
- The `depends_on` ensures services start in the correct order
- Health checks help manage service dependencies
- Volumes persist database data between container restarts

### Multi-Container Communication
For more complex applications, you might need multiple networks to isolate different parts of your application.

```yaml
version: '3.8'

services:
  # Frontend service (public)
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"  # Expose to host
    networks:
      - frontend-network
    depends_on:
      - api  # Ensure API is available

  # Backend API (internal)
  api:
    build: ./api
    environment:
      - DB_HOST=db
      - REDIS_HOST=redis
    networks:
      - backend-network
      - frontend-network  # Connect to both networks
    depends_on:
      - db
      - redis

  # Database (internal only)
  db:
    image: postgres:13
    environment:
      POSTGRES_PASSWORD: example
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - backend-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  # Redis Cache (internal only)
  redis:
    image: redis:alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - backend-network

networks:
  frontend-network:
    driver: bridge
  backend-network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
```

**Network Isolation Benefits:**
- Frontend services can only access the API
- Database and cache are not exposed to the frontend
- Better security through network segmentation
- Clearer service boundaries

**Advanced Features:**
- Multiple network attachments per service
- Custom network drivers and options
- Network aliases for service discovery
- Internal-only networks for sensitive services

## Advanced Networking Scenarios

### Custom DNS Configuration
Customize how containers resolve DNS queries, which is particularly useful in corporate environments or when you need to override default DNS settings.

```yaml
services:
  app:
    image: nginx
    dns:
      - 8.8.8.8           # Primary DNS server (Google DNS)
      - 8.8.4.4           # Secondary DNS server
      - 192.168.1.1       # Local DNS server (example)
    dns_search:
      - example.com        # Default search domain
      - corp.example.com   # Additional search domains
    dns_opt:
      - use-vc             # Use TCP for DNS queries
      - ndots:2            # Number of dots before absolute query
```

**Use Cases:**
- Corporate networks with internal DNS
- Split DNS configurations
- Testing DNS resolution
- Overriding default DNS settings

### Network Aliases
Create additional DNS names for your services within a Docker network, enabling flexible service discovery.

```yaml
services:
  web:
    image: nginx
    networks:
      app_net:
        aliases:
          - frontend         # Resolves to this container
          - webapp           # Additional alias
          - app.local        # Local development domain

  api:
    image: my-api
    networks:
      app_net:
        aliases:
          - api
          - api.local

networks:
  app_net:
    driver: bridge
    enable_ipv6: true        # Enable IPv6 support
    ipam:
      driver: default
      config:
        - subnet: "172.28.0.0/16"
          gateway: "172.28.5.254"
        - subnet: "2001:3984:3989::/64"  # IPv6 subnet
          gateway: "2001:3984:3989::1"
```

**Benefits:**
- Human-readable service names
- Multiple domain names for the same service
- Service discovery without hardcoded IPs
- Easier service migration

### External Networks
Connect containers to pre-existing networks, which is useful for integrating with other Docker environments or systems.

```yaml
services:
  app:
    image: myapp
    networks:
      - my-previous-network
      - monitoring         # Connect to multiple networks

  metrics:
    image: prom/node-exporter
    networks:
      - monitoring

networks:
  my-previous-network:
    external: true
    name: existing-network-name  # Must already exist
    
  monitoring:
    driver: bridge
    name: monitoring-network    # Custom network name
    driver_opts:
      com.docker.network.driver.mtu: "1500"
```

**Common Scenarios:**
- Connecting to a VPN network
- Integrating with existing infrastructure
- Sharing networks between Docker Compose projects
- Connecting to host network services

**Advanced Network Configuration:**
- Custom MTU settings
- Network labels for metadata
- Custom network drivers
- Network encryption options
- IPv6 support

### Multi-Host Networking with Overlay
For distributed applications spanning multiple Docker hosts.

```yaml
version: '3.8'

services:
  web:
    image: nginx
    deploy:
      replicas: 3
      placement:
        constraints: [node.role == worker]
    networks:
      - frontend

  api:
    image: my-api
    deploy:
      replicas: 3
      placement:
        constraints: [node.role == worker]
    networks:
      - frontend
      - backend

  db:
    image: postgres
    deploy:
      placement:
        constraints: [node.role == manager]
    networks:
      - backend

networks:
  frontend:
    driver: overlay
    attachable: true
  backend:
    driver: overlay
    internal: true  # Isolated from external access

volumes:
  db-data:
```

**Key Features:**
- Service discovery across multiple hosts
- Load balancing between replicas
- Secure communication between services
- Isolated backend network
- Zero-downtime deployments

## Network Security Best Practices

### 1. Use Custom Bridge Networks
Custom bridge networks provide isolation between containers and the host. Unlike the default bridge, custom bridges offer automatic DNS resolution between containers and better isolation.

```bash
# Create an isolated network that's not routable from outside
# The --internal flag prevents external access
docker network create --internal my-secure-network
```

**Security Benefits:**
- Isolates containers from external networks
- Prevents accidental exposure of services
- Reduces attack surface
- Allows fine-grained control over container communication

### 2. Limit Container Networking
Control which ports are exposed and how containers communicate.

```yaml
services:
  db:
    image: postgres:13
    networks:
      - internal  # Only accessible within this network
    # Only expose port 5432 to other containers on the same network
    expose:
      - "5432"    # PostgreSQL default port
    # No ports published to host
    
  api:
    build: .
    networks:
      - internal
      - frontend
    # Only expose port 3000 to the frontend network
    expose:
      - "3000"

networks:
  internal:
    internal: true  # No external access
  frontend:
    driver: bridge
```

**Key Security Measures:**
- Use `expose` instead of `ports` for internal communication
- Only publish necessary ports to the host
- Use internal networks for sensitive services
- Implement network segmentation

### 3. Enable Network Encryption (Swarm Mode)
For production deployments, encrypt overlay network traffic between containers.

```bash
# Create an encrypted overlay network
# Data is encrypted using the AES algorithm in GCM mode
docker network create --opt encrypted --driver overlay my-secure-overlay
```

**Encryption Features:**
- Encrypts all traffic between containers
- Uses AES in GCM mode with 256-bit keys
- Minimal performance overhead
- Automatic key rotation

### 4. Implement Network Policies
Control traffic flow between services using network policies.

**Docker Swarm Mode:**
```yaml
services:
  web:
    image: nginx
    deploy:
      placement:
        constraints: [node.role == worker]
    networks:
      - frontend
    configs:
      - source: nginx-config
        target: /etc/nginx/nginx.conf

  api:
    image: my-api
    deploy:
      placement:
        constraints: [node.role == worker]
    networks:
      - frontend
      - backend

networks:
  frontend:
    driver: overlay
    attachable: true
  backend:
    driver: overlay
    internal: true  # No external access
```

**Kubernetes Network Policies:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-allow-specific
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 3000
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: database
    ports:
    - protocol: TCP
      port: 5432
```

**Key Security Practices:**
- Default deny all traffic
- Explicitly allow necessary communications
- Use network segmentation
- Monitor network traffic
- Regularly audit network policies

## Troubleshooting Network Issues

### Diagnostic Commands
Use these commands to identify and resolve network problems:

**1. Container Network Inspection**
```bash
# Get detailed container network configuration
docker inspect container-name | jq '.[].NetworkSettings'

# View container IP addresses
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container-name

# Check container's DNS configuration
docker exec -it container-name cat /etc/resolv.conf
```

**2. Network Inspection**
```bash
# List all networks
docker network ls

# Get detailed network information
docker network inspect network-name

# View connected containers and their IPs
docker network inspect -f '{{range .Containers}}{{.Name}} {{.IPv4Address}}\n{{end}}' network-name
```

**3. Connectivity Testing**
```bash
# Test connectivity between containers
docker exec -it container1 ping container2

# Check DNS resolution
docker exec -it container nslookup google.com

# View routing table
docker exec -it container ip route

# Check open ports and connections
docker exec -it container netstat -tuln

# Test HTTP connectivity
docker exec -it container curl -I http://example.com
```

### Common Issues and Solutions

**1. Containers Can't Reach Each Other**

**Symptoms:**
- Ping fails between containers
- Services can't connect to each other
- Connection timeouts

**Troubleshooting Steps:**
1. Verify containers are on the same network:
   ```bash
   docker inspect container1 container2 | grep -A 5 "Networks"
   ```
2. Check container logs for errors:
   ```bash
   docker logs container-name
   ```
3. Test basic connectivity:
   ```bash
   # From container1
   docker exec -it container1 ping container2
   ```
4. Verify DNS resolution:
   ```bash
   docker exec -it container1 nslookup container2
   ```
5. Check firewall rules:
   ```bash
   sudo iptables -L -n
   ```

**2. Port Already in Use**

**Symptoms:**
- Container fails to start with port binding error
- "Address already in use" errors

**Solutions:**
1. Find the process using the port:
   ```bash
   # On Linux
   sudo lsof -i :80
   sudo netstat -tulpn | grep :80
   
   # On macOS
   lsof -i :80
   ```
2. Stop the conflicting process or choose a different port
3. Check for zombie containers:
   ```bash
   docker ps -a | grep Exited
   ```

**3. DNS Resolution Issues**

**Symptoms:**
- Containers can't resolve domain names
- Slow DNS lookups
- Intermittent connectivity

**Troubleshooting:**
1. Check container's DNS configuration:
   ```bash
   docker exec -it container cat /etc/resolv.conf
   ```
2. Test DNS resolution:
   ```bash
   docker exec -it container nslookup google.com
   docker exec -it container ping -c 4 8.8.8.8
   ```
3. Check Docker daemon DNS settings in `/etc/docker/daemon.json`:
   ```json
   {
     "dns": ["8.8.8.8", "8.8.4.4"],
     "dns-search": ["example.com"]
   }
   ```
4. Restart Docker daemon after changes:
   ```bash
   sudo systemctl restart docker
   ```

**4. Network Performance Issues**

**Symptoms:**
- Slow network throughput
- High latency
- Connection timeouts

**Troubleshooting:**
1. Check network interface statistics:
   ```bash
   docker exec -it container ifconfig
   docker exec -it container netstat -s
   ```
2. Test network performance:
   ```bash
   # Install iperf3 in containers
   docker exec -it container1 apt-get update && apt-get install -y iperf3
   docker exec -it container2 apt-get update && apt-get install -y iperf3
   
   # Start server on container1
   docker exec -itd container1 iperf3 -s
   
   # Run test from container2
   docker exec -it container2 iperf3 -c container1
   ```
3. Check for network congestion or packet loss:
   ```bash
   docker exec -it container ping -c 100 container2
   ```

**5. Docker Network Driver Issues**

**Symptoms:**
- Containers can't connect to the network
- Network creation fails
- Intermittent connectivity

**Troubleshooting:**
1. Check Docker network driver status:
   ```bash
   docker info | grep -i network
   ```
2. Restart Docker networking:
   ```bash
   sudo systemctl restart docker
   ```
3. Recreate the network:
   ```bash
   docker network rm my-network
   docker network create my-network
   ```
4. Check kernel modules:
   ```bash
   lsmod | grep bridge
   lsmod | grep overlay
   ```

## Performance Considerations

### Network Performance Optimization

**1. Network Driver Selection**
- **Host Mode**: Maximum performance, least isolation
  ```bash
  docker run -d --network host nginx
  ```
  *Best for:* High-performance requirements, low-latency applications

- **Macvlan**: Near bare-metal performance with MAC addresses
  ```bash
  docker network create -d macvlan \
    --subnet=192.168.1.0/24 \
    --gateway=192.168.1.1 \
    -o parent=eth0 \
    my-macvlan
  ```
  *Best for:* Network-intensive applications requiring direct access to physical network

- **Overlay Networks**: For multi-host communication
  ```bash
  docker network create -d overlay --opt encrypted my-overlay
  ```
  *Best for:* Distributed applications, Docker Swarm, Kubernetes

**2. Network Tuning**

**MTU Configuration**
```yaml
services:
  app:
    image: nginx
    networks:
      app_net:
        driver_opts:
          com.docker.network.driver.mtu: "1500"  # Standard Ethernet MTU
```

**TCP Stack Tuning**
```bash
# Increase TCP buffer sizes
echo 'net.core.rmem_max=16777216' | sudo tee -a /etc/sysctl.conf
echo 'net.core.wmem_max=16777216' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

**3. Resource Management**

**CPU and Memory Limits**
```yaml
services:
  app:
    image: nginx
    deploy:
      resources:
        limits:
          cpus: '2.0'    # Maximum 2 CPU cores
          memory: 1G     # Maximum 1GB RAM
        reservations:
          cpus: '0.5'    # Guaranteed 0.5 CPU core
          memory: 512M   # Guaranteed 512MB RAM
```

**Network Bandwidth Limitation**
```yaml
services:
  app:
    image: nginx
    networks:
      app_net:
        # Limit egress bandwidth to 100Mbps
        # 100Mbps = 100 * 1000 * 1000 / 8 = 12500000 bytes/second
        driver_opts:
          com.docker.network.bandwidth.egress: "12500000"
          
        # Limit ingress bandwidth to 50Mbps
        com.docker.network.bandwidth.ingress: "6250000"
```

**4. Monitoring and Metrics**

**Docker Stats**
```bash
# Basic container stats
docker stats

# Network-specific stats
docker stats --format "table {{.Name}}\t{{.NetIO}}"

# Detailed container metrics
docker container stats --no-stream
```

**cAdvisor for Advanced Monitoring**
```yaml
version: '3.8'
services:
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    devices:
      - /dev/kmsg:/dev/kmsg
    ports:
      - "8080:8080"
    networks:
      - monitoring

networks:
  monitoring:
    driver: bridge
```

**5. Best Practices for Network Performance**

**Container Communication**
- Place frequently communicating containers on the same host
- Use container names instead of IP addresses for service discovery
- Consider using Docker's embedded DNS server instead of /etc/hosts

**Network Security**
- Use network policies to control traffic flow
- Encrypt sensitive traffic using TLS
- Implement network segmentation for multi-tier applications

**Load Balancing**
- Use Docker Swarm or Kubernetes for built-in load balancing
- Consider external load balancers for production traffic
- Implement health checks for automatic failover

**6. Performance Testing**

**Network Benchmarking with iperf3**
```bash
# Server container
docker run -it --rm --name=iperf-server -p 5201:5201 networkstatic/iperf3 -s

# Client container
docker run -it --rm --network=host networkstatic/iperf3 -c localhost -t 30
```

**Latency Testing**
```bash
# Test latency between containers
docker run --rm --network=host alpine ping -c 10 google.com

# Test DNS resolution time
docker run --rm --dns=8.8.8.8 alpine time nslookup google.com
```

**7. Advanced Network Configuration**

**Custom Network Interface**
```yaml
services:
  app:
    image: nginx
    sysctls:
      - net.core.somaxconn=1024
      - net.ipv4.tcp_max_syn_backlog=1024
    cap_add:
      - NET_ADMIN
    devices:
      - "/dev/net/tun:/dev/net/tun"
```

**Network Namespace Sharing**
```yaml
services:
  app:
    image: nginx
    network_mode: "service:another-service"  # Share network namespace
```

**8. Troubleshooting Performance Issues**

**Network Bottlenecks**
```bash
# Check for packet drops
docker exec -it container-name netstat -i

# Monitor network traffic
docker exec -it container-name iftop

# Check for TCP retransmissions
docker exec -it container-name ss -s
```

**Connection Pooling**
- Implement connection pooling in your application
- Reuse connections when possible
- Set appropriate timeouts and retries

**9. Cloud-Specific Considerations**

**AWS ECS/EKS**
- Use AWS VPC CNI plugin for native networking
- Consider using AWS PrivateLink for private connectivity
- Enable service discovery using CloudMap

**Google GKE**
- Use VPC-native clusters for better performance
- Enable network policies for security
- Consider using GCP's global load balancer

**Azure AKS**
- Use Azure CNI for better network performance
- Implement network policies using Azure Network Policy or Calico
- Consider using Azure Front Door for global load balancing

## Real-World Example: Multi-Tier Application

```yaml
version: '3.8'

services:
  # Frontend Service
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    networks:
      - frontend
    depends_on:
      - api

  # Backend API
  api:
    build: ./api
    environment:
      - DB_HOST=db
      - REDIS_HOST=redis
    networks:
      - backend
      - frontend
    depends_on:
      - db
      - redis

  # Database
  db:
    image: postgres:13
    environment:
      POSTGRES_PASSWORD: example
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - backend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  # Redis Cache
  redis:
    image: redis:6
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - backend

  # Monitoring
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - monitoring
      - backend

  grafana:
    image: grafana/grafana
    ports:
      - "3001:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - monitoring
    depends_on:
      - prometheus

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
  monitoring:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
  grafana_data:
```

## Next Steps

- [Docker Compose Guide](/tutorials/docker/docker-compose/)
- [Docker Security Best Practices](/tutorials/security/docker/)
- [Kubernetes Networking](/tutorials/kubernetes/networking/)

{{< button "Back to Docker Tutorials" "/tutorials/docker/" >}}
