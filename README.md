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
 <sm style="font-size:7;">N+tsa3Ed8nfcTwYWJSp3LkHs1qZ/ACWC38CZuA4Q24o=:p0K5BOXQP4joK7aWUj+zPQ==</sm>
  
  _Nota: seguro._
```bash
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl restart nginx-ui

sudo nano /etc/nginx/sites-available/default
sudo nano /etc/nginx/sites-available/nginx-ui.conf
```
</sm>








