rm -rf /opt/caddy/vmess* &
/opt/caddy/xray-core/xray -config /opt/caddy/xray-core/config.json > /dev/null 2>&1 &
/opt/caddy/caddy run --config /opt/caddy/Caddyfile -adapter caddyfile
