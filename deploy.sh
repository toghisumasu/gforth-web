#!/usr/bin/env bash
set -euo pipefail
APP_DIR="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$APP_DIR/app.pid"
PORT=3000
BIND="127.0.0.1"
cd "$APP_DIR"

start() {
    [ -f "$PID_FILE" ] && echo "Already running (PID: $(cat $PID_FILE))" && return 1
    nohup bundle exec ruby app.rb --bind "$BIND" --port "$PORT" > app.log 2>&1 &
    echo $! > "$PID_FILE"
    echo "Started (PID: $(cat $PID_FILE))"
}
stop() {
    [ ! -f "$PID_FILE" ] && echo "Not running" && return 0
    kill "$(cat $PID_FILE)" || true
    rm -f "$PID_FILE"
    echo "Stopped"
}
restart() { stop; sleep 1; start; }
status() {
    if [ -f "$PID_FILE" ] && ps -p "$(cat $PID_FILE)" > /dev/null 2>&1; then
        echo "Running (PID: $(cat $PID_FILE))"
    else
        rm -f "$PID_FILE"
        echo "Not running"
    fi
}
case "${1:-status}" in
    start) start ;; stop) stop ;; restart) restart ;; status) status ;;
    *) echo "Usage: $0 {start|stop|restart|status}"; exit 1 ;;
esac
