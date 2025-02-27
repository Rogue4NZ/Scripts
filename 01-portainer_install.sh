#!/bin/bash

# Update package lists and upgrade installed packages
echo "Updating and upgrading system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "Installing curl, nano, and qemu-guest-agent..."
sudo apt install -y curl nano qemu-guest-agent

# Ensure qemu-guest-agent is enabled and running
echo "Enabling and starting qemu-guest-agent..."
sudo systemctl enable --now qemu-guest-agent

# Prompt for a username and add to root and sudo groups
echo "Enter the username to be added as root and sudo user:"
read USERNAME
sudo useradd -m -s /bin/bash -G sudo,root "$USERNAME"
sudo passwd "$USERNAME"

# Install Docker
echo "Installing Docker..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "Adding Docker repository..."
echo \  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \  $(. /etc/os-release && echo \"${UBUNTU_CODENAME:-$VERSION_CODENAME}\") stable" | \  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Prompt to install Portainer or Portainer Agent
echo "Do you want to install Portainer or Portainer Agent? (portainer/agent/no)"
read INSTALL_PORTAINER
if [ "$INSTALL_PORTAINER" == "portainer" ]; then
    echo "Installing Portainer..."
    sudo docker volume create portainer_data
    sudo docker run -d -p 8000:8000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
elif [ "$INSTALL_PORTAINER" == "agent" ]; then
    echo "Installing Portainer Agent..."
    sudo docker run -d -p 9001:9001 --name=portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent:latest
else
    echo "Skipping Portainer installation."
fi

echo "System update, package installation, user setup, Docker, and optional Portainer installation complete!"
