FROM php:7.4-fpm-alpine
# Maintainer
MAINTAINER Andrey Delfin <masterforweb@hotmail.com>
ENV FPM_INI_FILE /usr/local/etc/php-fpm.d/www.conf

RUN apk add --no-cache --update --virtual .build-deps $PHPIZE_DEPS \
    git \
    curl \
    imagemagick \
    imagemagick-libs \
    imagemagick-dev \ 
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \ 
    libzip-dev \
    vips-tools \
    vips-dev \
    fftw-dev \ 
    glib-dev \
    autoconf \
	g++ \
	libtool \
	make \
    icu-dev \
# intl
&& docker-php-ext-configure intl \
&& docker-php-ext-install intl \
#MYSQL
&& docker-php-ext-install -j$(nproc) pdo_mysql mysqli zip \
#IMAGICK
&& pecl install imagick \
&& docker-php-ext-enable --ini-name 20-imagick.ini imagick \
#VIPS
&& pecl install vips \
&& docker-php-ext-enable --ini-name 20-vips.ini vips \
#GD
&& docker-php-ext-configure gd --with-freetype --with-jpeg  \       
&& docker-php-ext-install -j$(nproc) gd \
#REDIS
&& pecl install redis \
&& docker-php-ext-enable --ini-name 20-redis.ini redis \
#base config php.ini
&& ln -sf "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
&& sed -i 's/short_open_tag = Off/short_open_tag = On/g' ${PHP_INI_DIR}/php.ini  \
&& sed -i -e "s/\;opcache.enable=1/opcache.enable=1/g" ${PHP_INI_DIR}/php.ini \
&& sed -i -e "s/\;opcache.enable_cli=0/opcache.enable_cli=1/g" ${PHP_INI_DIR}/php.ini \
#base fpm.ini
&& sed -i -e "s/\;env\[/env\[/g" ${FPM_INI_FILE} \
#remove trash
&& rm -rf /var/cache/apk/* \
&& rm -rf /tmp/*