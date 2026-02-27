#!/bin/bash

# Setting variables to run
DOMAIN="host.ospro.pt"
CLOUDFLAREEMAIL="onixsat6@gmail.com"
CLOUDFLAREAPIKEY="a254903d0de5754b285184bb2e4cbb65"

RANDOMLEVEL4=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1)

# Verifying script is run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
#Verifying script runns on /root
if [ "$PWD" != "/root" ]
  then echo "Please run on /root"
  exit
fi
# make some cleaning for previous testings
rm cloudflare.ini renewcert 2>&1 >/dev/null

# Verifying certbot is in the system
certbot --version 2>&1 >/dev/null # improvement by tripleee
CERBOT_IS_AVAILABLE=$?
if [ $CERBOT_IS_AVAILABLE -ne 0 ]; then 
    echo "Certbot is not installed. Installing it..."
    # Installing certbot
    apt update
    apt install -y nginx certbot python3-certbot-nginx python3-certbot-dns-cloudflare 
fi

echo "dns_cloudflare_email = "$CLOUDFLAREEMAIL > cloudflare.ini
echo "dns_cloudflare_api_key = "$CLOUDFLAREAPIKEY >> cloudflare.ini
chmod 600 cloudflare.ini
echo "#!/bin/bash" > renewcert
echo "source /root/certbot/venv/bin/activate" >> renewcert
echo "certbot renew" >> renewcert
chmod +x renewcert
ln /root/renewcert /etc/cron.weekly/renewcert

certbot certonly \
	--agree-tos --email $CLOUDFLAREEMAIL  --noninteractive \
    --server "https://acme-v02.api.letsencrypt.org/directory" \
    --dns-cloudflare \
    --dns-cloudflare-propagation-seconds 60 \
    --dns-cloudflare-credentials "/root/cloudflare.ini" \
    -d $DOMAIN -d "*."$DOMAIN -d $RANDOMLEVEL4".discard."$DOMAIN
