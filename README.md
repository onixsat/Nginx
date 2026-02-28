# Nginx
<h6 style="font-style:italic;">Executar os comandos para instalar o sistema.</h6>

```bash
#sudo su &&  git clone https://github.com/onixsat/Nginx.git && cd Nginx && bash install.sh

sudo su
git clone https://github.com/onixsat/Nginx.git
cd Nginx
bash install.sh
```

<sm style="font-style:italic;">
  Ao iniciar vai comfigurar todo o nhinx.
  <br>
 <sm style="font-size:7;">bI50o5rspCM2pvp+Nzl7XVh0wte7gwb3yM/TnCi1fvM=:gEasYd6mAH1WNWJin8gx9A==</sm>
  
  _Nota: seguro._
```bash
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl restart nginx-ui

sudo nano /etc/nginx/sites-available/default
sudo nano /etc/nginx/sites-available/nginx-ui.conf
```
</sm>








