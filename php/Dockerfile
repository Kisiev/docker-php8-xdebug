FROM php:8.1-fpm-alpine

RUN rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install xdebug-3.1.3 \
    && docker-php-ext-enable xdebug

# Install Postgre PDO
RUN apk update && apk add postgresql-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql

# gmp, bcmath
RUN apk add --update --no-cache gmp gmp-dev \
    && docker-php-ext-install gmp bcmath

# redis, apcu
RUN docker-php-source extract \
    && apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS \
    && pecl install redis \
    && pecl install apcu \
    && docker-php-ext-enable redis apcu \
    && apk del .phpize-deps-configure \
    && docker-php-source delete

# git client, mysql-client
RUN apk add --update --no-cache git mysql-client

ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev
RUN apk add --no-cache --update libmemcached-libs zlib
RUN set -xe \
    && apk add --no-cache --update --virtual .phpize-deps $PHPIZE_DEPS \
    && apk add --no-cache --update --virtual .memcached-deps $MEMCACHED_DEPS \
    && pecl install memcached \
    && echo "extension=memcached.so" > /usr/local/etc/php/conf.d/20_memcached.ini \
    && rm -rf /usr/share/php7 \
    && rm -rf /tmp/* \
    && apk del .memcached-deps .phpize-deps

# Configure version constraints
ENV PHP_ENABLE_XDEBUG=0 \
    PATH=/www:/src/vendor/bin:/root/.composer/vendor/bin:$PATH \
    TERM=linux \
    VERSION_PRESTISSIMO_PLUGIN=^0.3.7 \
    COMPOSER_ALLOW_SUPERUSER=1

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
ENV COMPOSER_HOME=/tmp

# pcntl
RUN docker-php-ext-install pcntl

RUN echo "expose_php=0" > /usr/local/etc/php/php.ini

# TimeZone
RUN apk add tzdata bash
ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Set Default User
RUN apk add shadow && usermod -u 1000 www-data && groupmod -g 1000 www-data
USER root

WORKDIR /src

ADD ./php.ini /usr/local/etc/php/php.ini
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

RUN wget https://getcomposer.org/installer -O - -q \
    | php -- --install-dir=/bin --filename=composer --quiet


CMD ["php-fpm"]
