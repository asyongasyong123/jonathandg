FROM alpine:3.19 AS xray-builder

RUN apk add --no-cache curl unzip ca-certificates
WORKDIR /app

RUN set -e && \
    curl -fL https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip && \
    unzip xray.zip && \
    chmod +x xray && \
    mv xray /usr/local/bin/xray && \
    rm -f xray.zip

FROM openresty/openresty:alpine-fat

RUN apk add --no-cache ca-certificates bash tzdata

COPY --from=xray-builder /usr/local/bin/xray /usr/local/bin/xray

COPY config.json /etc/xray.json
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /usr/local/bin/xray /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
