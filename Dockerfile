FROM golang:alpine AS xray
RUN apk update && apk add --no-cache git
WORKDIR /go/src/xray/core
RUN git clone --progress https://github.com/XTLS/Xray-core.git . && \
    go mod download && \
    CGO_ENABLED=0 go build -o /tmp/xray -trimpath -ldflags "-s -w -buildid=" ./main

FROM golang:1.19-alpine AS caddy
RUN apk update && apk add --no-cache git
WORKDIR /go/src/caddy/cmd/caddy
RUN git clone --progress https://github.com/caddyserver/caddy.git . && \
    CGO_ENABLED=0 go build -o /tmp/caddy -trimpath -ldflags "-s -w" -v


FROM alpine:edge

ARG AUUID="34eaf305-b49e-4d43-bea4-23980e7a5a30"
#ARG XRAY="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip"
ARG HTML="https://github.com/AYJCSGM/mikutap/archive/refs/heads/master.zip"
#ARG CADDY="https://github.com/caddyserver/caddy/releases/download/v2.6.2/caddy_2.6.2_linux_amd64.tar.gz"

COPY ./etc/ /tmp/config
COPY ./entrypoint.sh /entrypoint.sh

RUN apk update && \
    apk add --no-cache ca-certificates tor unzip wget && \
    mkdir -p /opt/caddy/xray-core && \
    cat /tmp/config/config.json | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" > /opt/caddy/xray-core/config.json && \
    mv /tmp/config/Caddyfile /opt/caddy/Caddyfile && \
    cat /tmp/config/Caddyfile | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" > /opt/caddy/Caddyfile && \
    wget -O /tmp/mikutap-master.zip $HTML && \
    unzip /tmp/mikutap-master.zip -d /opt/caddy/ && \
    rm -rf /tmp/* && \
    chmod +x /entrypoint.sh

COPY --from=xray /tmp/xray /opt/caddy/xray-core/
RUN chmod +x /opt/caddy/xray-core/xray
COPY --from=caddy /tmp/caddy /opt/caddy/
RUN chmod +x /opt/caddy/caddy

ENTRYPOINT /entrypoint.sh

