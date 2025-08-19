---
title: "SSH Certificates"
date: 2025-08-18
description: "Learn how to implement certificate-based authentication for SSH to enhance security and simplify key management in large environments."
keywords: ["ssh certificates", "ssh-ca", "certificate authority", "ssh authentication", "key management"]
tags: ["ssh", "security", "authentication"]
draft: false
---

# SSH Certificates: Secure Authentication at Scale

SSH certificates provide a more manageable and secure alternative to traditional SSH key authentication, especially in large environments. This guide covers how to set up and use SSH certificates for authentication.

## Why Use SSH Certificates?

- **Centralized Management**: Issue and revoke access from a central authority
- **Short-lived Credentials**: Set expiration times for certificates
- **No Key Distribution**: No need to copy public keys to servers
- **Fine-grained Access Control**: Restrict what users can do with certificates
- **Audit Trail**: Track certificate issuance and usage

## How SSH Certificates Work

1. A Certificate Authority (CA) issues signed certificates to users
2. Servers trust the CA's public key
3. Users present their certificate to servers
4. Servers verify the certificate's signature against the CA's public key

## Setting Up a Simple SSH CA

### 1. Create a CA Key Pair

```bash
# Generate a new key pair for the CA
ssh-keygen -t ed25519 -f ~/.ssh/ca_key -C "SSH CA Key"

# Securely store the private key (ca_key)
# Distribute the public key (ca_key.pub) to servers
```

### 2. Configure the CA on Servers

On each server, add this to `/etc/ssh/sshd_config`:

```
# Trust the CA for user authentication
TrustedUserCAKeys /etc/ssh/ca_key.pub

# Optional: Restrict which principals can log in
# This allows only users with certificates having the 'admin' role
# Match User *
#    AuthorizedPrincipalsFile /etc/ssh/auth_principals/%u
```

### 3. Create User Certificates

```bash
# Generate a user key pair if needed
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "user@example.com"

# Sign the user's public key with the CA
ssh-keygen -s ~/.ssh/ca_key \
  -I "user@example.com" \
  -n "username" \
  -V +1w \
  ~/.ssh/id_ed25519.pub

# This creates id_ed25519-cert.pub
```

## Certificate Options

- `-I`: Certificate identifier (for logging)
- `-n`: Username or principals (comma-separated)
- `-V`: Validity period (e.g., `+1w` for one week)
- `-O clear`: Clear all critical options
- `-O no-port-forwarding`: Restrict port forwarding
- `-O command="/bin/restricted-shell"`: Force a specific command

## Using Certificates

### Client Configuration

Add to `~/.ssh/config`:

```
Host *
    IdentityFile ~/.ssh/id_ed25519
    CertificateFile ~/.ssh/id_ed25519-cert.pub
```

### Verifying the Certificate

```bash
# View certificate details
ssh-keygen -Lf ~/.ssh/id_ed25519-cert.pub

# Test connection with verbose output
ssh -v user@server
```

## Advanced Topics

### Host Certificates

```bash
# Create host key pair
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key

# Sign host key with CA
ssh-keygen -s ~/ca_key \
  -I "web01.example.com" \
  -h \
  -n "web01.example.com" \
  -V +52w \
  /etc/ssh/ssh_host_ed25519_key.pub

# Configure sshd to use the certificate
# In /etc/ssh/sshd_config:
HostKey /etc/ssh/ssh_host_ed25519_key
HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
```

### Certificate Revocation

1. Maintain a list of revoked certificate serial numbers
2. Update the `RevokedKeys` setting in `sshd_config`
3. Consider using short-lived certificates instead of revocation

## Best Practices

1. **Use Strong Keys**: Prefer Ed25519 or RSA 4096-bit
2. **Short Expiration**: Set reasonable certificate lifetimes
3. **Principle of Least Privilege**: Restrict what each certificate can do
4. **Secure CA Key**: Keep the CA private key extremely secure
5. **Monitor Usage**: Log certificate-based authentications
6. **Rotate Certificates**: Regularly issue new certificates

## Integration with CI/CD

Example for GitHub Actions:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Install SSH key
      uses: webfactory/ssh-agent@v0.8.0
      with:
        ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
        ssh-cert: ${{ secrets.SSH_CERT }}
    - name: Deploy
      run: ssh user@server "deploy-command"
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Check certificate expiration
   - Verify the username in the certificate matches the remote username
   - Check server logs: `journalctl -u ssh --since "5 minutes ago"`

2. **Certificate Not Used**
   - Verify `CertificateFile` in SSH config
   - Check file permissions: `chmod 600 ~/.ssh/*-cert.pub`

3. **Host Key Verification**
   - Ensure host certificates are properly configured
   - Check `known_hosts` for incorrect entries

## Next Steps

- [SSH Agent Forwarding](/tutorials/ssh/agent-forwarding/)
- [SSH Tunneling and Port Forwarding](/tutorials/ssh/tunneling/)
- [SSH Hardening Guide](/tutorials/security/ssh-hardening/)

{{< button "Back to SSH Tutorials" "/tutorials/ssh/" >}}
