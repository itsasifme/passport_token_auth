#!/bin/sh
# entrypoint

set -e

echo "Environment: $APP_ENV"

XDEBUG_INI="/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini"
XDEBUG_PATH=$(find /usr/local/lib/php/extensions/ -name xdebug.so 2>/dev/null)

#Configure Xdebug based on environment
if [ "$APP_ENV" = "production" ] || [ "$APP_ENV" = "staging" ] || [ "$APP_ENV" = "dev" ]; then
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
if [ "$APP_ENV" = "production" ] || [ "$APP_ENV" = "staging" ] || [ "$APP_ENV" = "dev" ]; then
  echo "Skipping Composer install for production/staging/dev."

  # Config isn't cached at build time (see Dockerfile) — do it here so it reflects the
  # real runtime .env/secrets, not the placeholder values baked into the image.
  echo "Caching configuration..."
  php artisan config:cache

  # compose-only: k8s migrates once via its run-migrations initContainer instead,
  # since this runs per-pod and would otherwise re-run on every replica.
  if [ "$RUN_MIGRATIONS_ON_BOOT" = "true" ]; then
    echo "Running migrations..."
    for i in $(seq 1 10); do
      php artisan migrate --force && break
      echo "Migration attempt $i failed, retrying in 3s..."
      sleep 3
    done
  fi
else
  echo "Installing Composer dependencies for local development..."
  composer install

  # Extra local-dev boot steps can go here, e.g.:
  php artisan optimize
  # php artisan config:cache
  # php artisan route:cache
  # php artisan view:cache
  # php artisan event:cache
  php artisan migrate
fi

echo "Starting supervisord..."

# Supervisord runs as the main process, managing both php-fpm and the queue worker.
exec supervisord -c /etc/supervisor/conf.d/supervisord.conf

# If you wants run php-fpm directly, you can uncomment the relevant commands below:
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
