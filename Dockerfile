FROM alpine:3.19 AS xray-bin

RUN apk add --no-cache \
    curl \
    unzip \
    ca-certificates

# Bersyon nga sigurado nga naa
ARG XRAY_VERSION=1.8.24

WORKDIR /tmp

# Sigurado nga link
RUN curl -fL "https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-64.zip" -o xray.zip && \
    unzip xray.zip && \
    chmod +x xray && \
    mv xray /usr/local/bin/xray && \
    rm -f xray.zip

FROM openresty/openresty:alpine-fat

RUN apk add --no-cache \
    ca-certificates \
    curl \
    bash \
    tzdata

COPY --from=xray-bin /usr/local/bin/xray /usr/local/bin/xray

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY entrypoint.sh /entrypoint.sh
COPY config.json /etc/xray.json

RUN chmod +x /entrypoint.sh /usr/local/bin/xray

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
CMD curl -f http://localhost:8080/ || exit 1

ENTRYPOINT ["/entrypoint.sh"]
