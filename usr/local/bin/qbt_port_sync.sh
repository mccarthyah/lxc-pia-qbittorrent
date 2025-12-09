#!/bin/sh
LOG_FILE="/var/log/qbt-portwatch.log"
FORWARD_FILE="/tmp/forwarded_port"
QBT_URL="http://127.0.0.1:8080"
INTERVAL=60

echo "$(date): Starting qBittorrent port sync service" >> "$LOG_FILE"

# Wait until qBittorrent is up
until curl -s "$QBT_URL/api/v2/app/version" >/dev/null; do
  echo "$(date): Waiting for qBittorrent to start..." >> "$LOG_FILE"
  sleep 5
done

echo "$(date): qBittorrent is online, entering sync loop" >> "$LOG_FILE"

while true; do
  if [ -f "$FORWARD_FILE" ]; then
    PORT=$(cat "$FORWARD_FILE" | tr -d '\r\n')
    if [ -n "$PORT" ]; then
      curl -s -X POST "$QBT_URL/api/v2/app/setPreferences" \
        -d "json={\"listen_port\":$PORT}" >> "$LOG_FILE" 2>&1
      echo "$(date): Updated qBittorrent port to $PORT" >> "$LOG_FILE"
    else
      echo "$(date): Port file empty" >> "$LOG_FILE"
    fi
  else
    echo "$(date): Port file not found" >> "$LOG_FILE"
  fi
  sleep "$INTERVAL"
done
