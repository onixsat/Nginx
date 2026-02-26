#!/bin/bash

# Exit immediately if a command exits with a non-zero status
#set -euo pipefail
set -e
# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
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
    exit $exit_code
}

trap cleanup ERR

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root or with sudo"
    exit 1
fi

log_info "Starting VPS setup for vps-3026dd85.vps.ovh.net..."

# Update system packages


sudo git clone https://github.com/onixsat/Nginx.git
cd Nginx

# Create web directories
mkdir -p /var/www/stream
mkdir -p /var/www/html

# Move stream content if it exists
if [ -d "www/stream" ]; then
    cp -r www/stream/* /var/www/stream/
    log_info "Stream content copied to /var/www/stream/"
else
    log_warn "www/stream directory not found in repo"
fi

# Copy Nginx site configurations
if [ -d "sites-available" ]; then
    cp sites-available/* /etc/nginx/sites-available/
    log_info "Sites-available configurations copied"
fi

if [ -d "sites-enabled" ]; then
    cp sites-enabled/* /etc/nginx/sites-enabled/
    log_info "Sites-enabled configurations copied"
fi

# Set proper permissions (avoiding 777 for security)
log_info "Setting secure permissions..."
chown -R www-data:www-data /var/www/stream
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/stream
chmod -R 755 /var/www/html

# Remove default site if custom one exists
if [ -f "/etc/nginx/sites-available/default" ] && [ -f "/etc/nginx/sites-available/nginx-ui.conf" ]; then
    rm -f /etc/nginx/sites-enabled/default
    log_info "Removed default Nginx site"
fi

# Cleanup temporary repo
#rm -rf "$REPO_DIR"

# Test Nginx configuration
log_info "Testing Nginx configuration..."
nginx -t

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
log_info "Configuring SSH..."
systemctl restart ssh
systemctl enable ssh

# Ensure sshd service is handled correctly (some systems use ssh, some use sshd)
if systemctl list-unit-files | grep -q "^sshd.service"; then
    systemctl start sshd
    systemctl enable sshd
fi

# Final status check
log_info "Performing final status checks..."
systemctl is-active --quiet nginx && log_info "Nginx is running" || log_error "Nginx failed to start"
systemctl is-active --quiet php8.1-fpm && log_info "PHP-FPM is running" || log_error "PHP-FPM failed to start"

if systemctl is-active --quiet nginx-ui 2>/dev/null; then
    log_info "Nginx UI is running"
else
    log_warn "Nginx UI status check failed"
fi

# Display configuration files for manual editing (non-interactive)
log_info "Setup complete! Manual configuration may be required for:"
echo "  - /etc/nginx/sites-available/default"
echo "  - /etc/nginx/sites-available/nginx-ui.conf"
echo ""
log_info "To edit these files, use:"
echo "  sudo nano /etc/nginx/sites-available/default"
echo "  sudo nano /etc/nginx/sites-available/nginx-ui.conf"
echo ""
log_info "VPS setup completed successfully!"

exit 0
