#!/bin/sh
set -e

# Kuhaa ang port gikan sa Cloud Run, kung wala gamita 8080
PORT="${PORT:-8080}"
echo "Starting on port: $PORT"

# Ilisan ang port sa Nginx config
sed -i "s|listen 8080;|listen ${PORT};|g" /usr/local/openresty/nginx/conf/nginx.conf
sed -i "s|listen \[::\]:8080;|listen \[::\]:${PORT};|g" /usr/local/openresty/nginx/conf/nginx.conf

# Sugdi ang Xray ug Nginx
xray run -c /etc/xray.json &
exec /usr/local/openresty/bin/openresty -g "daemon off;"
