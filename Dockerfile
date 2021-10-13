FROM php:8.0.11-fpm-alpine3.14 as php

ARG UID=1000
ARG GID=1000
ARG PHPREDIS_VERSION=5.3.4
ARG IMAGICK_VERSION=3.5.1


RUN apk update && apk add --no-cache \
    vim \
    curl \
    git \
    npm

RUN apk add --virtual .build-deps \
    # pgsql deps
    postgresql-dev \

    # imagick deps

    imagemagick-dev \

    # gd deps
    libjpeg-turbo-dev \
    libwebp-dev \
    libpng-dev \

    # zip deps
    libzip-dev \
    
    # install phpredis from github

    && mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \

    # install imagick from  github

    && mkdir -p /usr/src/php/ext/imagick \
    && curl -L https://github.com/Imagick/imagick/archive/$IMAGICK_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/imagick --strip 1 \
    && echo 'imagick' >> /usr/src/php-available-exts \ 
    
    # install extensions
    && docker-php-ext-install -j "$(nproc)" \
    zip \
    pdo \
    pdo_pgsql \
    opcache \
    bcmath \
    sockets \
    redis \ 
    imagick \
    gd \
    exif \
    && apk del .build-deps && \
    rm -rf /var/cache/apk/*

RUN addgroup -S php -g $GID && adduser -u $UID -S -G php php && \
    mkdir /app

COPY --from=composer:2.1.9 /usr/bin/composer /usr/bin/composer

COPY php.ini /usr/local/etc/php/conf.d/
COPY php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

WORKDIR /app

USER php
