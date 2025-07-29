FROM ubuntu:22.04

# Environments
ARG USER
ARG UID
ENV COMPOSER_HOME /home/$USER/.composer
ENV DEBIAN_frontend noninteractive
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ Europe/Moscow
ENV php_conf /etc/php/8.3/fpm/php.ini
ENV nginx_conf /etc/nginx/nginx.conf

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y software-properties-common gnupg2 lsb-release ca-certificates apt-transport-https
RUN add-apt-repository ppa:ondrej/php -y
RUN apt-get update
RUN apt-get install -y wget unzip curl git nano sudo telnet net-tools iputils-ping iotop htop atop cron locales logrotate
RUN apt-get install -y libzip-dev libmagickwand-dev libpq-dev libpng-dev libfreetype6-dev libxml2-dev
RUN apt-get install -y default-mysql-client exim4 nginx supervisor
RUN apt-get install -y php8.3
RUN apt-get install -y php8.3-cli
RUN apt-get install -y php8.3-fpm
RUN apt-get install -y php8.3-dev
RUN apt-get install -y php8.3-common
RUN apt-get install -y php8.3-mysql
RUN apt-get install -y php8.3-sqlite3
RUN apt-get install -y php8.3-gmp
RUN apt-get install -y php8.3-curl
RUN apt-get install -y php8.3-intl
RUN apt-get install -y php8.3-mbstring
RUN apt-get install -y php8.3-soap
RUN apt-get install -y php8.3-ldap
RUN apt-get install -y php8.3-gd
RUN apt-get install -y php8.3-bcmath
RUN apt-get install -y php8.3-xml
RUN apt-get install -y php8.3-zip
RUN apt-get install -y php-zip
RUN apt-get install -y php8.3-redis
RUN apt-get install -y php8.3-exif
RUN apt-get install -y php8.3-fileinfo
RUN apt-get install -y php-json
RUN apt-get install -y php8.3-mysqli
RUN apt-get install -y php8.3-imagick
RUN apt-get install -y php8.3-simplexml
RUN apt-get install -y php8.3-xmlreader
RUN apt-get install -y php8.3-ssh2
RUN apt-get install -y php8.3-sockets
RUN apt-get install -y php8.3-dom
RUN apt-get install -y php-pear
RUN apt-get install -y php8.3-ftp
RUN apt-get install -y php8.3-xmlrpc
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
#RUN pecl install imagick ssh2

ENV TZ Europe/Moscow
RUN echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Yarn Install
RUN curl https://deb.nodesource.com/setup_20.x | bash
RUN curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y nodejs yarn \
    && rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get autoclean

#Sendmail
RUN sed -i 's@local@internet@' /etc/exim4/update-exim4.conf.conf && update-exim4.conf

# Set the locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create user
RUN useradd --create-home --shell /bin/bash $USER -G www-data -u $UID
RUN gpasswd --add $USER sudo && echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN usermod -a -G adm $USER

# WP_cli
RUN curl -sS https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp \
    && chown -R $USER:$USER /usr/local/bin/wp

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN mkdir -p /home/$USER/.composer \
    && chown -R $USER:$USER /home/$USER/

# use development php ini
#RUN mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
#RUN mv /php/php.ini-development /etc/php/php.ini

# Config Cron
COPY crontab /etc/cron.d/cronjobs
RUN chmod 0644 /etc/cron.d/cronjobs && \
 touch /var/log/cron.log

# Configure nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
RUN mkdir -p /run/php && chown -R www-data:www-data /run/php
COPY fpm-pool.conf /etc/php-fpm.d/www.conf
COPY fpm-pool.conf /etc/php/8.3/fpm/pool.d/www.conf
COPY php.ini /etc/php/8.3/conf.d/custom.ini
COPY php.ini /etc/php/8.3/fpm/conf.d/custom.ini
COPY php.ini /etc/php/8.3/cli/conf.d/custom.ini

RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf} && \
    echo "\ndaemon off;" >> ${nginx_conf} && \
    sed -i -e 's/user =.*/user = '${USER}'/g' /etc/php/8.3/fpm/pool.d/www.conf && \
    sed -i -e 's/owner =.*/owner = '${USER}'/g' /etc/php/8.3/fpm/pool.d/www.conf && \
    sed -i -e 's/user =.*/user = '${USER}'/g' /etc/php-fpm.d/www.conf && \
    sed -i -e 's/owner =.*/owner = '${USER}'/g' /etc/php-fpm.d/www.conf
            
# Configure supervisord
COPY supervisord.conf /etc/supervisor/supervisord.conf

COPY nginx-log-rotate /etc/logrotate.d/nginx
#COPY app/.env.example /var/www/html/.env
#COPY app /var/www/html

RUN sudo chown -R $USER:www-data /var/www

#VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/var/log", "/var/log/nginx", "/var/www/"]

#Logs
RUN chown -R Debian-exim:Debian-exim /var/spool/exim4/ && mkdir -p /var/log/exim4/ && touch /var/log/exim4/mainlog

# Let supervisord start nginx & php-fpm
COPY start.sh /opt/start.sh
CMD ["/opt/start.sh"]

# Add application
WORKDIR /var/www/

# Expose the port nginx is reachable on
EXPOSE 80

USER $USER
RUN crontab /etc/cron.d/cronjobs

# Configure a healthcheck to validate that everything is up&running
#HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
