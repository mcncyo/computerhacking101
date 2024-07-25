---
title: "Install docker, Docker Compose, and portainer"
url: /docs/docker/install-docker-compose-portainer
image: "images/docker/InstallDockerPortainer/installdockerportainer.png"
date: 2023-02-14T19:54:29
lastmod: 2023-02-25T19:54:29

draft: false
author: "Chris Allen"
categories: ["docker", "portainer", "Linux"]
description: "Learn how to install Docker, Docker Compose, and Portainer on a Linux server to build, ship, and manage your distributed applications. Follow step-by-step instructions to update your package index, install Docker CE, start the Docker daemon, download and make Docker Compose executable, and run Portainer. With this guide, you'll be able to manage your Docker environment with ease."
---


Docker is a popular platform for building, shipping, and running distributed applications. Docker Compose is a tool for defining and running multi-container Docker applications. Portainer is a management tool for Docker that makes it easy to manage your containers, images, networks, and volumes. In this article, we'll show you how to install these tools on a Linux server.

## Prerequisites

Before we get started, make sure that you have a Linux server set up and that you have administrative access to that server.

## Updating the Package Index

Before installing Docker, it is important to update the package index on your server. You can do this by running the following command:

```bash
sudo apt-get update
```

## Installing Docker CE

Next, we'll install Docker CE (Community Edition) by running the following command:

```bash
sudo apt-get install docker-ce
```

## Starting the Docker Daemon

Once the installation is complete, we need to start the Docker daemon by running the following command:

```bash
sudo systemctl start docker
```

## Installing Docker Compose

To install Docker Compose, we need to download the latest version of the binary and make it executable. We can do this by running the following commands:

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## Verifying the Docker and Docker Compose Installations

To verify that the Docker and Docker Compose installations were successful, we can run the following commands:

```bash
docker --version
docker-compose --version
```

## Installing Portainer

To install Portainer, we can run the following command:

```bash
docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer
```

This command will download the Portainer image and run a container based on that image, exposing Portainer on port 9000.

## Accessing Portainer

Once the Portainer container is running, we can access the Portainer web interface by opening a web browser and navigating to <http://your_server_ip:9000>. We should see the Portainer login screen.

## Conclusion

In this article, we showed you how to install Docker, Docker Compose, and Portainer on a Linux server. You can now start using Docker to build, ship, and run your applications, and use Portainer to manage your Docker environment.

I hope you found this article helpful. If you have any questions or comments, please leave them in the comments section below. Thank you for reading!
