# Boilerplate for nginx with Let’s Encrypt on docker-compose

> This repository is accompanied by a [step-by-step guide on how to
> set up nginx and Let’s Encrypt with Docker](https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71).
>
> This repository is forked from https://github.com/wmnnd/nginx-certbot

`init-letsencrypt.sh` fetches and ensures the renewal of a Let’s
Encrypt certificate for one or multiple domains in a docker-compose
setup with nginx.
This is useful when you need to set up nginx as a reverse proxy for an
application.



## Installation
1. [Install docker-compose](https://docs.docker.com/compose/install/#install-compose).
2. [Install Certbot](https://certbot.eff.org/instructions?ws=nginx&os=ubuntufocal).
2. When using Cloudflare as CDN, enable Overview -> Quick Actions -> Development Mode, and select SSL/TLS -> SSL/TLS encryption mode -> Off (not secure).
3. Clone this repository: `git clone git@github.com:homeryan/nginx-certbot.git .`
3. Modify configuration:
- Add domains and email addresses to init-letsencrypt.sh
- Replace all occurrences of example.org with primary domain (the first one you added to init-letsencrypt.sh) in data/nginx/app.conf, data/nginx/app.conf.http-only, and data/nginx/app.conf.https

4. Run the init script:

        ./init-letsencrypt.sh

5. Run the server:
    ```
    docker-compose up -d --remove-orphans
    ```
    
5. When using Cloudflare as CDN, disable Overview -> Quick Actions -> Development Mode, and select SSL/TLS -> SSL/TLS encryption mode -> Full.

    

## License

All code in this repository is licensed under the terms of the `MIT License`. For further information please refer to the `LICENSE` file.
