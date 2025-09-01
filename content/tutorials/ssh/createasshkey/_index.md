---
title: "Creating a ssh key"
# meta title
meta_title: "Creating a ssh key"
# meta description
description: "In this tutorial we will show you how to create a ssh key"
# save as draft
draft: false
---

Creating an `ed25519` key pair for SSH in Linux is straightforward. Follow these steps:

## 1. Open a Terminal
Open a terminal on your Linux system.

## 2. Generate the Key Pair
Use the `ssh-keygen` command to create an `ed25519` key. Run the following command:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

> Replace `"your_email@example.com"` with an appropriate label for the key. This is optional and typically used to identify the key.

## 3. Specify File Location
When prompted to specify a file to save the key:
- Press `Enter` to save it in the default location (`~/.ssh/id_ed25519`), or
- Specify a different path if needed.

## 4. Set a Passphrase (Optional)
You'll be asked to enter a passphrase. This adds an extra layer of security. 
- Leave it empty for no passphrase (**not recommended for security reasons**), or
- Set a strong passphrase.

## 5. Key Generation Complete
Once complete, the keys will be saved in the specified location. You should see output like this:

```plaintext
Your identification has been saved in /home/username/.ssh/id_ed25519
Your public key has been saved in /home/username/.ssh/id_ed25519.pub
```