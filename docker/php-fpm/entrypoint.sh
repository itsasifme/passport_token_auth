#!/bin/sh
# dev-entrypoint

set -e

echo "Environment: $APP_ENV"

XDEBUG_INI="/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini"
XDEBUG_PATH=$(find /usr/local/lib/php/extensions/ -name xdebug.so 2>/dev/null)

#Configure Xdebug based on environment
if [ "$APP_ENV" = "production" ] || [ "$APP_ENV" = "staging" ]; then
  echo "Disabling Xdebug..."
  rm -f "$XDEBUG_INI"
else
  echo "Enabling Xdebug..."
  if [ -n "$XDEBUG_PATH" ]; then
    {
      echo "zend_extension=$XDEBUG_PATH"
      echo "xdebug.mode=develop,coverage,debug"
      echo "xdebug.start_with_request=yes"
      echo "xdebug.client_host=host.docker.internal"
      echo "xdebug.client_port=9003"
      echo "xdebug.var_display_max_depth=10"
      echo "xdebug.var_display_max_children=512"
      echo "xdebug.var_display_max_data=2048"
    } > "$XDEBUG_INI"
  else
    echo "⚠️ Xdebug not found, skipping setup."
  fi
fi

# Composer install
if [ "$APP_ENV" = "production" ] || [ "$APP_ENV" = "staging" ]; then
  echo "Skipping Composer install and any type of command execution at runtime for production/staging."
  # If you have any staging/production-specific setup that needs to run once, put it into staging/production Dockerfile.
else
  echo "Installing Composer dependencies for development..."
  composer install

  # If you have any development-specific setup that needs to run when container boot up, put it here.
  # For example:
  # php artisan optimize
  # php artisan config:cache
  # php artisan route:cache
  # php artisan view:cache
  # php artisan event:cache
  php artisan migrate
fi

echo "Starting supervisord..."
# exec "php-fpm"
exec supervisord -c /etc/supervisor/conf.d/supervisord.conf

# If you wants run php-fpm directly, you can uncomment the line below:
# echo "Starting supervisord in the background for queue worker..."
# Start supervisord in the background.
# The -c flag specifies the configuration file.
# The & at the end sends the process to the background.
# supervisord -c /etc/supervisor/conf.d/supervisord.conf &

# echo "Starting php-fpm as the main container process..."
# Use 'exec' to replace the current shell process with php-fpm.
# This makes php-fpm the primary process that Docker monitors.
# The -F flag ensures php-fpm stays in the foreground.
# exec php-fpm -F
