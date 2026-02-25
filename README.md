# Nginx


sudo systemctl restart ssh
sudo systemctl start sshd
sudo systemctl enable sshd
sudo nginx -t
sudo systemctl restart nginx-debian

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install ufw -y
sudo apt install net-tools
sudo apt-get install nginx -y
sudo apt-get install php8.1-fpm -y
sudo add-apt-repository ppa:ondrej/php
sudo apt-get install php8.1-mcrypt
sudo apt install openssh-server mcrypt
sudo apt-get install dos2unix
find -name '*.sh' -print0 | xargs -0 dos2unix

sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d vps-3026dd85.vps.ovh.net -m explodgf@gmail.com --agree-tos --no-eff

sudo mkdir /var/www/stream

sudo chmod -R 777 /var/www/stream/
sudo chmod -R 777 /var/www/html/


bash -c "$(curl -L https://cloud.nginxui.com/install.sh)" @ install



git clone https://github.com/onixsat/Nginx.git
cd Nginx/
mv www/stream/ /var/www/
cp sites-available/* /etc/nginx/sites-available/
cp sites-enabled/* /etc/nginx/sites-enabled/
sudo systemctl restart nginx



sudo systemctl start nginx-ui
sudo systemctl status nginx-ui

sudo nano /etc/nginx/sites-available/default
sudo nano /etc/nginx/sites-available/nginx-ui.conf
 
