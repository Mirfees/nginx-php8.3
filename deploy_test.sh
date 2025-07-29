#! /bin/bash

set -e

current_path=$(pwd)

set -o allexport
source .env
set +o allexport

make dc.up -d


echo "========== STEP 2: Downloading WP core =========="
make bash "wp core download --locale=ru_RU --skip-content"

echo "========== STEP 3: Setting up wp-config.php =========="
make bash "wp config create \
	--dbname=$DB_DATABASE \
	--dbuser=$DB_USER \
	--dbpass=$DB_ROOT_PASSWORD \
	--force"


echo "========== STEP 4: Installing WP =========="
make bash "wp core install \
	--url=$SITE_URL \
	--title=$SITE_TITLE \
       	--admin_user=$ADMIN_USER \
	--admin_password=$ADMIN_PASSWORD \
	--admin_email=$ADMIN_EMAIL \
	--skip_email"

echo "========== STEP 5: Setting up wp-config.php =========="
make bash "wp config create \
	--dbname=$DB_DATABASE \
	--dbuser=$DB_USER \
	--dbpass=$DB_ROOT_PASSWORD \
	--force"

echo "========== STEP 6: Installing standart theme =========="
git clone "https://github.com/thunder-web-dev/wp-starter-theme" ./wp-content/themes/wp-theme-$PROJECT_NAME

echo "========== STEP 7: Creating DB =========="
wp db create
