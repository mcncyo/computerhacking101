---
title: "SSH Config File: The Complete Guide"
description: "Master the SSH config file to simplify your SSH connections, manage multiple hosts, and optimize your workflow with powerful configuration options."
date: 2025-08-15T00:00:00-05:00
draft: false
weight: 3
tags: ["ssh", "configuration", "productivity", "system-administration"]
---

# SSH Config File: The Complete Guide

The SSH config file (`~/.ssh/config`) is a powerful tool that can save you time and make your SSH workflow more efficient. This guide covers everything you need to know to master SSH configuration.

## Table of Contents
- [Basic Configuration](#basic-configuration)
- [Host Patterns and Wildcards](#host-patterns-and-wildcards)
- [Common Configuration Options](#common-configuration-options)
- [Advanced Features](#advanced-features)
- [Real-World Examples](#real-world-examples)
- [Best Practices](#best-practices)

## Basic Configuration

Create or edit `~/.ssh/config` to start configuring your SSH connections:

```bash
# ~/.ssh/config

# Default configuration for all hosts
Host *
    User your_username
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
    Compression yes

# Specific host configuration
Host myserver
    HostName server.example.com
    User admin
    Port 2222
    IdentityFile ~/.ssh/myserver_ed25519
```

## Host Patterns and Wildcards

Use patterns to match multiple hosts:

```bash
# Match all hosts in example.com domain
Host *.example.com
    User admin
    Port 22

# Match multiple hosts
Host server1 server2 server3
    User deploy
    IdentityFile ~/.ssh/deploy_key

# Negative patterns with !
Host * !forbidden.example.com
    ForwardAgent yes
```

## Common Configuration Options

### Connection Settings
```bash
Host example
    HostName example.com
    User username
    Port 22
    # Timeout in seconds
    ConnectTimeout 10
    # Number of connection attempts
    ConnectionAttempts 3
```

### Authentication
```bash
Host github
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_ed25519
    # Only use the specified identity file
    IdentitiesOnly yes
    # Disable password authentication
    PasswordAuthentication no
```

### Performance Optimization
```bash
Host fast-connection
    HostName fast.example.com
    # Compression (useful for slow connections)
    Compression yes
    # Faster encryption algorithms
    Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
    # Faster MAC algorithms
    MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
```

## Advanced Features

### Jump Hosts (Bastion Hosts)
```bash
# Connect through a jump host
Host internal-server
    HostName 10.0.0.100
    User admin
    # Jump through bastion.example.com
    ProxyJump bastion

Host bastion
    HostName bastion.example.com
    User johndoe
    IdentityFile ~/.ssh/bastion_key
```

### Local and Remote Port Forwarding
```bash
# Local port forwarding (access remote service on local port)
Host db-tunnel
    HostName database.internal
    LocalForward 5432 localhost:5432
    User dbadmin

# Remote port forwarding (expose local service to remote host)
Host expose-local
    HostName public.example.com
    RemoteForward 8080 localhost:80
```

### Multiplexing (Faster Connections)
```bash
Host *
    # Enable connection sharing
    ControlMaster auto
    ControlPath ~/.ssh/control:%h:%p:%r
    ControlPersist 10m
    # Keep connections alive
    ServerAliveInterval 30
```

## Real-World Examples

### GitHub Configuration
```bash
Host github.com
    User git
    IdentityFile ~/.ssh/github_ed25519
    # Enable connection sharing for faster Git operations
    ControlMaster auto
    ControlPath ~/.ssh/control:%h:%p:%r
    ControlPersist 30m
```

### Work Development Environment
```bash
# Development server
Host dev
    HostName dev.example.com
    User developer
    IdentityFile ~/.ssh/work_ed25519
    # Forward local port 3000 to remote port 3000
    LocalForward 3000 localhost:3000
    # Forward Docker socket (be careful with this!)
    # LocalForward /var/run/docker.sock /var/run/docker.sock

# Production server (behind bastion)
Host prod
    HostName 10.0.1.100
    User admin
    ProxyJump bastion
    # Disable SSH agent forwarding for security
    ForwardAgent no
```

## Best Practices

1. **Use Descriptive Host Aliases**: Make them memorable and consistent
2. **Order Matters**: Put specific configurations before general ones
3. **Use Includes**: Split config into multiple files for better organization:
   ```bash
   # In ~/.ssh/config
   Include config.d/*
   ```
4. **Secure Sensitive Information**: Set proper permissions: `chmod 600 ~/.ssh/config`
5. **Document Your Setup**: Add comments for complex configurations
6. **Test Configurations**: Use `ssh -G hostname` to test config
7. **Version Control**: Consider keeping your SSH config in version control

## Troubleshooting

### Debug SSH Config
```bash
# Show which config options are being used
ssh -G hostname

# Show debug information
ssh -v hostname
```

### Common Issues
- **Permission Denied**: Check file permissions (`chmod 600 ~/.ssh/config`)
- **Config Not Working**: Check for typos and ensure no conflicting options
- **Connection Refused**: Verify hostname, port, and network connectivity

## Security Considerations

- Be cautious with `ForwardAgent` and `LocalForward`
- Use `IdentitiesOnly yes` to prevent SSH from trying all keys
- Consider using `Match` for conditional configurations
- Regularly audit your SSH config for unnecessary or outdated entries
