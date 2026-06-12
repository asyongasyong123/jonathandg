#!/bin/sh
set -e
PORT=${PORT:-8080}
sed -i "s|listen 8080;|listen ${PORT};|g" /usr/local/openresty/nginx/conf/nginx.conf
xray run -c /etc/xray.json &
exec /usr/local/openresty/bin/openresty -g "daemon off;"
