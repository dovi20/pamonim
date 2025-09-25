# Deployment Guide - Linux Server Setup

This guide will help you deploy your React "Coming Soon" application to your Linux server with a domain.

## 📋 Prerequisites

- Linux server with domain configured
- Node.js 18+ installed on server
- Git installed on server
- Web server (Nginx/Apache) configured for your domain

## 🚀 Option 1: Manual Deployment

### Step 1: Server Setup
```bash
# Update your system
sudo apt update && sudo apt upgrade -y

# Install Node.js (if not already installed)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Git (if not already installed)
sudo apt-get install git

# Install PM2 for process management (optional but recommended)
npm install -g pm2
```

### Step 2: Upload Project to Server
```bash
# Create directory for your project
sudo mkdir -p /var/www/crm.pamonim.online
sudo chown $USER:$USER /var/www/crm.pamonim.online

# Clone your repository
cd /var/www/crm.pamonim.online
git clone https://github.com/dovi20/pamonim.git .
```

### Step 3: Install Dependencies and Build
```bash
# Install dependencies
npm install

# Build for production
npm run build
```

### Step 4: Configure Web Server (Nginx)
```bash
# Create Nginx configuration
sudo nano /etc/nginx/sites-available/crm.pamonim.online
```

Add this configuration:
```nginx
server {
    listen 80;
    server_name crm.pamonim.online;

    root /var/www/crm.pamonim.online/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Optional: Add SSL (Let's Encrypt)
    # listen 443 ssl;
    # ssl_certificate /etc/letsencrypt/live/crm.pamonim.online/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/crm.pamonim.online/privkey.pem;
}
```

```bash
# Enable the site
sudo ln -s /etc/nginx/sites-available/crm.pamonim.online /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### Step 5: Set Up Auto-Deployment (Optional)
Create a deployment script on your server:
```bash
# Create deployment script
sudo nano /var/www/crm.pamonim.online/deploy.sh
```

```bash
#!/bin/bash
cd /var/www/crm.pamonim.online
git pull origin master
npm install
npm run build
sudo systemctl reload nginx
```

```bash
# Make it executable
sudo chmod +x /var/www/crm.pamonim.online/deploy.sh
```

## 🚀 Option 2: GitHub Actions Auto-Deployment

### Step 1: Server Setup for SSH Access
```bash
# Generate SSH key on server
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Display public key
cat ~/.ssh/id_rsa.pub
```

### Step 2: GitHub Repository Setup
1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Add these secrets:
   - `SERVER_HOST`: Your server IP or domain
   - `SERVER_USER`: Your server username
   - `SERVER_SSH_KEY`: Private SSH key from your server

### Step 3: Configure Deployment
The GitHub Actions workflow will automatically deploy when you push to main branch.

## 🔄 Updating Your Site

### Manual Updates:
```bash
# On your server
cd /var/www/crm.pamonim.online
./deploy.sh
```

### Git-Based Updates:
```bash
# Make changes locally
git add .
git commit -m "Update coming soon page"
git push origin master
```

## 🛠️ Troubleshooting

### Common Issues:

1. **Permission Errors**
   ```bash
   sudo chown -R $USER:$USER /var/www/crm.pamonim.online
   ```

2. **Port 80 Already in Use**
   ```bash
   sudo netstat -tlnp | grep :80
   sudo systemctl stop apache2  # If Apache is running
   ```

3. **Node.js Version Issues**
   ```bash
   node --version  # Should be 18+
   npm --version   # Should be 9+
   ```

4. **Build Errors**
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   npm run build
   ```

## 📊 Monitoring

### Check Nginx Status:
```bash
sudo systemctl status nginx
sudo systemctl reload nginx
```

### Check Application Logs:
```bash
# If using PM2
pm2 logs

# Check Nginx error logs
sudo tail -f /var/log/nginx/your-domain.com_error.log
```

## 🔒 Security Recommendations

1. Set up SSL certificate with Let's Encrypt
2. Configure firewall: `sudo ufw allow 'Nginx Full'`
3. Use non-root user for deployment
4. Keep Node.js and dependencies updated
5. Monitor server resources

## 🎉 Next Steps

Once deployed, you can:
- Add SSL certificate for HTTPS
- Set up monitoring and alerts
- Configure backup strategies
- Add more content to your coming soon page
- Set up email notifications for updates

Your "Coming Soon" page is now live! 🚀