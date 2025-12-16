# Use official PHP image with Apache
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nodejs \
    npm \
    libzip-dev \
    logrotate \
    cron \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip opcache

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set proper permissions for www-data user
RUN chown -R www-data:www-data /var/www

# Copy custom PHP-FPM pool configuration
COPY ./docker/php/www.conf /usr/local/etc/php-fpm.d/zz-custom.conf

# Copy logrotate configuration for Laravel logs
COPY ./docker/php/logrotate-laravel /etc/logrotate.d/laravel

# Copy start script
COPY ./docker/php/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Set up cron job for logrotate (runs hourly)
RUN echo "0 * * * * root /usr/sbin/logrotate /etc/logrotate.d/laravel" > /etc/cron.d/logrotate-laravel && chmod 0644 /etc/cron.d/logrotate-laravel

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["/usr/local/bin/start.sh"]
