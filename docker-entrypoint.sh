#!/bin/sh
# Railway mounts the persistent volume at /data. Prepare only that dedicated
# application-state path, then run the relay as an unprivileged user.
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p /data
    chown -R lumen:lumen /data
    exec gosu lumen "$@"
fi

if [ "${LUMEN_HTTPUPGRADE_ENABLED:-1}" = "1" ]; then /app/xray-httpupgrade-supervisor.sh & fi
if [ "$#" -ge 2 ] && [ "$1" = "python" ] && [ "$2" = "main.py" ]; then PORT="${LUMEN_APP_PORT:-8081}" "$@" & app_pid=$!; trap 'kill "$app_pid" 2>/dev/null || true; exit 0' INT TERM; exec /usr/bin/caddy run --config /app/Caddyfile --adapter caddyfile; fi
exec "$@"