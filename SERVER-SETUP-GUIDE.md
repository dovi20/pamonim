# 🚀 Complete Server Setup Guide - Production Ready

This comprehensive guide will help you set up a production-ready Linux server with PM2, Nginx, SSL, and all security best practices for your Pamonim application.

## 📋 Prerequisites

- Fresh Ubuntu 22.04 LTS server
- Domain name: `crm.pamonim.online`
- GitHub repository: `https://github.com/dovi20/pamonim`

## 🛡️ Step 1: Initial Server Security & Setup

### 1.1 Update System
```bash
# Connect to your server
ssh your-username@your-server-ip

# Update system
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y curl wget git htop nano ufw fail2ban
```

### 1.2 Create Dedicated User
```bash
# Create pamonim user
sudo adduser pamonim --gecos "Pamonim Application User" --disabled-password
echo "pamonim:YOUR_SECURE_PASSWORD" | sudo chpasswd

# Add to sudo group
sudo usermod -aG sudo pamonim

# Switch to pamonim user
su - pamonim
cd ~
```

### 1.3 Configure Firewall
```bash
# Enable UFW firewall
sudo ufw enable

# Allow SSH (change 22 to your SSH port if modified)
sudo ufw allow 22

# Allow HTTP and HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Check firewall status
sudo ufw status
```

### 1.4 Install Fail2Ban for SSH protection
```bash
sudo apt install -y fail2ban

# Configure fail2ban for SSH
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## 🟢 Step 2: Node.js & PM2 Setup

### 2.1 Install Node.js (Latest LTS)
```bash
# Install Node.js 20.x (latest LTS)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version  # Should be v20.x.x
npm --version   # Should be 9.x.x
```

### 2.2 Install PM2 Globally
```bash
# Install PM2 globally
sudo npm install -g pm2

# Configure PM2 to start on boot
pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u pamonim --hp /home/pamonim

# Save PM2 configuration
pm2 save
```

### 2.3 Create PM2 Ecosystem File
```bash
# Create ecosystem file for PM2
nano ecosystem.config.js
```

Add this configuration:
```javascript
module.exports = {
  apps: [{
    name: 'pamonim',
    script: 'serve',
    env: {
      PM2_SERVE_PATH: './dist',
      PM2_SERVE_PORT: 3000,
      PM2_SERVE_HOMEPAGE: '/index.html'
    }
  }]
};
```

## 🌐 Step 3: Nginx Configuration

### 3.1 Install Nginx
```bash
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

### 3.2 Configure Nginx Sites
```bash
# Remove default site
sudo rm /etc/nginx/sites-enabled/default

# Create site configuration
sudo nano /etc/nginx/sites-available/crm.pamonim.online
```

Add this configuration:
```nginx
server {
    listen 80;
    server_name crm.pamonim.online;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Main location
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Security: Hide Nginx version
    server_tokens off;

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### 3.3 Enable Site and Test
```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/crm.pamonim.online /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Check status
sudo systemctl status nginx
```

## 🔒 Step 4: SSL Certificate with Let's Encrypt

### 4.1 Install Certbot
```bash
sudo apt install -y certbot python3-certbot-nginx
```

### 4.2 Get SSL Certificate
```bash
# Get SSL certificate
sudo certbot --nginx -d crm.pamonim.online

# Test automatic renewal
sudo certbot renew --dry-run
```

### 4.3 Configure Auto-Renewal
```bash
# Enable auto-renewal
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Check timer status
sudo systemctl status certbot.timer
```

### 4.4 Update Nginx for SSL
The SSL configuration will be automatically added by Certbot, but let's verify:
```bash
sudo nano /etc/nginx/sites-available/crm.pamonim.online
```

Should include:
```nginx
server {
    listen 443 ssl http2;
    server_name crm.pamonim.online;

    ssl_certificate /etc/letsencrypt/live/crm.pamonim.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/crm.pamonim.online/privkey.pem;

    # SSL Security
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;

    # SSL Session Cache
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # ... rest of config
}
```

## 🚀 Step 5: Deploy Application

### 5.1 Clone and Setup Application
```bash
# Navigate to web directory
cd /var/www

# Create application directory
sudo mkdir -p crm.pamonim.online
sudo chown pamonim:pamonim crm.pamonim.online

# Clone repository
cd crm.pamonim.online
git clone https://github.com/dovi20/pamonim.git .
```

### 5.2 Install Dependencies and Build
```bash
# Install dependencies
npm install

# Build application
npm run build

# Verify build
ls -la dist/
```

### 5.3 Start with PM2
```bash
# Start application with PM2
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Check status
pm2 status
pm2 logs pamonim
```

### 5.4 Test Application
```bash
# Test if app is running
curl -I http://localhost:3000

# Check Nginx is serving
curl -I http://localhost

# Test external access
curl -I http://crm.pamonim.online
```

## 📊 Step 6: Monitoring & Maintenance

### 6.1 PM2 Monitoring
```bash
# PM2 commands
pm2 status              # Check all apps
pm2 logs pamonim        # View logs
pm2 monit               # Real-time monitoring
pm2 restart pamonim     # Restart app
pm2 stop pamonim        # Stop app
pm2 delete pamonim      # Delete app
```

### 6.2 Nginx Monitoring
```bash
# Check Nginx status
sudo systemctl status nginx

# View access logs
sudo tail -f /var/log/nginx/crm.pamonim.online_access.log

# View error logs
sudo tail -f /var/log/nginx/crm.pamonim.online_error.log

# Test configuration
sudo nginx -t
```

### 6.3 System Monitoring
```bash
# System resource usage
htop

# Disk usage
df -h

# Memory usage
free -h

# Network connections
ss -tlnp
```

### 6.4 Log Rotation
```bash
# Configure logrotate for PM2
sudo nano /etc/logrotate.d/pm2-pamonim
```

Add:
```
/home/pamonim/.pm2/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 pamonim pamonim
}
```

## 🔧 Step 7: Backup & Security

### 7.1 Automated Backups
```bash
# Install backup tools
sudo apt install -y duplicity

# Create backup script
nano ~/backup.sh
```

Add:
```bash
#!/bin/bash
# Backup script for Pamonim

BACKUP_DIR="/home/pamonim/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup application files
tar -czf $BACKUP_DIR/pamonim_app_$DATE.tar.gz /var/www/crm.pamonim.online

# Backup database (if applicable)
# mysqldump -u username -p password database > $BACKUP_DIR/db_$DATE.sql

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.tar.gz" -type f -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/pamonim_app_$DATE.tar.gz"
```

```bash
# Make executable and run
chmod +x ~/backup.sh
./backup.sh
```

### 7.2 Security Hardening
```bash
# Disable root SSH login
sudo nano /etc/ssh/sshd_config
```

Change:
```bash
PermitRootLogin no
PasswordAuthentication no
```

```bash
# Restart SSH
sudo systemctl restart ssh

# Set up automatic security updates
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

## 🔄 Step 8: Update Process

### 8.1 Manual Updates
```bash
# On your server
cd /var/www/crm.pamonim.online

# Pull latest changes
git pull origin master

# Install new dependencies
npm install

# Rebuild application
npm run build

# Restart with PM2
pm2 restart pamonim

# Reload Nginx
sudo systemctl reload nginx
```

### 8.2 Automatic Updates (GitHub Actions)
The GitHub Actions workflow will automatically deploy when you push to master branch.

## 🛠️ Troubleshooting

### Common Issues:

#### 1. PM2 Application Won't Start
```bash
# Check logs
pm2 logs pamonim

# Check if port is in use
sudo netstat -tlnp | grep 3000

# Kill process if needed
sudo kill -9 PROCESS_ID
```

#### 2. Nginx 502 Bad Gateway
```bash
# Check if PM2 app is running
pm2 status

# Check Nginx error logs
sudo tail -f /var/log/nginx/crm.pamonim.online_error.log

# Restart services
pm2 restart pamonim
sudo systemctl reload nginx
```

#### 3. SSL Certificate Issues
```bash
# Check certificate status
sudo certbot certificates

# Renew certificate
sudo certbot renew

# Test SSL
curl -I https://crm.pamonim.online
```

#### 4. High Memory Usage
```bash
# Check PM2 memory
pm2 monit

# Restart application
pm2 restart pamonim

# Set memory limit in ecosystem.config.js
module.exports = {
  apps: [{
    name: 'pamonim',
    script: 'serve',
    env: {
      PM2_SERVE_PATH: './dist',
      PM2_SERVE_PORT: 3000,
      PM2_SERVE_HOMEPAGE: '/index.html'
    },
    max_memory_restart: '200M'  // Restart if exceeds 200MB
  }]
};
```

## 📈 Performance Optimization

### 8.1 PM2 Configuration
```javascript
module.exports = {
  apps: [{
    name: 'pamonim',
    script: 'serve',
    instances: 'max',  // Use all CPU cores
    exec_mode: 'cluster',  // Enable cluster mode
    env: {
      PM2_SERVE_PATH: './dist',
      PM2_SERVE_PORT: 3000,
      PM2_SERVE_HOMEPAGE: '/index.html'
    },
    max_memory_restart: '200M',
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
};
```

### 8.2 Nginx Optimization
```nginx
# Add to http block in /etc/nginx/nginx.conf
http {
    # ... existing config

    # Connection limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;

    # File upload size
    client_max_body_size 50M;
}
```

## 🎉 Final Verification

### Test Your Setup:
```bash
# Test HTTP
curl -I http://crm.pamonim.online

# Test HTTPS
curl -I https://crm.pamonim.online

# Test application
curl https://crm.pamonim.online | head -20

# Check SSL certificate
curl -vI https://crm.pamonim.online 2>&1 | grep -i ssl
```

### Check All Services:
```bash
# System services
sudo systemctl status nginx
sudo systemctl status certbot.timer

# PM2 application
pm2 status
pm2 logs pamonim

# Security
sudo ufw status
sudo systemctl status fail2ban
```

## 🚀 You're Done!

Your server is now production-ready with:
- ✅ **Security hardened** with firewall and fail2ban
- ✅ **PM2 process manager** for reliable app management
- ✅ **Nginx reverse proxy** with SSL termination
- ✅ **SSL certificate** from Let's Encrypt
- ✅ **Monitoring and logging** configured
- ✅ **Automated backups** and maintenance
- ✅ **Performance optimized** for production

Your Pamonim application is now live at `https://crm.pamonim.online` with enterprise-level reliability and security! 🎉