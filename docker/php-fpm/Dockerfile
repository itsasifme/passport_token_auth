# syntax=docker/dockerfile:1.4
# This Dockerfile uses multi-stage builds to create a lean production image
# while providing a convenient base for development.

# --- Stage 1: Base PHP-FPM Setup (Common dependencies and user setup) ---
# This stage serves as the foundation for both development and production images.
# It installs core PHP extensions, system dependencies, Composer, and Supervisor.
# It also defines the application user and sets up the entrypoint script.
FROM php:8.2.0-fpm AS base_php_fpm

LABEL maintainer="Md. Asif Rahman"

# Arguments for user and UID, passed during build (e.g., from docker-compose.yml)
ARG user
ARG uid

# Install system dependencies and PHP extensions
# Using a single RUN command to minimize layers and improve build cache efficiency.
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

# Get latest Composer from the official Composer image.
# This ensures you always have a recent version of Composer.
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create a dedicated system user to run Composer and Artisan Commands.
# This enhances security by not running the application as root.
RUN useradd -G www-data,root -u "$uid" -d "/home/$user" "$user" \
    && mkdir -p "/home/$user/.composer" \
    && chown -R "$user":"$user" "/home/$user"

# Set the working directory for subsequent instructions.
WORKDIR /var/www

# Copy Supervisor configuration and the custom entrypoint script.
# These files are essential for managing PHP-FPM and queue workers.
COPY ./docker/php-fpm/supervisor.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./docker/php-fpm/entrypoint.sh /usr/local/bin/entrypoint.sh

# Make the entrypoint script executable.
RUN chmod +x /usr/local/bin/entrypoint.sh

# Ensure necessary directories for logs and PHP configurations have correct ownership.
# This is important for the non-root user to write logs and for PHP-FPM to function.
RUN mkdir -p /var/www/storage/logs/supervisor \
    && chown -R "$user":"$user" /var/www/storage/logs/supervisor \
    && chown -R "$user":"$user" /usr/local/etc/php/conf.d

# --- Configuration for the 'base_php_fpm' stage when used as a development image ---
# These instructions define how the 'base_php_fpm' image will behave if run directly.
# This is useful for development where code is bind-mounted.
USER "$user"
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

# Define the ENTRYPOINT using the shell form to run multiple commands.
# This starts supervisord in the background and then execs php-fpm in the foreground
# as the main process.
# ENTRYPOINT ["/bin/sh", "-c", "supervisord -c /etc/supervisor/conf.d/supervisord.conf & exec php-fpm -F"]

# --- Stage 2: Production Image (Includes application code and optimized Composer setup) ---
# This stage builds upon the 'base_php_fpm' stage and adds the application code.
# It's optimized for production by baking in Composer dependencies at build time.
FROM base_php_fpm AS production

# Re-declare ARGs for this stage if they are needed for subsequent commands in this stage.
ARG user
ARG uid

# Copy application code into the image and set the correct ownership at the same time.
# This prevents the 'chown' operation not permitted error.
COPY --chown="$user":"$user" src /var/www/

# Copy the production environment file and set it as the main .env file.
# The ownership is already handled by the previous COPY command, so we can omit --chown here.
COPY src/.env.prod /var/www/.env

# Switch to the non-root user BEFORE running Composer to ensure correct permissions.
USER "$user"

# Run Composer install for production dependencies.
# This bakes dependencies into the image, leading to faster container startup in production.
# It also ensures Composer is not needed at runtime in production.
RUN composer install --no-dev --optimize-autoloader && rm -rf /home/"$user"/.composer

# Cache Laravel config, routes, views, and events at build time.
# Since .env.prod is already copied above, real values are used — no dummy vars needed.
RUN php artisan optimize

# The USER, ENTRYPOINT, and CMD are inherited from the 'base_php_fpm' stage.
# No need to redefine them here unless you want different behavior specifically for production.
