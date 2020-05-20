FROM php:7.4-fpm-alpine
# Maintainer
MAINTAINER Andrey Delphin <masterforweb@hotmail.com>
# Environments
ENV TIMEZONE Europe/Moscow
ENV PHP_MEMORY_LIMIT 1024M
ENV MAX_UPLOAD 128M
ENV PHP_MAX_FILE_UPLOAD 128
ENV PHP_MAX_POST 128M
ENV PHP_INI_FILE php.ini-production
ENV WWW_USER 1000
# удаляем юзера для подмены
RUN  deluser www-data && \
mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \  
apk add --no-cache --virtual .deps \
    git \
    icu-libs \
    zlib \
    openssh \
    imagemagick \
    imagemagick-libs \
    imagemagick-dev  && \
set -xe && \
    apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    icu-dev \
    zlib-dev &&  \ 
#install ext                  
docker-php-ext-install pdo pdo_mysql mysqli && \
# add pecl
pecl install imagick && \  
#config ini
docker-php-ext-enable --ini-name 20-imagick.ini imagick && \
# usr/local/etc/php/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' ${PHP_INI_DIR}/php.ini  && \
sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" ${PHP_INI_DIR}/php.ini && \
sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" ${PHP_INI_DIR}/php.ini && \
sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" ${PHP_INI_DIR}/php.ini && \
sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" ${PHP_INI_DIR}/php.ini && \
sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" ${PHP_INI_DIR}/php.ini && \
# add user and group
addgroup -g ${WWW_USER} -S www-data && \
adduser -u ${WWW_USER} -D -S -G www-data www-data

WORKDIR /vhosts
USER www-data