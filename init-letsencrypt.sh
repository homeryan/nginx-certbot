#!/bin/bash

# Must run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root."
  exit
fi

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

docker-compose down
cp -f ./data/nginx/app.conf.http-only ./data/nginx/app.conf


domains=(example.org)
rsa_key_size=4096
data_path="./data/certbot"
email="" # Adding a valid address is strongly recommended
staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits


if [ -d "$data_path" ]; then
  read -p "Existing data found for $domains. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi


echo "### Starting nginx ..."
docker-compose up --force-recreate -d nginx
echo


echo "### Requesting Let's Encrypt certificate for $domains ..."
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

certbot_www="$data_path/www"
sudo certbot certonly --webroot -w "$data_path/www" \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal

sudo cp -r -f /etc/letsencrypt "$data_path/"
sudo rm -rf "$data_path/conf"
sudo mv "$data_path/letsencrypt" "$data_path/conf"

if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  sudo curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  sudo curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

echo

echo "### Reloading nginx ..."
cp -f ./data/nginx/app.conf.https ./data/nginx/app.conf
docker-compose down -v
docker container prune -f
docker volume prune -f
docker-compose up -d --remove-orphans

