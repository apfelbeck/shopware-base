FROM php:7.4-apache
ENV PHP_MEMORY_LIMIT=512M
# timezone / date   
RUN echo "Europe/Berlin" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
# install packages
RUN apt-get update -y && \
  apt-get install -y --no-install-recommends \
  less vim wget unzip rsync git  autossh ssl-cert \
  libcurl4-openssl-dev libfreetype6 libjpeg62-turbo libpng-dev libzip-dev \
  libjpeg-dev libxml2-dev libwebp6 libxpm4 libc-client-dev libkrb5-dev libonig-dev && \
  apt-get clean && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/* && \
  echo "export TERM=xterm" >> /root/.bashrc
# enable required apache modules
RUN a2enmod rewrite && a2enmod headers && /usr/sbin/a2enmod expires 
# install php extensions
RUN docker-php-ext-configure gd && \
  docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
  docker-php-ext-install -j$(nproc) curl json xml mbstring zip bcmath soap pdo_mysql mysqli gd gettext imap intl
# install ioncube    
RUN curl -o ioncube.tar.gz http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xvvzf ioncube.tar.gz \
    && mv ioncube/ioncube_loader_lin_7.4.so `php-config --extension-dir` \
    && rm -Rf ioncube.tar.gz ioncube \
    && docker-php-ext-enable ioncube_loader_lin_7.4
# install composer 
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN echo "memory_limit = 512M" > /usr/local/etc/php/conf.d/shopware.ini
