#!/bin/sh
set -eu
STATE="${DATA_DIR:-/data}/code_state.json"; CONFIG="${DATA_DIR:-/data}/xray-httpupgrade.json"; PATH_VALUE="${LUMEN_HTTPUPGRADE_PATH:-/hup}"; last=""; child=""
trap '[ -n "$child" ] && kill "$child" 2>/dev/null || true; exit 0' INT TERM
while :; do
 stamp="$(stat -c %Y "$STATE" 2>/dev/null || echo missing)"
 if [ "$stamp" != "$last" ]; then python /app/xray_httpupgrade_config.py --state "$STATE" --output "$CONFIG" --path "$PATH_VALUE"; [ -n "$child" ] && kill "$child" 2>/dev/null || true; xray run -c "$CONFIG" & child=$!; last="$stamp"; fi
 if [ -n "$child" ] && ! kill -0 "$child" 2>/dev/null; then child=""; last=""; fi
 sleep 2
done
