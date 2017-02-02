# Base
FROM          alpine:latest
MAINTAINER    Daniel van der Spuy <hello@danielvdspuy.co>

# Environment variables
ENV TIMEZONE  Europe/London
ENV PHP_MEMORY_LIMIT    512M
ENV MAX_UPLOAD          50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST        100M

# Prep apk
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
&&  apk update \
&&  apk upgrade \
&&  apk add --update tzdata \
&&  cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
&&  echo "${TIMEZONE}" > /etc/timezone \

# Install packages
&&  apk add --update \
            freetype-dev \
            libpng-dev \
            libjpeg-turbo-dev \
            libxml2-dev \
            autoconf \
            gcc \
            g++ \
            imagemagick-dev \
            libtool \
            make \
            php7-mcrypt \
            php7-json \
            php7-dom \
            php7-pdo \
            php7-gd \
            php7-xmlreader \
            php7-iconv \
            php7-curl \
&&  pecl install imagick \
&&  apk add --update \
            nginx \
            php7-fpm \
            supervisor \
            
# Stop supervisor
&&  service supervisor stop \

# Delete compilation dependencies
&&  apk del autoconf g++ libtool make \

# Enable imagick PHP extension
&&  echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \

# Setup
&&  sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php7/php-fpm.conf \
&&  sed -i "s|;*listen\s*=\s*127.0.0.1:9000|listen = 9000|g" /etc/php7/php-fpm.d/www.conf \
&&  sed -i "s|;*listen\s*=\s*/||g" /etc/php7/php-fpm.d/www.conf \
&&  sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php7/php.ini \
&&  sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php7/php.ini \
&&  sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" /etc/php7/php.ini \
&&  sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php7/php.ini \
&&  sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php7/php.ini \
&&  sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= 0|i" /etc/php7/php.ini \
    
# Cleanup
&&  mkdir /var/www \
&&  apk del tzdata \
&&	rm -rf /var/cache/apk/*
    
# Copy configs & scripts
ADD ./supervisor.conf /etc/supervisor/conf.d/supervisor.conf
ADD ./start.sh /start.sh

# Set permissions
RUN chmod 755 /start.sh
RUN usermod -u 1000 www-data
RUN usermod -G staff www-data
RUN chown -R www-data:www-data /var/www
    
# Set work directory
WORKDIR /var/www

# Expose volumes
VOLUME ["/var/www"]

# Expose ports
EXPOSE 80
EXPOSE 9000

# Script entry point
CMD ["/bin/bash", "/start.sh"]