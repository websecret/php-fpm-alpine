FROM php:8.0.5-fpm-alpine as php

RUN apk update && apk add --no-cache \
        shadow \
        vim \
        curl \
        wget \
        git \
        jpeg \
        libwebp \
        libzip-dev \
        postgresql-dev

RUN docker-php-ext-install \
    zip \
    pdo pdo_pgsql \
    opcache \
    bcmath \
    gd

ENV PHPREDIS_VERSION 5.3.3

RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis
