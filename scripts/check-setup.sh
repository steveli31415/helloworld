#!/bin/bash

# EC2 Setup Diagnostic Script
# This script checks the current state of your EC2 setup

echo "🔍 Checking EC2 Setup Status..."
echo "=================================="

# Check Docker installation
echo -n "Docker installed: "
if command -v docker &> /dev/null; then
    echo "✅ YES ($(docker --version))"
else
    echo "❌ NO"
fi

# Check Docker service
echo -n "Docker service running: "
if systemctl is-active --quiet docker; then
    echo "✅ YES"
else
    echo "❌ NO"
fi

# Check user in docker group
echo -n "User in docker group: "
if groups $USER | grep &>/dev/null '\bdocker\b'; then
    echo "✅ YES"
else
    echo "❌ NO"
fi

# Check if user can run docker without sudo
echo -n "Docker accessible without sudo: "
if docker ps &>/dev/null; then
    echo "✅ YES"
else
    echo "❌ NO (may need to logout/login)"
fi

# Check firewall status
echo -n "UFW firewall configured: "
if sudo ufw status | grep -q "Status: active"; then
    echo "✅ YES"
    echo "  Active rules:"
    sudo ufw status numbered | grep -E "(22|80|443)" | sed 's/^/    /'
else
    echo "❌ NO"
fi

# Check systemd service
echo -n "Helloworld systemd service: "
if [ -f /etc/systemd/system/helloworld-app.service ]; then
    echo "✅ EXISTS"
    echo -n "  Service enabled: "
    if systemctl is-enabled --quiet helloworld-app; then
        echo "✅ YES"
    else
        echo "❌ NO"
    fi
else
    echo "❌ NOT CREATED"
fi

# Check application directory
echo -n "Application directory: "
if [ -d /opt/helloworld ]; then
    echo "✅ EXISTS (/opt/helloworld)"
    echo "  Permissions: $(ls -ld /opt/helloworld | awk '{print $1, $3, $4}')"
else
    echo "❌ NOT CREATED"
fi

# Check if any containers are running
echo -n "Running containers: "
if docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null | grep -q helloworld-app; then
    echo "✅ helloworld-app is running"
    docker ps --filter name=helloworld-app --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    echo "❌ No helloworld-app container running"
fi

echo ""
echo "🔧 Quick Actions:"
echo "=================="

if ! command -v docker &> /dev/null; then
    echo "• Run setup script: ./scripts/setup-ec2.sh"
elif ! docker ps &>/dev/null; then
    echo "• Logout and login again for docker group access"
    echo "• Or run: sudo systemctl start docker"
elif ! docker ps --filter name=helloworld-app --format "{{.Names}}" | grep -q helloworld-app; then
    echo "• App not deployed yet - push code to GitHub to trigger CI/CD"
    echo "• Or manually run: docker run -d --name helloworld-app -p 80:5000 your-image"
else
    echo "• Setup looks complete! ✅"
    echo "• Test your app: curl http://localhost"
fi

echo ""
echo "📋 Useful Commands:"
echo "==================="
echo "• View container logs: docker logs helloworld-app"
echo "• Restart container: docker restart helloworld-app"
echo "• Check disk usage: df -h"
echo "• Monitor resources: htop"
echo "• View firewall rules: sudo ufw status numbered" 