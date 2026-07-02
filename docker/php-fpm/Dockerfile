# syntax=docker/dockerfile:1.4
#
# Multi-stage Dockerfile for Laravel PHP-FPM application.
#
# Stages:
#   development_base_php  — shared base used by local bind-mount dev (docker-compose.local.yml)
#   server_deployment_php — deployable image for all server environments (dev, staging, production)
#                           built via docker-compose.dev.yml / docker-compose.kind.yml / etc.
#
# Usage:
#   Local dev (bind-mount):  docker compose -f docker-compose.local.yml up
#   Server image build:      docker compose -f docker-compose.<env>.yml build

# =============================================================================
# Stage 1: development_base_php
# =============================================================================
# Shared foundation for all environments. Installs:
#   - System packages (git, zip, nodejs, supervisor, etc.)
#   - PHP extensions (pdo_mysql, mbstring, gd, xdebug, etc.)
#   - Composer binary
#   - Non-root application user
#   - Supervisor and entrypoint script
#
# When used directly (docker-compose.local.yml), source code is bind-mounted
# at runtime so no COPY of src/ is needed here.
FROM php:8.2.0-fpm AS development_base_php

LABEL maintainer="Md. Asif Rahman"

# Build arguments: non-root user name and UID (passed from docker-compose build args).
ARG user
ARG uid

# Install system packages and PHP extensions in a single layer to keep image size small.
# --no-install-recommends avoids pulling in unnecessary suggested packages.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        zip \
        unzip \
        gzip \
        tzdata \
        nodejs \
        npm \
        supervisor \
        libpng-dev \
        libonig-dev \
        libxml2-dev \
    && docker-php-ext-install \
        pdo_mysql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy Composer binary from the official Composer image to avoid installing it via apt.
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create a dedicated non-root user to run Composer and Artisan commands.
# Running as root inside the container is a security risk.
RUN useradd -G www-data,root -u "$uid" -d "/home/$user" "$user" \
    && mkdir -p "/home/$user/.composer" \
    && chown -R "$user":"$user" "/home/$user"

WORKDIR /var/www

# Copy Supervisor config and the container entrypoint script.
COPY ./docker/php-fpm/supervisor.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./docker/php-fpm/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Pre-create the supervisor log directory and fix ownership.
# The non-root user must be able to write here at runtime.
RUN mkdir -p /var/www/storage/logs/supervisor \
    && chown -R "$user":"$user" /var/www/storage/logs/supervisor \
    && chown -R "$user":"$user" /usr/local/etc/php/conf.d

# Switch to non-root user. All subsequent RUN/CMD/ENTRYPOINT run as this user.
USER "$user"

# entrypoint.sh handles: xdebug toggle, composer install (local only), migrate, supervisord start.
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

# =============================================================================
# Stage 2: server_deployment_php
# =============================================================================
# Extends development_base_php with the application source code baked in.
# Used for all server environments: dev, staging, production (and kind for local testing).
#
# What this stage does at build time:
#   1. Copies src/ into the image (no bind mount needed on the server)
#   2. Copies src/.env.prod as /var/www/.env (sensitive values left blank;
#      real values are injected at runtime via k8s ConfigMap + Secret)
#   3. Runs composer install --no-dev to strip dev dependencies from the image
#   4. Runs php artisan optimize to cache routes, views, events
#      (config cache is intentionally excluded — baked config would use blank DB_HOST etc.)
#      Note: config:cache runs at container startup via entrypoint.sh / run-migrations initContainer
FROM development_base_php AS server_deployment_php

ARG user
ARG uid

# Copy source code with correct ownership in a single layer (avoids a separate chown layer).
COPY --chown="$user":"$user" src /var/www/

# Copy the env template. Sensitive fields (DB_PASSWORD, APP_KEY, etc.) are intentionally
# blank here — they are injected at runtime via k8s Secret mounted at /var/www/.env.
COPY src/.env.prod /var/www/.env

USER "$user"

# Install production-only Composer dependencies and remove the local cache to reduce image size.
RUN composer install --no-dev --optimize-autoloader && rm -rf /home/"$user"/.composer

# Cache routes, views, and events at build time.
# Config cache is skipped here intentionally — see note above.
RUN php artisan optimize

# USER and ENTRYPOINT are inherited from development_base_php — no need to repeat them.
