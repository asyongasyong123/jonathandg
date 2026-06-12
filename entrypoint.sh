#!/bin/sh
set -e

# Kuhaa ang port gikan sa Cloud Run, default 8080 kung wala
PORT="${PORT:-8080}"
echo "Using port: $PORT"

# Ilisan ang port sa nginx.conf
sed -i "s|listen 8080;|listen ${PORT};|g" /usr/local/openresty/nginx/conf/nginx.conf

# I-check kung nausab na
echo "Nginx config updated to listen on port $PORT"

# Sugdi ang Xray ug OpenResty
xray run -c /etc/xray.json &
exec /usr/local/openresty/bin/openresty -g "daemon off;"
