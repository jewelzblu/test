FROM golang:alpine AS xray
RUN apk update && apk add --no-cache git
WORKDIR /go/src/xray/core
RUN git clone --progress https://github.com/XTLS/Xray-core.git . && \
    go mod download && \
    CGO_ENABLED=0 go build -o /tmp/xray -trimpath -ldflags "-s -w -buildid=" ./main


FROM alpine:edge
COPY --from=xray /tmp/xray .
RUN apk update && \
    apk add --no-cache ca-certificates caddy tor wget && \
    chmod +x /xray && \
    rm -rf /var/cache/apk/*

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh
