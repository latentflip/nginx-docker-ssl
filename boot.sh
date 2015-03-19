#!/bin/bash
IP=$(cat /etc/hosts | grep dockerhost | cut -f 1)
echo $IP
echo "s/{hostip}/$IP"
sed "s/{hostip}/$IP/" /etc/nginx/default.tmpl > /etc/nginx/sites-enabled/default
cat /etc/nginx/sites-enabled/default
nginx
