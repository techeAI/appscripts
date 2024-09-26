FROM ubuntu:22.04
ENV DEBIAN_FRONTEND="noninteractive" TZ="America/New_York"
RUN apt-get update
RUN echo RESET CACHE
RUN apt-get install -y apache2 curl wget gnupg2 ca-certificates lsb-release apt-transport-https build-essential libpng-dev libjpeg-dev zlib1g-dev libfreetype6-dev locales zip jpegoptim optipng pngquant gifsicle vim unzip  libzip-dev ffmpeg
RUN curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c' | gpg --dearmor | tee /usr/share/keyrings/ppa_ondrej_php.gpg > /dev/null && echo "deb [signed-by=/usr/share/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ppa_ondrej_php.list
RUN apt update
RUN apt-get install php7.4 php7.4-fpm php7.4-common php7.4-xml php7.4-xmlrpc php7.4-curl php7.4-gd php7.4-imagick php7.4-cli php7.4-dev php7.4-imap php7.4-mbstring php7.4-soap php7.4-zip php7.4-bcmath -y
RUN apt install php7.4-mysql libapache2-mod-php7.4 -y
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN a2enmod ssl
RUN a2enmod headers
RUN a2enmod php7.4
RUN a2ensite default-ssl
#RUN mkdir -p /usr/share/php/agavi/
RUN mkdir -p /home/ubuntu/public_html/
WORKDIR /home/ubuntu/public_html/
RUN rm -rf /etc/apache2/apache2.conf
RUN rm -rf /etc/apache2/envars
RUN rm -rf /etc/php/7.4/fpm/pool.d/www.conf
COPY uploades.ini /etc/php/7.4/fpm/conf.d/uploades.ini
COPY apache2.conf /etc/apache2/
COPY envars /etc/apache2/
COPY www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY 000-default.conf /etc/apache2/sites-available/
COPY default-ssl.conf /etc/apache2/sites-available/
RUN chmod 644 /etc/php/7.4/fpm/pool.d/www.conf
RUN sed -i -- 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.4/fpm/php.ini
RUN sed -i -- 's/;max_input_vars = 1000/max_input_vars = 10000/g' /etc/php/7.4/fpm/php.ini

CMD apachectl -D FOREGROUND