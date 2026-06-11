#!/bin/sh
 set -e
 echo "Starting Xray..."
 xray run -c /etc/xray.json &
 echo "Starting Nginx on port 8080..."
 exec openresty -g 'daemon off;'
