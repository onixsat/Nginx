#!/bin/bash
set -eu #set -euo pipefail
TIMEZONE=Africa/Lagos
export LC_ALL=en_US.UTF-8
add-apt-repository --yes universe
timedatectl set-timezone ${TIMEZONE} 
apt --yes install locales-all

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
    local code=$?
    if [ $code -ne 0 ]; then
        log_error "Script failed with exit code $code at line $LINENO"
    fi
    echo $code
}
trap cleanup ERR

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root or with sudo"
    exit 1
fi

log_info "Starting VPS setup for vps-3026dd85.vps.ovh.net..."




echo "Criar novo sudo user ospro..."
USERNAME=ospro
# Add the new user (and give them sudo privileges).
useradd --create-home --shell "/bin/bash" --groups sudo "${USERNAME}"
# Force a password to be set for the new user the first time they log in.
passwd --delete "${USERNAME}" 
chage --lastday 0 "${USERNAME}"
# Copy the SSH keys from the root user to the new user.
rsync --archive --chown=${USERNAME}:${USERNAME} /root/.ssh /home/${USERNAME}

read -s -n 1 -p "Press any key to continuar!"

# Set $chostname to current hostname 
chostname=$(cat /etc/hostname)
hostname="vps-3026dd85.vps.ovh.net"
# Display current hostname
echo "Current hostname1 is '$chostname'"
echo "Current hostname2 is '$hostname'"

# Set $newhostname as new hostname 
echo "Enter new hostname: "
read newhostname

# Change the hostname value in /etc/hostname and /etc/hosts files
sudo sed -i "s/$chostname/$newhostname/g" /etc/hostname
sudo sed -i "s/$chostname/$newhostname/g" /etc/hosts
sudo sed -i "s/$hostname/$newhostname/g" /etc/hosts

# Display new hostname
echo "Your new hostname is $newhostname"

read -s -n 1 -p "Press any key to continuar 1!"

# Update system packages
log_info "Updating package lists and upgrading system..."
apt-get update -y
apt-get upgrade -y
apt --yes -o Dpkg::Options::="--force-confnew" upgrade

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
    iptables-persistent \
    fail2ban \
    curl

read -s -n 1 -p "Press any key to continuar 2!"

# Configure UFW (Uncomplicated Firewall)
log_info "Configuring UFW..."
ufw allow 22
ufw allow 80/tcp 
ufw allow 443/tcp 
ufw allow 21/tcp 
ufw allow 8080/tcp 
ufw allow 8443/tcp 
ufw allow 9000/tcp 
sudo ufw allow 'Nginx Full'
sudo ufw allow OpenSSH
sudo ufw --force enable

log_info "Configuring iptables..."
sudo iptables -I INPUT 1 -p tcp --dport 21 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 9000 -j ACCEPT

read -s -n 1 -p "Press any key to continuar 3!"

# Obtain SSL certificate
log_info "Obtaining SSL certificate for cloudflare..."
sudo mv ospro.pt.pem /etc/ssl/certs/
sudo mv ospro.pt.key /etc/ssl/private/
sudo chmod 644 /etc/ssl/certs/ospro.pt.pem
sudo chmod 640 /etc/ssl/private/ospro.pt.key

read -s -n 1 -p "Press any key to continuar 4!"

# Install Nginx UI
log_info "Installing Nginx UI..."
if ! command -v nginx-ui &> /dev/null; then
    bash -c "$(curl -fsSL https://cloud.nginxui.com/install.sh)" @ install
else
    log_warn "Nginx UI already installed, skipping..."
fi

read -s -n 1 -p "Press any key to continuar 5!"

echo "Configurar nginx files..."
if [ -d "/var/www/stream" ] 
then
    echo "Directory /var/www/stream exists." 
    sudo rm -r /var/www/stream
    echo "Directory /var/www/stream removido." 
fi

echo "Copiar nginx files..."
sudo mv www/stream/ /var/www/
sudo cp sites-available/* /etc/nginx/sites-available/
sudo cp sites-enabled/* /etc/nginx/sites-enabled/

echo "Setting secure permissions..."
chown -R www-data:www-data /var/www/stream
chown -R www-data:www-data /var/www/html
chmod -R 777 /var/www/stream/*
chmod -R 777 /var/www/html/*

read -s -n 1 -p "Press any key to continuar 5!"

echo "Testing Nginx configuration..."
nginx -t

read -s -n 1 -p "Press any key to continuar 6!"

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
# Final status check
log_info "Performing final status checks..."
systemctl is-active --quiet nginx && log_info "Nginx is running" || log_error "Nginx failed to start"
systemctl is-active --quiet php8.1-fpm && log_info "PHP-FPM is running" || log_error "PHP-FPM failed to start"

if systemctl is-active --quiet nginx-ui 2>/dev/null; then
    log_info "Nginx UI is running"
else
    log_warn "Nginx UI status check failed"
fi

echo "Script complete! Rebooting..." 
read -s -n 1 -p "Press any key to reboot!"
reboot

