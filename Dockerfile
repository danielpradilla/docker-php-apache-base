FROM php:5.6-apache
MAINTAINER Daniel Pradilla <info@danielpradilla.info>

# Install proxy module
RUN apt-get update \
    && apt-get install -y libapache2-mod-proxy-html \
    && a2enmod proxy proxy_http


# Install GD
RUN apt-get update \
    && apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng12-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

# Install MCrypt
RUN apt-get update \
    && apt-get install -y libmcrypt-dev \
    && docker-php-ext-install mcrypt

# Install Intl
RUN apt-get update \
    && apt-get install -y libicu-dev \
    && docker-php-ext-install intl

ENV XDEBUG_ENABLE 0
RUN pecl config-set preferred_state beta \
    && pecl install -o -f xdebug \
    && rm -rf /tmp/pear \
    && pecl config-set preferred_state stable
COPY ./99-xdebug.ini.disabled /usr/local/etc/php/conf.d/

# Install Mysql
RUN docker-php-ext-install mysqli pdo_mysql

# Install Postgres
RUN apt-get install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Install mbstring
RUN docker-php-ext-install mbstring

# Install soap
RUN apt-get update \
    && apt-get install -y libxml2-dev \
    && docker-php-ext-install soap

# Install opcache
RUN docker-php-ext-install opcache

# Install PHP zip extension
RUN docker-php-ext-install zip

# Install Git
RUN apt-get update \
    && apt-get install -y git

# Install xsl
RUN apt-get update \
    && apt-get install -y libxslt-dev \
    && docker-php-ext-install xsl

# Install iconv
RUN docker-php-ext-install iconv

# Install memcached
RUN apt-get update \
    && apt-get install -y memcached php5-memcached libmemcached-dev zlib1g-dev \
    && pecl install memcached-2.2.0 \
    && docker-php-ext-enable memcached

# Install vim
RUN apt-get update \
    && apt-get install -y vim

# Define PHP_TIMEZONE env variable
ENV PHP_TIMEZONE UTC

# Configure Apache Document Root
ENV APACHE_DOC_ROOT /var/www/html

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Additional PHP ini configuration
COPY ./999-php.ini /usr/local/etc/php/conf.d/

COPY ./index.php /var/www/html/index.php

# Install ssmtp Mail Transfer Agent
RUN apt-get update \
    && apt-get install -y ssmtp \
    && apt-get clean \
    && echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf \
    && echo 'sendmail_path = "/usr/sbin/ssmtp -t"' > /usr/local/etc/php/conf.d/mail.ini

# Install MySQL CLI Client
RUN apt-get update \
    && apt-get install -y mysql-client

# Additional proxy configuration
COPY ./00-custom-proxy.conf /etc/apache2/conf-available/
RUN a2enconf "00-custom-proxy.conf"

########################################################################################################################

# Start!
COPY ./start /usr/local/bin/
CMD ["start"]
