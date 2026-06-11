#!/bin/sh
set -e

PORT=${PORT:-8080}

echo "Using PORT=$PORT"

xray test -c /etc/xray.json

sed -i "s/__PORT__/${PORT}/g" \
/usr/local/openresty/nginx/conf/nginx.conf

xray run -c /etc/xray.json &

exec openresty -g 'daemon off;'
