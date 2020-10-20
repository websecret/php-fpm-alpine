FROM php:7.4.10-fpm-alpine as php

RUN apk update \
&& docker-php-source extract \
&& apk add --no-cache --virtual .build-dependencies \
    $PHPIZE_DEPS \
    pcre-dev \
    build-base \
&& apk add --no-cache \
    shadow \
    vim \
    curl \
    git \
    postgresql-dev \
    imagemagick-dev \
    libzip-dev \
    # for GD
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
&& docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
&& docker-php-ext-configure exif \
&& docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" \
    intl \
    exif \
    zip \
    pdo_pgsql \
    gd \
    opcache \
&& printf "y\n" | pecl install mongodb-1.8.0 \
&& printf "y\n" | pecl install imagick-3.4.4 \
&& printf "y\n" | pecl install igbinary-3.1.5 \
&& printf "y\n" | pecl install redis-5.3.1 --enable-redis-igbinary \
&& docker-php-ext-configure exif \
&& docker-php-ext-enable \
    igbinary \
    redis \
    mongodb \
    imagick \
    opcache \
&& apk del .build-dependencies \
&& docker-php-source delete \
&& rm -rf /tmp/* /var/cache/apk/*
