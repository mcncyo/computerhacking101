---
title: "Install Syncthing on Linux"
description: "Step-by-step guide to install and configure Syncthing on Linux for secure file synchronization"
date: '2024-12-29T10:09:40-06:00'
lastmod: "2025-07-03"
draft: false
weight: 2
---

{{< youtube _PXNxpdAvJM >}}

# 🚀 Install Syncthing on Linux

## 🌟 Introduction

Syncthing is a continuous file synchronization program that synchronizes files between two or more computers in real time, safely protected from prying eyes. This guide will walk you through installing and setting up Syncthing on your Linux system.

{{< notice tip >}}
💡 **Did You Know?** Syncthing uses a peer-to-peer architecture, meaning your files are synchronized directly between your devices without relying on a central server.
{{< /notice >}}

## 🚀 Quick Start

For those who want to get started quickly, here are the essential commands:

```bash
# Add the release PGP key and repository
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

# Update and install
sudo apt update
sudo apt install syncthing

# Enable and start the service (replace 'username' with your actual username)
sudo systemctl enable --now syncthing@username.service
```

## 📚 Step-by-Step Guide

#### 1. Add Syncthing Repository

First, we'll add the official Syncthing repository to your system's package sources. This ensures you get the latest stable version.

{{< tabs >}}
{{< tab "Debian/Ubuntu" >}}
```bash
echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
```
{{< /tab >}}
{{< tab "RHEL/CentOS" >}}
```bash
# For RHEL 8/CentOS 8 and later
sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/home:/knsit:/syncthing/RHEL_8/home:knsit:syncthing.repo
```
{{< /tab >}}
{{< /tabs >}}

#### 2. Install Required Dependencies

We need `curl` to download the PGP key for the Syncthing repository.

{{< tabs >}}
{{< tab "Debian/Ubuntu" >}}
```bash
sudo apt update
sudo apt install -y curl
```
{{< /tab >}}
{{< tab "RHEL/CentOS" >}}
```bash
sudo dnf install -y curl
```
{{< /tab >}}
{{< /tabs >}}

{{< notice info >}}
If curl is already installed, you'll see a message indicating it's already at the latest version.
{{< /notice >}}

#### 3. Add Syncthing's PGP Key

To ensure the integrity of the packages, we need to add Syncthing's PGP key to your system's trusted keys.

{{< tabs >}}
{{< tab "Debian/Ubuntu" >}}
```bash
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
```
{{< /tab >}}
{{< tab "RHEL/CentOS 8+" >}}
```bash
sudo rpm --import https://syncthing.net/release-key.txt
```
{{< /tab >}}
{{< /tabs >}}

After adding the key, you should see an "OK" message confirming the key was added successfully.

#### 4. Update Package Database

Refresh your package lists to include the newly added Syncthing repository.

{{< tabs >}}
{{< tab "Debian/Ubuntu" >}}
```bash
sudo apt update
```
{{< /tab >}}
{{< tab "RHEL/CentOS" >}}
```bash
sudo dnf makecache
```
{{< /tab >}}
{{< /tabs >}}

This ensures your system is aware of the Syncthing package and its dependencies.

#### 5. Install Syncthing

Now we can install Syncthing using your distribution's package manager.

{{< tabs >}}
{{< tab "Debian/Ubuntu" >}}
```bash
sudo apt install -y syncthing
```
{{< /tab >}}
{{< tab "RHEL/CentOS" >}}
```bash
sudo dnf install -y syncthing
```
{{< /tab >}}
{{< /tabs >}}

This will install Syncthing along with all its dependencies.

#### 6. Enable Syncthing Service

To ensure Syncthing starts automatically when your system boots, enable it as a systemd service. Replace `username` with your actual Linux username.

{{< notice warning >}}
**Security Note**: Always run Syncthing as a regular user, not as root, to follow security best practices.
{{< /notice >}}

```bash
# Replace 'username' with your actual username
sudo systemctl enable syncthing@username.service
```

This creates a systemd service that will start Syncthing automatically at boot.

To verify that Syncthing is running:

```bash
systemctl --user status syncthing.service
```

You should see output indicating that the service is active and running.

## 🌐 Accessing the Web Interface

Once Syncthing is running, you can access its web interface by opening a web browser and navigating to:

```
http://localhost:8384/
```

You'll be greeted by the Syncthing web interface where you can configure your synchronization settings.

## 🔄 Basic Syncthing Commands

Here are some useful commands for managing Syncthing:

| Command | Description |
|---------|-------------|
| `systemctl --user start syncthing` | Start Syncthing |
| `systemctl --user stop syncthing` | Stop Syncthing |
| `systemctl --user restart syncthing` | Restart Syncthing |
| `systemctl --user enable --now syncthing` | Enable and start Syncthing |
| `journalctl --user -u syncthing -f` | View Syncthing logs |

## 🌟 Next Steps

Now that you have Syncthing installed, you might want to:

1. [Set up your first folder sync](https://docs.syncthing.net/users/folders.html)
2. [Add a remote device](https://docs.syncthing.net/users/device-ids.html)
3. [Configure automatic startup](https://docs.syncthing.net/users/autostart.html)
4. [Set up file versioning](https://docs.syncthing.net/users/versioning.html)

## 🌐 Remote Access Configuration (Optional)

By default, Syncthing's web interface is only accessible from the local machine. If you want to access it from other devices on your network, follow these steps:

### 1. Edit the Syncthing Configuration

First, stop the Syncthing service:

```bash
systemctl --user stop syncthing
```

Then edit the configuration file (replace `username` with your actual username):

```bash
nano /home/username/.config/syncthing/config.xml
```

### 2. Update the GUI Address

Find the `<gui>` section and modify the `tls` and `address` attributes:

```xml
<gui enabled="true" tls="false" debugging="false">
    <address>0.0.0.0:8384</address>
    <!-- Rest of the GUI configuration -->
</gui>
```

### 3. Restart Syncthing

After saving the changes, restart Syncthing:

```bash
systemctl --user start syncthing
```

### 4. Access Remotely

You can now access the web interface from other devices on your network using:

```
http://<your-server-ip>:8384
```

{{< notice warning >}}
**Security Note**: This configuration is not secure for use over the internet. For remote access, consider using a VPN or setting up an SSH tunnel.
{{< /notice >}}

## 🔒 Security Considerations

- **Enable Authentication**: Always set a username and password in the web interface
- **Use HTTPS**: Enable TLS in the GUI settings for encrypted connections
- **Firewall Rules**: Configure your firewall to only allow access from trusted networks
- **Regular Updates**: Keep Syncthing updated to the latest version

## 🛠 Troubleshooting

### Common Issues

1. **Service won't start**
   - Check logs: `journalctl --user -u syncthing -f`
   - Verify permissions on `~/.config/syncthing/`

2. **Can't access web interface**
   - Check if the service is running
   - Verify the listening address in the config
   - Check firewall settings

3. **Devices won't connect**
   - Ensure both devices are online
   - Check if port 22000 is open in your firewall
   - Verify device IDs are correctly added

## 📚 Additional Resources

- [Official Syncthing Documentation](https://docs.syncthing.net/)
- [Syncthing Forum](https://forum.syncthing.net/)
- [GitHub Repository](https://github.com/syncthing/syncthing)

{{< button "Get Started with Syncthing" "https://docs.syncthing.net/intro/getting-started.html" >}}
