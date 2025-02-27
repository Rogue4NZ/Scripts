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

# Install Pi-hole with Unbound
echo "Installing Pi-hole and Unbound..."
sudo apt install -y unbound
curl -sSL https://install.pi-hole.net | bash

# Configure Unbound for Pi-hole
echo "Configuring Unbound for Pi-hole..."
cfg_file="/etc/unbound/unbound.conf.d/pi-hole.conf"
echo "server:" | sudo tee "$cfg_file"
echo "    interface: 127.0.0.1" | sudo tee -a "$cfg_file"
echo "    access-control: 127.0.0.0/8 allow" | sudo tee -a "$cfg_file"
echo "    do-ip4: yes" | sudo tee -a "$cfg_file"
echo "    do-ip6: no" | sudo tee -a "$cfg_file"
echo "    do-udp: yes" | sudo tee -a "$cfg_file"
echo "    do-tcp: yes" | sudo tee -a "$cfg_file"
echo "    harden-dnssec-stripped: yes" | sudo tee -a "$cfg_file"
echo "    use-caps-for-id: no" | sudo tee -a "$cfg_file"
echo "    edns-buffer-size: 1232" | sudo tee -a "$cfg_file"

echo "Restarting Unbound..."
sudo systemctl restart unbound

echo "System update, package installation, user setup, Docker, Pi-hole, and Unbound installation complete!"
