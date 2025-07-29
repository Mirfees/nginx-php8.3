-include Makefile-extend.mk

# Handle the case where we accidentally run `$ make` without the second parameter (target)
.DEFAULT_GOAL := default
default:
	@echo 'No target specified for make command.'


# Eg: $ make bash "cd www && ls -al"
# Eg: $ make bash "composer install --no-dev"
bash:
	docker-compose exec www bash -c "$(filter-out $@,$(MAKECMDGOALS))"


################
# Docker
################

dc.up:
	docker-compose up -d

dc.stop:
	docker-compose stop

dc.down:
	docker-compose down --remove-orphans

dc.recreate: # rebuild docker images and recreate containers
	docker-compose up -d --force-recreate --remove-orphans

dc.rebuild: # rebuild docker images
	docker-compose up -d --build


################
# PHP
################

goto.www:
	docker-compose exec www bash

gulp.watch:
	make node npx gulp watch
gulp.build:
	make node npx gulp build
gulp.scss:
	make node npx gulp scss
gulp.scssProd:
	make node npx gulp scssProd
gulp.js:
	make node npx gulp js
gulp.jsProd:
	make node npx gulp jsProd

npm.install:
	make node npm install
npm.update:
	make node npm update

################
# WP INSTALL
################

wp.download:
	docker-compose exec www bash -c "wp core download --locale=$(LOCALE) --skip-content"
wp.config-create:
	docker-compose exec www bash -c "wp config create \
	--dbname=$(DB_DATABASE) \
	--dbuser=$(DB_USER) \
	--dbpass=$(DB_ROOT_PASSWORD) \
	--dbhost=db \
	--force"
wp.core-install:
	docker-compose exec www bash -c "wp core install \
	--url=$(SITE_URL) \
	--title=$(SITE_TITLE) \
    --admin_user=$(ADMIN_USER) \
	--admin_password=$(ADMIN_PASSWORD) \
	--admin_email=$(ADMIN_EMAIL) \
	--skip-email"
wp.install-plugins:
    docker-compose exec www bash -c " \
      wp plugin install carbon-fields contact-form-7 wp-mail-smtp \
      cookieyes-gdpr-cookie-consent duplicate-page wp-activity-log \
      wordpress-seo query-monitor cyr-to-lat booster-10web wp-optimize --activate \
    "