+++
lastmod = "2025-07-03"
date = '2024-12-29T10:09:40-06:00'
draft = false
title = 'Install syncthing on linux'
description = "This will show you how to install synchthing on a Linux computer using apt."
+++

{{< youtube _PXNxpdAvJM >}}

## Step 1 add Syncthing repo to apt sources

Syncthing isn’t available to install using the default repo. So the first step is adding syncthing repo to our apt sources so we can install it on our computer. We need to open up a terminal and run the following command.

{{< tabs >}}

{{< tab "Linux" >}}
```bash
echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
```
{{< /tab >}}

{{< /tabs >}}
 ![adding-syncthing-repo](/images/syncthing/linux/addingsyncthing-repo.webp)

## Step 2 Installing curl

We must ensure we have curl installed to install the syncthing PGP key. All we need to do is the following command.

{{< tabs >}}

{{< tab "Linux" >}}
```bash
sudo apt install curl
```
{{< /tab >}}

{{< /tabs >}}

If it is already installed, you will get this message

 ![ifcurlinstall](/images/syncthing/linux/ifcurlinstall.webp)

If you need to install it, your screen will look like this one.

 ![instaling curl](/images/syncthing/linux/installing-curl.webp)

## Step 3 – Add syncthing's PGP Keys

The next step we need to do Is add the synching repo PGP key to our apt keys. Without this, apt will not trust synching repo and will not install syncthing.

{{< tabs >}}

{{< tab "Linux" >}}
```bash
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
```
{{< /tab >}}

{{< /tabs >}}

You should see the following if you added it correctly.

 ![adding-syncthing-apt](/images/syncthing/linux/adding-syncthing-apt-key.webp)

## Step 4 – Update apt’s database

We need to update the download package information from synching and your other sources on your computer. We do that by running the sudo apt update.

{{< tabs >}}

{{< tab "Linux" >}}
```bash
sudo apt update
```
{{< /tab >}}

{{< /tabs >}}

 ![sudo-apt-update](/images/syncthing/linux/running-sudo-apt-update.webp)

## Step 5 – Installing Syncthing

We finally get to install Syncthing on Linux. We just need to type the command below and press enter.

{{< tabs >}}

{{< tab "Linux" >}}
```bash
sudo apt install syncthing
```
{{< /tab >}}

{{< /tabs >}}
 ![install-syncthing](/images/syncthing/linux/install-syncthing.webp)

## Step 6 – Enable the Syncthing service

Now we got syncthing installed; we need to enable syncthing to start at boot using the systemctl command. But make sure you replace the username with your user name in the following order. But please don’t use root. It is a security issue.

{{< tabs >}}

{{< tab "Linux" >}}
```bash
sudo systemctl enable syncthing@username.service
```
{{< /tab >}}

{{< /tabs >}}
 ![enable-syncthing](/images/syncthing/linux/enable-syncthing.webp)

## Step 7 – Start syncthing service up

Let’s start syncthing up for the first time by running this command below. Make sure you change the user name to your user name.

{{< tabs >}}

{{< tab "Linux" >}}
```bash
sudo systemctl start syncthing@username.service
```
{{< /tab >}}

{{< /tabs >}}
 ![adding-syncthing-apt-key](/images/syncthing/linux/adding-syncthing-apt-key.webp)

## (Optional) setting syncthing so you can remotely connect to it

If you want to configure syncthing from another computer, you must change one line in the config file to allow access. It would be best if you had an editor. In this example, I am going to be using pico.

{{< tabs >}}

{{< tab "Linux" >}}
```bash
sudo pico .config/syncthing/config.xml
```
{{< /tab >}}

{{< /tabs >}}
 ![picoconfig](/images/syncthing/linux/picoconfig.webp)

Need to find 127.0.0.1:8384 It is under the <gui enabled=true” tls=”false” debuging=”false”>. We need to change it from 127.0.0.1:8384 to 0.0.0.0:8384
 (/images/syncthing/linux/changeipaddress.webp)

Then we need to restart the syncthing service by running this command. Make sure you change the username to your username again

{{< tabs >}}

{{< tab "Linux" >}}
```bash
sudo systemctl restart syncthing@username.service
```
{{< /tab >}}

{{< /tabs >}}
