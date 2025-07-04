---
title: "Setting Up a Server – From Cloud VPS to Secure Production Box"
description: "Choose a cloud VPS provider, create a Droplet, install Ubuntu, harden SSH, and configure a firewall for a rock-solid web server."
weight: 1
tags: ["Linux Server", "Ubuntu", "VPS", "Firewall", "Server Hardening"]
categories: ["Servers & Networking"]
sitemap:
  priority: 0.8
  changefreq: "monthly"
---

## Why Run Your Own Server?

Running your own virtual private server (VPS) gives you full control, better privacy, and often lower long-term cost than shared hosting. You can:

- Host multiple websites, APIs, or Docker containers
- Deploy Home-Assistant remote access, Nextcloud, or a Git server
- Learn real-world Linux skills that transfer to any DevOps job

---

## 1 · Pick a Cloud Provider

| Provider       | $/mo (1 GB) | Strengths                    | Gotchas                       |
| -------------- | ----------- | ---------------------------- | ----------------------------- |
| DigitalOcean   | $6          | One-click marketplace apps   | Snapshots cost extra          |
| Hetzner Cloud  | €4.15       | Fast AMD CPUs, cheap NVMe    | EU data-centres only          |
| Vultr          | $5          | Global regions, hourly billing | Older plans use slower IO   |

> **Tip:** Choose the region closest to your audience for lowest latency.

---

## 2 · Create the Server (Droplet)

- Log in to your provider dashboard.
- Choose **Ubuntu 22.04 LTS 64-bit** as the image.
- Select **1 vCPU / 1 GB** (upgrade later if needed).
- Add your **SSH key** so you can disable passwords.
- Launch it and note the public IP.

👉 [Full walk-through](/tutorials/webserver/digitalocean-droplet/)

---

## 3 · Install & Secure Ubuntu

SSH in as `root` and run:

```bash
apt update && apt upgrade -y
adduser ch101 && usermod -aG sudo ch101
```

**Disable root + password logins:**

```bash
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh
```

✅ Need the full checklist? [Set Up & Secure Ubuntu Server](/tutorials/webserver/setup-secure-ubuntu/)

---

## 4 · Enable a Firewall

Run:

```bash
ufw allow OpenSSH
ufw allow http
ufw allow https
ufw enable
```

---

## 5 · Backups & Monitoring

- **Snapshots** – enable auto-backups in your cloud panel.
- **Off-site rsync** – push `/var/www` and SQL dumps to S3/Backblaze weekly.
- **Monitoring** – Uptime Robot or Grafana Loki for alerts.

---

## Related Tutorials

| Topic                              | Quick Link                                           |
| ---------------------------------- | --------------------------------------------------- |
| Create a Droplet on DigitalOcean   | [/tutorials/webserver/digitalocean-droplet/](/tutorials/webserver/digitalocean-droplet/) |
| Set Up & Secure Ubuntu Server      | [/tutorials/webserver/setup-secure-ubuntu/](/tutorials/webserver/setup-secure-ubuntu/)   |

---

## FAQ

### How much RAM do I need?

1 GB handles Nginx + a small PHP site; 2 GB if you add Docker/Node.

### Swap on SSD VPS?

Yes – set a 1 GB zram or disk swapfile for safety.

### Best beginner distro?

Ubuntu LTS for extensive docs; Debian if you prefer slower release cycles.

---

## Next Steps

- Ready for containers? Jump to the [/tutorials/docker/](/tutorials/docker/) guides.
- Rotate keys automatically with our SSH key-management cheat-sheet.

Need help? Ping me on X/Twitter — happy server-building!