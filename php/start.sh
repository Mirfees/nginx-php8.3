#!/bin/sh

sudo mkdir -p /var/log/nginx
sudo /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
