FROM alpine:edge

ARG AUUID="34eaf305-b49e-4d43-bea4-23980e7a5a30"
ARG XRAY="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip"
ARG HTML="https://github.com/AYJCSGM/mikutap/archive/refs/heads/master.zip"
ARG CADDY="https://github.com/caddyserver/caddy/releases/download/v2.6.2/caddy_2.6.2_linux_amd64.tar.gz"

COPY ./etc/ /tmp/config
COPY ./start.sh /start.sh
RUN apk update && \
    apk add --no-cache ca-certificates unzip wget && \
    mkdir -p /opt/caddy/xray-core && \
    wget -O /tmp/Xray.zip $XRAY && \
    unzip /tmp/Xray.zip -d /tmp/Xray/ && \
    mv /tmp/Xray/xray /opt/caddy/xray-core/ && \
    cat /tmp/config/config.json | sed -e 's/$AUUID/'"${AUUID}"'/g' > /opt/caddy/xray-core/config.json && \
    wget -O /tmp/caddy.tar.gz $CADDY && \
    tar -zxf /tmp/caddy.tar.gz -C /tmp/ && \
    mv /tmp/caddy /opt/caddy/ && \
    mv /tmp/config/Caddyfile /opt/caddy/Caddyfile && \
    wget -O /tmp/mikutap-master.zip $HTML && \
    unzip /tmp/mikutap-master.zip -d /opt/caddy/ && \
    chmod +x /opt/caddy/xray-core/xray && \
    rm -rf /tmp/* && \
    chmod +x /start.sh

ENTRYPOINT /start.sh
