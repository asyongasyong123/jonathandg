#!/bin/sh
set -e

# Start xray in background and capture PID
/usr/local/bin/xray run -c /etc/xray.json &
XRAY_PID=$!

# Ensure xray is stopped on TERM/INT
_term() {
  echo "Stopping xray (pid $XRAY_PID) ..."
  kill -TERM "$XRAY_PID" 2>/dev/null || true
  wait "$XRAY_PID" 2>/dev/null || true
  exit 0
}
trap _term TERM INT

# Give xray a moment to initialize
sleep 2

# Start openresty in foreground as PID 1
exec /usr/local/openresty/bin/openresty -g 'daemon off;'
