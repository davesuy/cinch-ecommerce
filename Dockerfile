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
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip opcache

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set proper permissions for www-data user
RUN chown -R www-data:www-data /var/www

# Copy custom PHP-FPM pool configuration
COPY ./docker/php/www.conf /usr/local/etc/php-fpm.d/zz-custom.conf

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]

