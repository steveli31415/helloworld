#!/bin/bash

# EC2 Setup Script for Flask App Deployment
# Run this script on your EC2 instance (Debian 12)
# 
# This script is idempotent - safe to run multiple times
# It will skip steps that are already completed

set -e

echo "🚀 Setting up EC2 instance for Flask app deployment..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "🐳 Installing Docker..."

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    echo "Docker is already installed, checking version..."
    docker --version
else
    echo "Installing Docker dependencies..."
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

    # Add Docker's official GPG key (only if not exists)
    if [ ! -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
        echo "Adding Docker GPG key..."
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    else
        echo "Docker GPG key already exists, skipping..."
    fi

    # Set up the stable repository (only if not exists)
    if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
        echo "Adding Docker repository..."
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    else
        echo "Docker repository already configured, skipping..."
    fi

    # Install Docker Engine
    echo "Installing Docker Engine..."
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
fi

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group (requires logout/login to take effect)
if groups $USER | grep &>/dev/null '\bdocker\b'; then
    echo "User $USER is already in docker group"
else
    echo "Adding user $USER to docker group..."
    sudo usermod -aG docker $USER
    echo "⚠️  Please logout and login again for Docker group changes to take effect"
fi

# Install additional tools
echo "🛠️  Installing additional tools..."
sudo apt install -y htop git curl wget unzip

# Configure firewall (optional - adjust based on your security requirements)
echo "🔥 Configuring firewall..."

# Install ufw if not present
if ! command -v ufw &> /dev/null; then
    echo "Installing UFW firewall..."
    sudo apt update
    sudo apt install -y ufw
fi

# Check if ufw is already enabled
if sudo ufw status | grep -q "Status: active"; then
    echo "UFW firewall is already active"
else
    echo "Configuring UFW firewall rules..."
    sudo ufw allow ssh
    sudo ufw allow 80
    sudo ufw allow 443
    echo "y" | sudo ufw enable
fi

# Ensure rules are present (ufw allow is idempotent)
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443

# Create application directory
echo "📁 Creating application directory..."
sudo mkdir -p /opt/helloworld
sudo chown $USER:$USER /opt/helloworld

# Create systemd service for auto-restart (optional)
if [ -f /etc/systemd/system/helloworld-app.service ]; then
    echo "Systemd service already exists, skipping creation..."
else
    echo "🔄 Creating systemd service..."
    sudo tee /etc/systemd/system/helloworld-app.service > /dev/null <<EOF
[Unit]
Description=Hello World Flask App
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker start helloworld-app
ExecStop=/usr/bin/docker stop helloworld-app
User=$USER

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable helloworld-app
fi

echo "✅ EC2 setup complete!"
echo ""
echo "Next steps:"
echo "1. Logout and login again for Docker group changes"
echo "2. Test Docker: docker run hello-world"
echo "3. Configure GitHub secrets for deployment"
echo "4. Push your code to trigger the CI/CD pipeline" 