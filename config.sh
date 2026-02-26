#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -euo pipefail
#set -e
echo "Starting VPS setup for vps-3026dd85.vps.ovh.net..."

sudo mv www/stream/ /var/www/
cp sites-available/* /etc/nginx/sites-available/
cp sites-enabled/* /etc/nginx/sites-enabled/

echo "Setting secure permissions..."
chown -R www-data:www-data /var/www/stream
chown -R www-data:www-data /var/www/html
chmod -R 777 /var/www/stream/*
chmod -R 777 /var/www/html/*


echo "Testing Nginx configuration..."
nginx -t

# Restart services
echo "Restarting services..."
systemctl restart nginx
systemctl restart php8.1-fpm

# Start and enable Nginx UI
ystemctl start nginx-ui
systemctl enable nginx-ui
 #   systemctl restart nginx-ui
    

# Configure SSH
#log_info "Configuring SSH..."
#systemctl restart ssh
#systemctl enable ssh

# Ensure sshd service is handled correctly (some systems use ssh, some use sshd)
#if systemctl list-unit-files | grep -q "^sshd.service"; then
#    systemctl start sshd
 #   systemctl enable sshd
#fi

# Final status check









sudo systemctl restart nginx

sudo systemctl start nginx-ui
sudo systemctl status nginx-ui
