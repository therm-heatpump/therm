#!/usr/bin/env bash
# therm add-on entrypoint: map add-on options to THERM_* environment variables,
# then start Streamlit for Ingress. Credentials are never echoed.
set -euo pipefail

OPTIONS_FILE="/data/options.json"

if [ -f "$OPTIONS_FILE" ]; then
    # Emit shell-safe export lines for the options that are set.
    eval "$(python3 - "$OPTIONS_FILE" <<'PY'
import json, shlex, sys
opts = json.load(open(sys.argv[1]))
env = {
    "THERM_INFLUX_HOST": opts.get("influx_host") or "",
    "THERM_INFLUX_PORT": opts.get("influx_port", 8086),
    "THERM_INFLUX_DB": opts.get("influx_database") or "homeassistant",
    "THERM_INFLUX_USER": opts.get("influx_username") or "",
    "THERM_INFLUX_PASSWORD": opts.get("influx_password") or "",
    "THERM_INFLUX_SSL": "true" if opts.get("influx_ssl") else "false",
    "THERM_LOG_LEVEL": opts.get("log_level", "info"),
}
for k, v in env.items():
    print(f"export {k}={shlex.quote(str(v))}")
PY
)"
fi

mkdir -p "${THERM_DATA_DIR:-/config}/profiles" "${THERM_DATA_DIR:-/config}/cache"
echo "[therm] profiles: ${THERM_DATA_DIR:-/config}/profiles ($(ls "${THERM_DATA_DIR:-/config}/profiles" | grep -c '^therm_profile_.*\.json$' || true) saved)"

echo "[therm] starting (influx: ${THERM_INFLUX_HOST:-not configured}, log level: ${THERM_LOG_LEVEL:-info})"

cd /app
# Streamlit listens on localhost only; nginx (nginx.conf) is the only way in and
# admits just Home Assistant's Ingress gateway (172.30.32.2). CORS and XSRF stay
# off because Ingress rewrites the origin and path; the source-address gate is
# what keeps other containers out.
streamlit run app.py \
    --server.port 8502 \
    --server.address 127.0.0.1 \
    --server.headless true \
    --server.enableCORS false \
    --server.enableXsrfProtection false \
    --server.maxUploadSize 15 \
    --browser.gatherUsageStats false \
    --client.toolbarMode minimal \
    --logger.level "${THERM_LOG_LEVEL:-info}" &
STREAMLIT_PID=$!

nginx -c /etc/therm/nginx.conf -g 'daemon off;' &
NGINX_PID=$!
echo "[therm] Ingress gate: nginx :8501 (172.30.32.2 only) -> Streamlit 127.0.0.1:8502"

# Shutdown (the Supervisor sends SIGTERM): stop both and exit 0, a clean stop. If either
# process exits on its own, stop the other and exit with its status, so the Supervisor (and
# the watchdog) sees the failure.
stopping=0
trap 'stopping=1; kill -TERM "$STREAMLIT_PID" "$NGINX_PID" 2>/dev/null' TERM INT
set +e
wait -n "$STREAMLIT_PID" "$NGINX_PID"
status=$?
kill -TERM "$STREAMLIT_PID" "$NGINX_PID" 2>/dev/null
wait "$STREAMLIT_PID" "$NGINX_PID" 2>/dev/null
if [ "$stopping" = 1 ]; then
    echo "[therm] stopped"
    exit 0
fi
echo "[therm] a process exited (status $status); stopping the add-on"
exit "$status"
