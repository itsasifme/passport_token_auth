# --- Stage 1: Base Nginx Setup (Common for local environments) ---
FROM nginx:latest AS base_nginx

# Copy your configuration templates directly into the image layers
COPY ./docker/nginx/templates /etc/nginx/templates
COPY ./docker/nginx/html /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

# --- Stage 2: Production/Staging Image (Bakes in static assets) ---
FROM base_nginx AS production

# Only copy assets here for staging and production environments
COPY ./src/public /var/www/public