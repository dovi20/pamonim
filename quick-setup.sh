#!/bin/bash

# Quick Setup Script for Pamonim Server
# Run this on your server: root@pamonim.online

echo "🚀 Starting Pamonim Server Setup..."

# Update system
echo "📦 Updating system..."
apt update && apt upgrade -y

# Install essential tools
echo "🔧 Installing essential tools..."
apt install -y curl wget git htop nano ufw fail2ban

# Install Node.js 20.x
echo "🟢 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Install Nginx
echo "🌐 Installing Nginx..."
apt install -y nginx

# Install PM2
echo "⚙️ Installing PM2..."
npm install -g pm2

# Configure firewall
echo "🛡️ Configuring firewall..."
ufw enable
ufw allow 22
ufw allow 80
ufw allow 443

# Enable fail2ban
echo "🔒 Enabling fail2ban..."
systemctl enable fail2ban
systemctl start fail2ban

# Create application directory
echo "📁 Creating application directory..."
mkdir -p /var/www/crm.pamonim.online
cd /var/www/crm.pamonim.online

# Clone repository
echo "📥 Cloning repository..."
git clone https://github.com/dovi20/pamonim.git .

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build application
echo "🔨 Building application..."
npm run build

# Configure PM2
echo "⚙️ Configuring PM2..."
pm2 start ecosystem.config.js
pm2 startup
pm2 save

# Configure Nginx
echo "🌐 Configuring Nginx..."
cat > /etc/nginx/sites-available/crm.pamonim.online << 'EOF'
server {
    listen 80;
    server_name crm.pamonim.online;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/json;

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

        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Security: Hide Nginx version
    server_tokens off;
}
EOF

# Enable site
ln -s /etc/nginx/sites-available/crm.pamonim.online /etc/nginx/sites-enabled/

# Remove default site
rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
nginx -t && systemctl reload nginx

# Install SSL certificate
echo "🔒 Installing SSL certificate..."
apt install -y certbot python3-certbot-nginx
certbot --nginx -d crm.pamonim.online

# Enable auto-renewal
systemctl enable certbot.timer

echo "✅ Setup completed!"
echo ""
echo "🌐 Your site will be available at: https://crm.pamonim.online"
echo ""
echo "📊 Check status with:"
echo "pm2 status"
echo "systemctl status nginx"
echo "certbot certificates"