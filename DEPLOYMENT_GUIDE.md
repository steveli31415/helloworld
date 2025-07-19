# CI/CD Deployment Guide

This guide will walk you through setting up a complete CI/CD pipeline for your Flask Hello World application using GitHub Actions, Docker, and AWS EC2.

## Overview

The pipeline will:
1. ✅ Run tests on every push/PR
2. 🐳 Build Docker image
3. 📦 Push to Docker Hub
4. 🚀 Deploy to EC2 instance
5. 🔄 Auto-restart application

## Prerequisites

- AWS Account with EC2 access
- Docker Hub account
- GitHub repository
- SSH key pair for EC2 access

## Step 1: Set Up EC2 Instance

### 1.1 Launch EC2 Instance
1. Go to AWS EC2 Console
2. Click "Launch Instance"
3. Configure:
   - **AMI**: Debian 12 (debian-12-amd64-20250316-2053)
   - **Instance Type**: t2.micro (free tier) or larger
   - **Key Pair**: Create or select existing key pair
   - **Security Group**: Allow SSH (22), HTTP (80), HTTPS (443)
   - **Storage**: 8GB+ (default is fine)

### 1.2 Connect to EC2 Instance
```bash
# Replace with your key file and instance public IP
ssh -i /path/to/your-key.pem admin@your-ec2-public-ip
```

### 1.3 Set Up EC2 Environment
```bash
# Make setup script executable and run it
chmod +x scripts/setup-ec2.sh scripts/check-setup.sh
./scripts/setup-ec2.sh

# If script was interrupted (e.g., EC2 restart), run it again - it's safe!
# The script is idempotent and will skip completed steps

# Check setup status
./scripts/check-setup.sh

# Logout and login again for Docker group changes (if needed)
exit
ssh -i /path/to/your-key.pem admin@your-ec2-public-ip

# Test Docker installation
docker run hello-world
```

## Step 2: Configure Docker Hub

### 2.1 Create Docker Hub Repository
1. Go to [Docker Hub](https://hub.docker.com)
2. Create account or login
3. Create new repository: `helloworld-flask`
4. Set visibility (public recommended for learning)

### 2.2 Get Docker Hub Credentials
- Username: Your Docker Hub username
- Password: Create access token in Docker Hub settings → Security → Access Tokens

## Step 3: Configure GitHub Secrets

In your GitHub repository, go to Settings → Secrets and variables → Actions → New repository secret:

### Required Secrets:
```
DOCKER_USERNAME=your-docker-hub-username
DOCKER_PASSWORD=your-docker-hub-access-token
EC2_HOST=your-ec2-public-ip
EC2_USERNAME=admin
EC2_SSH_KEY=your-private-key-content
```

### 3.1 Adding SSH Key Secret
For `EC2_SSH_KEY`, copy your entire private key file content:
```bash
# On your local machine
cat /path/to/your-key.pem
```
Copy the entire output (including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`)

## Step 4: Deploy Your Application

### 4.1 Push to GitHub
```bash
# Add all files
git add .

# Commit changes
git commit -m "Add CI/CD pipeline"

# Push to main branch
git push origin main
```

### 4.2 Monitor Deployment
1. Go to your GitHub repository
2. Click "Actions" tab
3. Watch the workflow progress:
   - ✅ Test job
   - 🏗️ Build and push job
   - 🚀 Deploy job

### 4.3 Verify Deployment
Once the pipeline completes:
```bash
# Check if container is running on EC2
ssh -i /path/to/your-key.pem admin@your-ec2-public-ip
docker ps

# Test the application
curl http://your-ec2-public-ip
# Should return: Hello, AWS!
```

## Step 5: Access Your Application

Your Flask app will be available at:
- `http://your-ec2-public-ip` (port 80)

## Troubleshooting

### Common Issues:

1. **Script interrupted by EC2 restart**
   ```bash
   # The setup script is idempotent - safe to run multiple times
   ./scripts/setup-ec2.sh
   
   # Check what's already configured
   ./scripts/check-setup.sh
   ```

2. **Docker permission denied**
   ```bash
   # On EC2, ensure user is in docker group
   sudo usermod -aG docker $USER
   # Then logout and login again
   ```

3. **GitHub Actions fails to connect to EC2**
   - Verify EC2 security group allows SSH (port 22)
   - Check SSH key format in GitHub secrets
   - Ensure EC2 instance is running

4. **Docker Hub authentication fails**
   - Verify Docker Hub credentials in GitHub secrets
   - Use access token instead of password

5. **Application not accessible**
   - Check EC2 security group allows HTTP (port 80)
   - Verify container is running: `docker ps`
   - Check container logs: `docker logs helloworld-app`

### Useful Commands for EC2:

```bash
# Check overall setup status
./scripts/check-setup.sh

# Check container status
docker ps -a

# View container logs
docker logs helloworld-app

# Restart container manually
docker restart helloworld-app

# Pull latest image manually
docker pull your-username/helloworld-flask:latest

# Check system resources
htop
df -h

# Re-run setup script (safe - idempotent)
./scripts/setup-ec2.sh
```

## Security Best Practices

1. **EC2 Security Group**: Only allow necessary ports
2. **SSH Keys**: Use strong key pairs, rotate regularly
3. **Docker Images**: Keep base images updated
4. **Secrets**: Never commit secrets to code
5. **EC2 Instance**: Keep system updated with `sudo apt update && sudo apt upgrade`

## Scaling and Improvements

For production use, consider:
- **Load Balancer**: AWS ALB for multiple instances
- **Auto Scaling**: EC2 Auto Scaling Groups
- **Container Orchestration**: ECS or EKS
- **Database**: RDS for persistent data
- **Monitoring**: CloudWatch, Datadog, etc.
- **SSL Certificate**: AWS Certificate Manager
- **CDN**: CloudFront for static assets

## Cost Optimization

- Use **t2.micro** (free tier eligible)
- **Stop instances** when not needed
- **Monitor billing** in AWS Console
- Consider **Spot Instances** for development

## Next Steps

1. Add more comprehensive tests
2. Implement health checks
3. Add environment-specific configurations
4. Set up monitoring and alerting
5. Implement blue-green deployments
6. Add database integration
7. Set up staging environment

---

🎉 **Congratulations!** You now have a complete CI/CD pipeline for your Flask application! 