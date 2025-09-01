+++
lastmod = "2025-07-03"
date = '2024-12-30'
draft = false
title = 'Setting Up and Securing Your Ubuntu Server'
description = "In this tutorial, we will show you how to set up and secure your new Ubuntu server."
+++

### Introduction

DigitalOcean provides the option to configure your own VPS server. Now that your server is set up, it’s time to connect and secure it. Follow these steps to get started:

### Step 1: Connect to Your Server

First, get the IP address of your new server. Then, open a terminal and type the following command:

```bash
ssh root@{ip_address_of_the_server}
```

Press **Enter**.

![Connecting to SSH](/images/webserver/connecttossh.png)

The first time you connect, you'll see a prompt asking if you want to continue. Type `yes` and press **Enter**.

![SSH Fingerprint](/images/webserver/sshfingerprint.png)

### Step 2: Update Your System

Once connected, update your server to ensure it’s secure by running the following commands:

```bash
apt update && apt upgrade -y
```

This will apply all updates to your server. You should run this command regularly (weekly or monthly). If the updates include a kernel update, reboot the server with:

```bash
reboot
```

Wait a minute or two for the server to restart, then reconnect using the same `ssh` command as before.

### Step 3: Create a New User

For security, avoid logging in as the root user. Create a new user with the following command:

```bash
adduser chris
```

Replace `chris` with your desired username. Follow the prompts to set a password and skip additional questions by pressing **Enter** multiple times. Confirm the information at the end by pressing **Enter** again.

![Adding a User](/images/webserver/addingauser.png)

Next, add the new user to the `sudo` group:

```bash
usermod -aG sudo chris
```

Replace `chris` with your username.

### Step 4: Configure SSH Keys

Copy your SSH public key to the new user's home directory:

```bash
cp -r ~/.ssh /home/chris/.ssh
```

Update the ownership of the `.ssh` directory:

```bash
sudo chown -R chris:chris /home/chris/.ssh
```

Test logging in as the new user:

```bash
ssh chris@{ip_address_of_the_server}
```

![Login as New User](/images/webserver/logininasnewuser.png)

### Step 5: Disable Root SSH Login

Open the SSH configuration file:

```bash
sudo vim /etc/ssh/sshd_config
```

Find the line `PermitRootLogin yes` and change it to `PermitRootLogin no`. Press **i** to edit, make the change, then press **ESC** and type `:wq` to save and exit.

![Editing SSH Config](/images/webserver/editingsshdconfig.png)

Restart the SSH service to apply the changes:

```bash
sudo systemctl restart sshd
```

### Step 6: Set Up a Firewall

To block unwanted traffic, configure the Uncomplicated Firewall (UFW):

1. Deny all incoming traffic:

    ```bash
    sudo ufw default deny incoming
    ```

    ![Deny Incoming Traffic](/images/webserver/denyallincomming.png)

2. Allow all outgoing traffic:

    ```bash
    sudo ufw default allow outgoing
    ```

    ![Allow Outgoing Traffic](/images/webserver/allowalloutgoing.png)

3. Allow SSH connections:

    ```bash
    sudo ufw allow OpenSSH
    ```

    ![Allow SSH](/images/webserver/allowssh.png)

4. Verify the rules:

    ```bash
    sudo ufw show added
    ```

    ![Check Firewall Rules](/images/webserver/checkfirewall.png)

5. Enable the firewall:

    ```bash
    sudo ufw enable
    ```

    Press **y** to confirm.

    ![Enable Firewall](/images/webserver/enablefirewall.png)

### Conclusion

Your server is now secure and configured to allow only SSH connections. Regularly update your server and monitor firewall settings to maintain security.
