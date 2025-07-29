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
