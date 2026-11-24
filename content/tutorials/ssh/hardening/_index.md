---
title: "SSH Server Hardening Guide"
description: "Secure your SSH server with these essential hardening techniques. Protect against brute force attacks, disable weak protocols, and implement security best practices."
date: 2025-08-15T00:00:00-05:00
draft: false
weight: 4
tags: ["ssh", "security", "hardening", "server-administration"]
---

Securing your SSH server is critical to protect against unauthorized access and potential security breaches. This guide provides comprehensive steps to harden your SSH server configuration.

## Table of Contents
- [Basic Security Measures](#basic-security-measures)
- [Authentication Hardening](#authentication-hardening)
- [Encryption & Algorithms](#encryption--algorithms)
- [Network Restrictions](#network-restrictions)
- [Advanced Security Measures](#advanced-security-measures)
- [Monitoring & Logging](#monitoring--logging)
- [Automated Hardening](#automated-hardening)
- [Verification & Testing](#verification--testing)

## Basic Security Measures

### 1. Update SSH Server

```bash
# Debian/Ubuntu
sudo apt update && sudo apt upgrade openssh-server

# RHEL/CentOS
sudo yum update openssh-server

# Check SSH version
ssh -V
```

### 2. Change Default SSH Port

Edit `/etc/ssh/sshd_config`:

```bash
Port 2222  # Use a non-standard port (1-1023 require root)
```

Update SELinux (if enabled):
```bash
semanage port -a -t ssh_port_t -p tcp 2222
```

### 3. Disable Root Login

```bash
PermitRootLogin no
```

### 4. Limit User Access

```bash
# Allow only specific users
AllowUsers alice bob

# Allow groups (prefixed with %)
AllowGroups sshusers

# Deny specific users
DenyUsers baduser1 baduser2
```

## Authentication Hardening

### 1. Disable Password Authentication

```bash
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
```

### 2. Enable Key-Based Authentication

```bash
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
```

### 3. Two-Factor Authentication (2FA)

Install Google Authenticator:
```bash
# Debian/Ubuntu
sudo apt install libpam-google-authenticator

# RHEL/CentOS
sudo yum install google-authenticator
```

Configure PAM:
```bash
auth required pam_google_authenticator.so
```

Update `sshd_config`:
```bash
AuthenticationMethods publickey,keyboard-interactive
```

## Encryption & Algorithms

### 1. Disable Weak Ciphers

```bash
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
```

### 2. Disable Weak MACs

```bash
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
```

### 3. Disable Weak Key Exchange Algorithms

```bash
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
```

## Network Restrictions

### 1. Limit Login Attempts

```bash
MaxAuthTries 3
MaxSessions 5
```

### 2. Configure Idle Timeout

```bash
ClientAliveInterval 300
ClientAliveCountMax 2
```

### 3. Use TCP Wrappers

Edit `/etc/hosts.allow`:
```bash
sshd: 192.168.1.0/24
```

Edit `/etc/hosts.deny`:
```bash
sshd: ALL
```

### 4. Firewall Configuration

```bash
# UFW (Ubuntu)
sudo ufw allow 2222/tcp
sudo ufw limit 2222/tcp

# firewalld (RHEL/CentOS)
sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --reload
```

## Advanced Security Measures

### 1. Fail2Ban Installation

```bash
# Debian/Ubuntu
sudo apt install fail2ban

# RHEL/CentOS
sudo yum install fail2ban
```

Configure `/etc/fail2ban/jail.local`:
```ini
[sshd]
enabled = true
port = 2222
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 1h
findtime = 600
```

### 2. Port Knocking

Install `knockd`:
```bash
# Debian/Ubuntu
sudo apt install knockd

# RHEL/CentOS
sudo yum install knock
```

Configure `/etc/knockd.conf`:
```ini
[options]
        UseSyslog
        Interface = eth0

[openSSH]
        sequence    = 7000,8000,9000
        seq_timeout = 10
        command     = /sbin/iptables -A INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
        tcpflags    = syn

[closeSSH]
        sequence    = 9000,8000,7000
        seq_timeout = 10
        command     = /sbin/iptables -D INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
        tcpflags    = syn
```

## Monitoring & Logging

### 1. Enable Verbose Logging

```bash
LogLevel VERBOSE
```

### 2. Monitor Authentication Attempts

```bash
# Monitor SSH login attempts
grep 'sshd\[.*\]: Failed' /var/log/auth.log

# Monitor successful logins
last

# Monitor current SSH sessions
who
w
```

### 3. Set Up Alerts

Example script (`/usr/local/bin/ssh-login-alert.sh`):
```bash
#!/bin/bash
if [ "$PAM_TYPE" != "open_session" ]; then
    exit 0
fi

echo "`date '+%Y-%m-%d %H:%M:%S %Z'` - $PAM_USER logged in from $PAM_RHOST" | \
    mail -s "SSH Login: $PAM_USER@$HOSTNAME" admin@example.com
```

## Automated Hardening

### 1. SSH-Audit

```bash
# Install
pip install ssh-audit

# Run audit
ssh-audit localhost -p 2222
```

### 2. Lynis

```bash
# Debian/Ubuntu
sudo apt install lynis

# RHEL/CentOS
sudo yum install lynis

# Run audit
sudo lynis audit system --tests-from-group ssh
```

## Verification & Testing

### 1. Test Configuration

```bash
# Check for syntax errors
sudo sshd -t

# Check all configurations
sudo sshd -T
```

### 2. Test Security with Nmap

```bash
# Check open ports
nmap -sV -p 2222 --script ssh2-enum-algos localhost

# Check supported algorithms
nmap -p 2222 --script ssh-hostkey --script-args ssh_hostkey=all localhost
```

## Final Steps

1. **Restart SSH Service**
   ```bash
   # Systemd
   sudo systemctl restart sshd
   
   # SysVinit
   sudo service ssh restart
   ```

2. **Keep a Backup Session Open**
   ```bash
   screen -S ssh_test
   ```

3. **Test Connection**
   ```bash
   ssh -p 2222 username@server
   ```

## Maintenance

- Regularly update your SSH server
- Monitor logs for suspicious activity
- Review and rotate SSH keys periodically
- Stay informed about new vulnerabilities

## Additional Resources

- [OpenSSH Security](https://www.openssh.com/security.html)
- [Mozilla SSH Guidelines](https://infosec.mozilla.org/guidelines/openssh)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)

---

*Last updated: August 2025*
