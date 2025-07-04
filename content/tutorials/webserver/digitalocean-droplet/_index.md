+++
lastmod = "2025-07-03"
date = '2024-12-30'
draft = false
title = 'Creating a Droplet on DigitalOcean'
description = "Learn how to set up a production-ready server step by step."
+++

Deploying a Virtual Private Server (VPS) isn’t as hard as it might seem. In this guide, I’ll walk you through the process of setting up a server correctly. I'll be using Pop!_OS (built on Ubuntu) for my main computer and Ubuntu Server for my VPS. For this tutorial, I’ve chosen [DigitalOcean](https://m.do.co/c/216b0d40d6f4) as my VPS provider.

### Step 1: Set Up a DigitalOcean Account  
Start by creating an account on [DigitalOcean](https://m.do.co/c/216b0d40d6f4). It’s a simple process, and with my [referral link](https://m.do.co/c/216b0d40d6f4), you’ll receive $200 in credit to use on DigitalOcean for 60 days.

### Step 2: Generate an SSH Key  
You’ll need an SSH key for secure authentication. If you don’t already have one, follow [these instructions]({{% ref "/tutorials/ssh/createasshkey/" %}}) to create an SSH key.

### Step 3: Create a Droplet  
Once your account is set up, navigate to the DigitalOcean dashboard and click on **Create** > **Droplets**. DigitalOcean refers to their VPS instances as “Droplets.”

![Creating a Droplet](/images/webserver/create_a_droplet.png)

#### Select Data Center  
Choose a data center closest to you or your target audience.

#### Choose an Image  
Select **Ubuntu 24.10 x64** as your operating system.

#### Choose a Plan  
For small websites, the $4/month plan is sufficient. This plan includes:  
- 1 CPU  
- 512 MB of RAM  
- 10 GB SSD  
- 500 GB of transfer bandwidth  

![selecting a plan](/images/webserver/selectingaplan.png)

If your needs grow, you can always upgrade later.

#### Authentication Method  
Use **SSH key** authentication—it’s more secure than using a password. To add your SSH key:  
1. Open a terminal on your main desktop and run the following command:  
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```  
   ![SSH Public Key in Terminal](/images/webserver/sshpublic.png)

2. Copy the output starting with `ssh-ed25519` and ending with your email address.  

3. Paste it into the **New SSH Key** section on the DigitalOcean dashboard, name it, and click **Add SSH Key**.  
   ![Adding an SSH Key](/images/webserver/addsshkey.png)

### Step 4: Finalize and Create Your Droplet  
Scroll down, change the hostname to something meaningful, and click **Create Droplet**.  
![Changing Hostname](/images/webserver/changehostname.png)

### What’s Next?  
Congratulations! You’ve successfully created your first Droplet. Now, you can begin configuring it for your specific needs.