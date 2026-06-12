#!/bin/sh
set -e

# Gamita ang port gikan sa Cloud Run o 8080 kung wala
PORT=${PORT:-8080}

# Ilisan ang port sa nginx config
sed -i "s/listen 8080;/listen $PORT;/g" /usr/local/openresty/nginx/conf/nginx.conf

# Sugdi ang Xray ug OpenResty
xray run -c /etc/xray.json &
exec /usr/local/openresty/bin/openresty -g "daemon off;"
