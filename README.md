# Nginx
<h6 style="font-style:italic;">Executar os comandos para instalar o sistema.</h6>

```bash
  sudo su
  git clone https://github.com/onixsat/Nginx.git
  cd Nginx
  bash install.sh
 ```

<sm style="font-style:italic;">
  Ao iniciar vai comfigurar todo o nhinx.
  <br>
  oi
  _Nota: seguro._
```bash
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl restart nginx-ui

sudo nano /etc/nginx/sites-available/default
sudo nano /etc/nginx/sites-available/nginx-ui.conf
```
</sm>








