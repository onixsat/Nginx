#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -euo pipefail
#set -e
echo "Starting VPS setup for vps-3026dd85.vps.ovh.net..."

sudo rm -r /var/www/stream
sudo mv www/stream/ /var/www/
cp sites-available/* /etc/nginx/sites-available/
cp sites-enabled/* /etc/nginx/sites-enabled/

echo "Setting secure permissions..."
chown -R www-data:www-data /var/www/stream
chown -R www-data:www-data /var/www/html
chmod -R 777 /var/www/stream/*
chmod -R 777 /var/www/html/*
ufw allow 'Nginx Full'

ufw allow OpenSSH
ufw --force enable
sudo apt-get install iptables-persistent
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT

echo "Testing Nginx configuration..."
nginx -t

# Restart services
echo "Restarting services..."
sudo systemctl restart nginx
sudo systemctl restart php8.1-fpm

# Start and enable Nginx UI
sudo systemctl start nginx-ui
sudo systemctl enable nginx-ui
#systemctl restart nginx-ui

