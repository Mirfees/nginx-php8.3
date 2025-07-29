#! /bin/bash

current_path=$(pwd)

set -o allexport
source .env
set +o allexport

make dc.up -d

echo "========== STEP 2: Downloading WP core =========="
make wp.download LOCALE=ru_RU

echo "========== STEP 3: Setting up wp-config.php =========="
make wp.config-create DB_DATABASE=$DB_DATABASE DB_USER=$DB_USER DB_ROOT_PASSWORD=$DB_ROOT_PASSWORD

echo "========== STEP 4: Installing WP =========="
make wp.core-install SITE_URL=$SITE_URL SITE_TITLE=$SITE_TITLE ADMIN_USER=$ADMIN_USER ADMIN_PASSWORD=$ADMIN_PASSWORD ADMIN_EMAIL=$ADMIN_EMAIL

echo "========== STEP 6: Installing standart theme =========="
docker-compose exec www bash -c "git clone 'https://github.com/thunder-web-dev/wp-starter-theme' ./wp-content/themes/wp-theme-$PROJECT_NAME"

echo "========== STEP 7: Setting up theme =========="
docker-compose exec www bash -c "echo '/*
 * Theme Name: $PROJECT_NAME | Wordpress-theme
 * Description: Template for $PROJECT_NAME
 * Theme URI:
 * Author: thunder-web.dev
 * Author URI: https://thunder-web.ru
 * Requires at least: 6.5.5
 * Requires PHP: 7.4
 * Version: 1.0
 * Text Domain: $PROJECT_NAME
*/' > ./wp-content/themes/wp-theme-$PROJECT_NAME/style.css"

docker-compose exec www bash -c "wp theme activate wp-theme-$PROJECT_NAME"