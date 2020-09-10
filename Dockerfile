FROM php:7.4.9-apache
MAINTAINER Viet Nguyen "<mrholao09@gmail.com>"
ENV DEBIAN_FRONTEND=noninteractive
#Install git
RUN apt-get update && apt-get install -y git \
      --no-install-recommends && \
	  apt-get autoremove -y && \
	  rm -rf /var/lib/apt/lists/*
    
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-png=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
    
RUN cd /var/www && git clone https://github.com/holao09/KodExplorer.git && git checkout 0b88917b405bfa2b0410233c725c81227e9d90ee
RUN  rm -rf /var/www/html && ln -s /var/www/KodExplorer /var/www/html
RUN  chown -R www-data:www-data /var/www/KodExplorer

# Apache + xdebug configuration
RUN { \
                echo "<VirtualHost *:80>"; \
                echo "  DocumentRoot /var/www/html"; \
                echo "  LogLevel warn"; \
                echo "  ErrorLog /var/log/apache2/error.log"; \
                echo "  CustomLog /var/log/apache2/access.log combined"; \
                echo "  ServerSignature Off"; \
                echo "  <Directory /var/www/html>"; \
                echo "    Options +FollowSymLinks"; \
                echo "    Options -ExecCGI -Includes -Indexes"; \
                echo "    AllowOverride all"; \
                echo; \
                echo "    Require all granted"; \
                echo "  </Directory>"; \
                echo "  <LocationMatch assets/>"; \
                echo "    php_flag engine off"; \
                echo "  </LocationMatch>"; \
                echo; \
                echo "  IncludeOptional sites-available/000-default.local*"; \
                echo "</VirtualHost>"; \
	} | tee /etc/apache2/sites-available/000-default.conf

RUN echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf && \
	echo "date.timezone = Asia/Ho_Chi_Minh" > /usr/local/etc/php/conf.d/timezone.ini && \
    echo "log_errors = On\nerror_log = /dev/stderr" > /usr/local/etc/php/conf.d/errors.ini && \
	a2enmod rewrite expires remoteip cgid && \
	usermod -u 1000 www-data && \
	usermod -G staff www-data

EXPOSE 80

