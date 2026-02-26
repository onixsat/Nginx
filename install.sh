#!/bin/bash
set -euo pipefail
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Error handler
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Script failed with exit code $exit_code at line $LINENO"
    fi
    echo $exit_code
}

trap cleanup ERR

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root or with sudo"
    exit 1
fi

log_info "Starting VPS setup for vps-3026dd85.vps.ovh.net..."

# Update system packages
log_info "Updating package lists and upgrading system..."
apt-get update -y
apt-get upgrade -y

# Add PHP PPA BEFORE installing PHP packages
log_info "Adding Ondrej PHP PPA..."
add-apt-repository ppa:ondrej/php -y
apt-get update -y

# Install all packages in a single transaction where possible
log_info "Installing required packages..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ufw \
    net-tools \
    nginx \
    php8.1-fpm \
    php8.1-mcrypt \
    openssh-server \
    dos2unix \
    certbot \
    python3-certbot-nginx \
    git \
    curl

sudo apt-get install iptables-persistent

# Note: mcrypt is deprecated in PHP 8.1. If you need encryption, consider sodium or openssl
log_warn "mcrypt is deprecated in PHP 8.1+. Consider using php8.1-sodium instead."

# Configure UFW (Uncomplicated Firewall)
log_info "Configuring UFW..."
ufw allow 'Nginx Full'
ufw allow OpenSSH
ufw --force enable

log_info "Configuring iptables..."
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT

# Obtain SSL certificate
log_info "Obtaining SSL certificate for vps-3026dd85.vps.ovh.net..."
if ! certbot certificates | grep -q "vps-3026dd85.vps.ovh.net"; then
    certbot --nginx -d vps-3026dd85.vps.ovh.net -m explodgf@gmail.com --agree-tos --no-eff-email --non-interactive
else
    log_warn "Certificate already exists, skipping..."
fi

# Install Nginx UI
log_info "Installing Nginx UI..."
if ! command -v nginx-ui &> /dev/null; then
    bash -c "$(curl -fsSL https://cloud.nginxui.com/install.sh)" @ install
else
    log_warn "Nginx UI already installed, skipping..."
fi

# Clone and configure Nginx configurations
log_info "Setting up custom Nginx configurations..."
REPO_DIR="/tmp/nginx-setup-repo"
if [ -d "$REPO_DIR" ]; then
    rm -rf "$REPO_DIR"
fi










# Restart services
log_info "Restarting services..."
systemctl restart nginx
systemctl restart php8.1-fpm

# Start and enable Nginx UI
if systemctl list-unit-files | grep -q nginx-ui; then
    systemctl start nginx-ui
    systemctl enable nginx-ui
    log_info "Nginx UI started and enabled"
else
    log_warn "nginx-ui service not found"
fi

# Configure SSH
#log_info "Configuring SSH..."
#systemctl restart ssh
#systemctl enable ssh

# Ensure sshd service is handled correctly (some systems use ssh, some use sshd)
#if systemctl list-unit-files | grep -q "^sshd.service"; then
#    systemctl start sshd
#    systemctl enable sshd
#fi

# Final status check
log_info "Performing final status checks..."
systemctl is-active --quiet nginx && log_info "Nginx is running" || log_error "Nginx failed to start"
systemctl is-active --quiet php8.1-fpm && log_info "PHP-FPM is running" || log_error "PHP-FPM failed to start"

if systemctl is-active --quiet nginx-ui 2>/dev/null; then
    log_info "Nginx UI is running"
else
    log_warn "Nginx UI status check failed"
fi

echo "Configurar nginx files..."

sudo rm -r /var/www/stream
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
sudo systemctl restart nginx
sudo systemctl restart php8.1-fpm

# Start and enable Nginx UI
sudo systemctl start nginx-ui
sudo systemctl enable nginx-ui
#systemctl restart nginx-ui

echo "OK"
