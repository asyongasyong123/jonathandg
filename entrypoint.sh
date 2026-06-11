#!/bin/sh
set -e

sed -i "s|listen.*;|listen ${PORT:-8080};|g" /usr/local/openresty/nginx/conf/nginx.conf

sed -i "s|listen ${PORT:-8080};|listen 0.0.0.0:${PORT:-8080};|g" /usr/local/openresty/nginx/conf/nginx.conf

echo "Starting services on port: ${PORT:-8080}"

openresty -g 'daemon off;' &

exec xray run -c /etc/xray.json
