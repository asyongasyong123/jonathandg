# syntax=docker/dockerfile:1

### Build stage: download Xray binary
FROM alpine:3.19 AS xray-bin

RUN apk add --no-cache curl unzip ca-certificates bash

WORKDIR /tmp

# Download and extract the xray binary reliably
RUN curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip \
    && unzip -j xray.zip 'xray' -d /tmp \
    && chmod +x /tmp/xray \
    && mv /tmp/xray /usr/local/bin/xray \
    && rm -f xray.zip

### Final stage: OpenResty + Xray
FROM openresty/openresty:alpine-fat

RUN apk add --no-cache ca-certificates bash curl tzdata

# Copy xray from build stage
COPY --from=xray-bin /usr/local/bin/xray /usr/local/bin/xray

# Copy configs and entrypoint
COPY config.json /etc/xray.json
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY entrypoint.sh /entrypoint.sh

# Make sure entrypoint and binary are executable
RUN chmod +x /usr/local/bin/xray \
    && chmod +x /entrypoint.sh

# Expose port that matches nginx.conf (adjust to 80 or 8080 as your nginx listens)
EXPOSE 80

# Use a simple healthcheck (optional)
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s CMD wget -qO- http://localhost/ || exit 1

ENTRYPOINT ["/entrypoint.sh"]
