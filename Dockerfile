# syntax=docker/dockerfile:1

### Build stage: download Xray binary
FROM alpine:3.19 AS xray-bin

RUN apk add --no-cache curl unzip ca-certificates bash

WORKDIR /tmp

RUN curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip \
    && unzip -j xray.zip 'xray' -d /tmp \
    && chmod +x /tmp/xray \
    && mv /tmp/xray /usr/local/bin/xray \
    && rm -f xray.zip

### Final stage: OpenResty + Xray
FROM openresty/openresty:alpine

RUN apk add --no-cache ca-certificates bash curl tzdata wget

# Copy xray from build stage
COPY --from=xray-bin /usr/local/bin/xray /usr/local/bin/xray

# Copy app files into OpenResty html folder (adjust if your static files are elsewhere)
COPY . /usr/local/openresty/nginx/html

# Copy nginx and xray config and entrypoint
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY config.json /etc/xray.json
COPY entrypoint.sh /entrypoint.sh

# Make executables and set ownership
RUN chmod +x /usr/local/bin/xray \
    && chmod +x /entrypoint.sh \
    && chown -R root:root /usr/local/openresty/nginx/html

# Expose port that matches nginx.conf
EXPOSE 8080

# Optional healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s CMD wget -qO- http://127.0.0.1:8080/ || exit 1

ENTRYPOINT ["/entrypoint.sh"]
