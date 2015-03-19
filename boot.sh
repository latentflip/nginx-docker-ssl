#!/bin/bash
IP=$(cat /etc/hosts | grep dockerhost | cut -f 1)
sed "s/{hostip}/$IP/" /etc/nginx/default.tmpl > /etc/nginx/sites-enabled/default
nginx
