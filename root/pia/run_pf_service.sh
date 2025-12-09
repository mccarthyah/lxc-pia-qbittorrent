#!/bin/sh
# Persistent PIA WireGuard Port Forwarding Service
# Keeps refreshing port and maintaining connection.

LOG_FILE="/var/log/pia-port-forward.log"
PORT_FILE="/tmp/forwarded_port"
DEBUG_LOG="/var/log/pia-debug.log"

echo "=== $(date) Starting persistent run_pf_service.sh ===" >>"$DEBUG_LOG"

set -x

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
cd /root/pia || exit 1

export PF_GATEWAY=66.56.81.217
export PF_HOSTNAME=ontario402

while true; do
    echo "=== $(date) Fetching PIA token ===" >>"$DEBUG_LOG"
    export PIA_TOKEN=$(
        PIA_USER=p9798466 PIA_PASS=nnEmPHTZ84 ./get_token.sh 2>/dev/null \
        | awk -F= '/PIA_TOKEN/ {print $2}'
    )

    if [ -z "$PIA_TOKEN" ]; then
        echo "Token fetch failed, retrying in 60s" >>"$DEBUG_LOG"
        sleep 60
        continue
    fi

    echo "Got PIA_TOKEN length: ${#PIA_TOKEN}" >>"$DEBUG_LOG"

    rm -f "$PORT_FILE" /tmp/pia_pf_temp.log
    ./port_forwarding.sh > /tmp/pia_pf_temp.log 2>&1 &
    PF_PID=$!
    echo "Started port_forwarding.sh with PID $PF_PID" >>"$DEBUG_LOG"

    # Wait up to 20s for port to appear
    for i in $(seq 1 20); do
        if grep -q "Forwarded port" /tmp/pia_pf_temp.log; then
            PORT=$(awk '/Forwarded port/ {print $3}' /tmp/pia_pf_temp.log)
            echo "$PORT" > "$PORT_FILE"
            echo "$(date) Forwarded port: $PORT" >>"$DEBUG_LOG"
            break
        fi
        sleep 1
    done

    cat /tmp/pia_pf_temp.log >>"$LOG_FILE"
    rm -f /tmp/pia_pf_temp.log

    echo "$(date) Sleeping 15 min before renewing..." >>"$DEBUG_LOG"
    sleep 900
done