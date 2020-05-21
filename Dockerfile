FROM php:7.4-fpm-alpine
# Maintainer
MAINTAINER Andrey Delfin <masterforweb@hotmail.com>

# Environments
ENV TIMEZONE Europe/Moscow
ENV PHP_MEMORY_LIMIT 1024M
ENV MAX_UPLOAD 128M
ENV PHP_MAX_FILE_UPLOAD 128
ENV PHP_MAX_POST 128M
ENV PHP_INI_FILE php.ini-production
ENV WWW_USER 1000

RUN deluser www-data \
&& addgroup -g ${WWW_USER} -S www-data \
&& adduser -u ${WWW_USER} -D -S -G www-data www-data \
# install soft
&& apk add --no-cache --update --virtual .build-deps $PHPIZE_DEPS \
    git \
    curl \
    imagemagick \
    imagemagick-libs \
    imagemagick-dev \ 
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \ 
    vips-tools \
    vips-dev \
    fftw-dev \ 
    glib-dev \
#MYSQL
&& docker-php-ext-install -j$(nproc) pdo_mysql mysqli \
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
#RUN apk del -f .build-deps 
&& ln -sf "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
# usr/local/etc/php/php.ini
&& sed -i 's/short_open_tag = Off/short_open_tag = On/g' ${PHP_INI_DIR}/php.ini  \
&& sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" ${PHP_INI_DIR}/php.ini \
&& sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" ${PHP_INI_DIR}/php.ini \
&& sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" ${PHP_INI_DIR}/php.ini \
&& sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" ${PHP_INI_DIR}/php.ini \
&& sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" ${PHP_INI_DIR}/php.ini \
#remove trash
&& rm -rf /var/cache/apk/* \
&& rm -rf /tmp/*


WORKDIR /vhosts
USER www-data