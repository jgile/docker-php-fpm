FROM php:7.2-fpm-alpine

RUN apk update \
    && apk upgrade \
    && apk add zlib-dev \
    && docker-php-ext-configure zip --with-zlib-dir=/usr \
    && docker-php-ext-install zip bcmath opcache mysqli tokenizer pcntl

RUN set -ex \
  && apk --no-cache add postgresql-dev

RUN apk add --no-cache curl libmemcached libmcrypt freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
  docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  docker-php-ext-install -j${NPROC} gd pdo_pgsql pdo_mysql && \
  apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

COPY ./templates/overrides.ini /usr/local/etc/php/conf.d
COPY ./templates/pool.conf /usr/local/etc/php-fpm.d/
COPY ./templates/overrides.conf /usr/local/etc/php-fpm.d/

WORKDIR /var/www/html

CMD ["php-fpm"]