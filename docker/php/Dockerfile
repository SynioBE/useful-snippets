FROM php:8.2-fpm-alpine
ARG DOMAIN=wp.local
ENV DOMAIN=$DOMAIN
WORKDIR /app
RUN apk add --no-cache zip unzip php-zip nodejs npm yarn
RUN apk add --no-cache shadow && usermod -u 1000 www-data && groupmod -g 1000 www-data
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN curl -sL https://getcomposer.org/installer | php -- --install-dir /usr/bin --filename composer
RUN apk add --no-cache autoconf automake libtool coreutils gcc g++ less libc-dev libc6-compat bash libjpeg-turbo-dev libpng-dev make nasm
RUN curl -sLo /usr/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x /usr/bin/wp
RUN apk add --no-cache mysql-client rsync
RUN apk add imagemagick-dev imagemagick
RUN yes '' | pecl install imagick
RUN docker-php-ext-enable imagick
RUN apk add --no-cache libpng libpng-dev && docker-php-ext-install gd && apk del libpng-dev
RUN apk add --no-cache libzip-dev zlib-dev && docker-php-ext-configure zip && docker-php-ext-install zip && apk del libzip-dev zlib-dev
RUN apk add --update linux-headers
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del -f .build-deps
