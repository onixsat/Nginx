# Nginx
git clone https://github.com/onixsat/Nginx.git
cd Nginx
bash install.sh


sudo nginx -t
sudo systemctl restart nginx
sudo systemctl restart nginx-ui

sudo nano /etc/nginx/sites-available/default
sudo nano /etc/nginx/sites-available/nginx-ui.conf
 
find -name '*.sh' -print0 | xargs -0 dos2unix
