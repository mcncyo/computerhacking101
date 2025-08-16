---
title: "SSH Tunneling & Port Forwarding"
description: "Master SSH tunneling techniques including local, remote, and dynamic port forwarding. Learn how to securely access remote services and create encrypted tunnels."
date: 2025-08-15T00:00:00-05:00
draft: false
weight: 5
tags: ["ssh", "networking", "tunneling", "port-forwarding", "security"]
---

# SSH Tunneling & Port Forwarding Guide

SSH tunneling and port forwarding are powerful techniques for securely accessing remote services, bypassing firewalls, and creating encrypted tunnels. This guide covers all aspects of SSH tunneling with practical examples.

## Table of Contents
- [Introduction to SSH Tunneling](#introduction-to-ssh-tunneling)
- [Local Port Forwarding](#local-port-forwarding)
- [Remote Port Forwarding](#remote-port-forwarding)
- [Dynamic Port Forwarding (SOCKS Proxy)](#dynamic-port-forwarding)
- [Reverse Tunneling](#reverse-tunneling)
- [SSH Tunneling with Jump Hosts](#ssh-tunneling-with-jump-hosts)
- [SSH Tunneling for Web Browsing](#ssh-tunneling-for-web-browsing)
- [Persistent Tunnels with autossh](#persistent-tunnels-with-autossh)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)

## Introduction to SSH Tunneling

SSH tunneling allows you to:
- Securely access services behind firewalls
- Encrypt traffic between local and remote machines
- Bypass network restrictions
- Create secure tunnels for insecure protocols

### Basic SSH Tunneling Syntax
```bash
ssh -L [LOCAL_IP:]LOCAL_PORT:DESTINATION:DESTINATION_PORT [USER@]SSH_SERVER
ssh -R [REMOTE_IP:]REMOTE_PORT:DESTINATION:DESTINATION_PORT [USER@]SSH_SERVER
ssh -D [LOCAL_IP:]LOCAL_PORT [USER@]SSH_SERVER
```

## Local Port Forwarding

Local port forwarding lets you access a service on a remote server as if it were running locally.

### Basic Local Port Forwarding
```bash
# Forward local port 8080 to example.com:80 via SSH server
ssh -L 8080:example.com:80 user@ssh-server.com
# Now access http://localhost:8080 to reach example.com:80
```

### Bind to Specific Interface
```bash
# Only accept connections from localhost (default)
ssh -L 127.0.0.1:8080:example.com:80 user@ssh-server.com

# Accept connections from any interface (use with caution!)
ssh -L 0.0.0.0:8080:example.com:80 user@ssh-server.com
```

### Multiple Port Forwards
```bash
# Forward multiple ports in one command
ssh -L 8080:example.com:80 -L 8443:example.com:443 user@ssh-server.com
```

## Remote Port Forwarding

Remote port forwarding makes a local service available on a remote server.

### Basic Remote Port Forwarding
```bash
# Make local port 3000 available on remote server port 8080
ssh -R 8080:localhost:3000 user@ssh-server.com
# Anyone connecting to ssh-server.com:8080 will reach your localhost:3000
```

### Enable GatewayPorts
For the remote server to accept connections from other hosts:
```bash
# In /etc/ssh/sshd_config on the remote server
GatewayPorts clientspecified
# Then restart SSH: sudo systemctl restart sshd
```

## Dynamic Port Forwarding (SOCKS Proxy)

Create a local SOCKS proxy that routes traffic through the SSH server.

### Basic SOCKS Proxy
```bash
# Create a SOCKS proxy on port 1080
ssh -D 1080 user@ssh-server.com

# Configure your browser or system to use SOCKS5 proxy at localhost:1080
```

### Using SOCKS Proxy with cURL
```bash
curl --socks5 localhost:1080 http://example.com
```

## Reverse Tunneling

Access a service behind NAT/firewall by creating a reverse tunnel.

### Create a Reverse Tunnel
On the machine behind NAT:
```bash
# Connect to public server and create reverse tunnel
ssh -R 2222:localhost:22 user@public-server.com
```

Then, from the public server:
```bash
# Connect back to the machine behind NAT
ssh -p 2222 localuser@localhost
```

## SSH Tunneling with Jump Hosts

Access servers through intermediate jump hosts.

### Using -J Flag (OpenSSH 7.3+)
```bash
# Connect through one jump host
ssh -J user@jump-host user@target-host

# Multiple jump hosts
ssh -J user@jump1,user@jump2,user@jump3 user@target-host
```

### Using ProxyCommand
```bash
# Single jump host
ssh -o ProxyCommand="ssh -W %h:%p user@jump-host" user@target-host

# Multiple jump hosts
ssh -o ProxyCommand="ssh -W %h:%p -J user@jump1,user@jump2 user@jump3" user@target-host
```

## SSH Tunneling for Web Browsing

### Secure Web Browsing Through SSH
```bash
# Create SOCKS proxy
ssh -D 1080 user@ssh-server.com
```

Then configure your browser:
1. Go to network settings
2. Configure manual proxy
3. Set SOCKS Host: localhost, Port: 1080
4. Select SOCKS v5

### Browser Extensions
- Firefox: FoxyProxy
- Chrome: SwitchyOmega

## Persistent Tunnels with autossh

Keep SSH tunnels alive and automatically reconnect if they drop.

### Install autossh
```bash
# Debian/Ubuntu
sudo apt install autossh

# RHEL/CentOS
sudo yum install autossh
```

### Create Persistent Tunnel
```bash
autossh -M 0 -N -L 8080:example.com:80 user@ssh-server.com
```

### Systemd Service for Persistent Tunnel
Create `/etc/systemd/system/ssh-tunnel.service`:
```ini
[Unit]
Description=Persistent SSH Tunnel
After=network.target

[Service]
User=your_username
ExecStart=/usr/bin/autossh -M 0 -N -L 8080:example.com:80 user@ssh-server.com
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Then enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now ssh-tunnel.service
```

## SSH Tunneling for Database Access

### Secure MySQL Connection
```bash
ssh -L 3306:localhost:3306 user@database-server.com
# Connect to MySQL on localhost:3306
```

### Secure PostgreSQL Connection
```bash
ssh -L 5432:localhost:5432 user@database-server.com
# Connect to PostgreSQL on localhost:5432
```

## X11 Forwarding

Run graphical applications securely over SSH.

### Enable X11 Forwarding
```bash
# On client side
ssh -X user@remote-host
# Or for better performance
ssh -Y user@remote-host

# Then run any X11 application
xclock
```

## Security Considerations

1. **Minimize Exposure**
   - Only forward necessary ports
   - Use `-L 127.0.0.1:PORT` instead of `-L *:PORT`
   - Disable `AllowTcpForwarding` if not needed

2. **Authentication**
   - Use key-based authentication
   - Disable password authentication
   - Use strong passphrases

3. **Firewall Rules**
   - Restrict SSH access with firewall rules
   - Use fail2ban to prevent brute force attacks

4. **SSH Configuration**
   ```bash
   # In /etc/ssh/sshd_config
   AllowTcpForwarding yes
   GatewayPorts no
   X11Forwarding no
   AllowAgentForwarding no
   ```

## Troubleshooting

### Common Issues

1. **Connection Refused**
   ```bash
   # Check if SSH server allows port forwarding
   grep -i 'allowtcpforwarding' /etc/ssh/sshd_config
   
   # Check if port is in use
   sudo lsof -i :PORT
   ```

2. **Tunnel Drops**
   ```bash
   # Use autossh for automatic reconnection
   autossh -M 0 -N -L 8080:example.com:80 user@ssh-server.com
   
   # Add keepalive to SSH config
   echo "ServerAliveInterval 60" >> ~/.ssh/config
   ```

3. **Permission Denied**
   ```bash
   # Check permissions on ~/.ssh directory and files
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/*
   ```

### Debugging SSH Connections
```bash
# Verbose output
ssh -v -L 8080:example.com:80 user@ssh-server.com

# More verbose
ssh -vvv -L 8080:example.com:80 user@ssh-server.com
```

## Performance Tuning

### Compression
```bash
# Enable compression (good for slow connections)
ssh -C -L 8080:example.com:80 user@ssh-server.com
```

### Cipher Selection
```bash
# Use faster ciphers
ssh -c arcfour,blowfish-cbc -L 8080:example.com:80 user@ssh-server.com
```

### Multiplexing
```bash
# In ~/.ssh/config
Host *
    ControlMaster auto
    ControlPath ~/.ssh/control:%h:%p:%r
    ControlPersist 10m
```

## Advanced Examples

### Double SSH Tunnel
```bash
# Through two SSH servers
ssh -L 8080:target-server:80 -J user@jump-host user@intermediate-host
```

### VPN Over SSH
```bash
# Create a tun device
ssh -w 0:0 user@vpn-server

# On the server:
sudo ifconfig tun0 10.0.0.1 10.0.0.2

# On the client:
sudo ifconfig tun0 10.0.0.2 10.0.0.1
```

## Conclusion

SSH tunneling is a versatile tool for:
- Securely accessing remote services
- Bypassing network restrictions
- Creating secure tunnels for insecure protocols
- Building secure communication channels

Always consider security implications and follow best practices when setting up SSH tunnels.

## Additional Resources

- [OpenSSH Manual](https://www.openssh.com/manual.html)
- [SSH Tunneling Explained](https://www.ssh.com/ssh/tunneling/example)
- [SSH Port Forwarding](https://www.cyberciti.biz/faq/ssh-port-forwarding/)

---

*Last updated: August 2025*
