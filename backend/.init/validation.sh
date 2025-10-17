#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/two-player-tic-tac-toe-30439-30448/backend"
cd "$WORKSPACE"
export NODE_ENV="${NODE_ENV:-development}"
PORT="${PORT:-3000}"
TIMEOUT_SECONDS=${VALIDATION_TIMEOUT:-20}
LOG=/tmp/backend_server.log
rm -f "$LOG"
NODE_V=$(node -v || true) && NPM_V=$(npm -v || true)
# ensure dependencies
if ! node -e "require('express')" >/dev/null 2>&1; then npm ci --silent --no-audit --no-fund; NPM_CI_STATUS=$?; else NPM_CI_STATUS=0; fi
echo "node=${NODE_V} npm=${NPM_V} npm_ci_status=${NPM_CI_STATUS}"
# start server in background
node index.js >"$LOG" 2>&1 &
PID=$!
case "$PID" in
  ''|*[!0-9]*) echo "failed to start server (invalid PID)" >&2; tail -n 200 "$LOG"; exit 6 ;;
esac
trap 'if [ -n "${PID:-}" ] && ps -p "$PID" >/dev/null 2>&1; then kill -TERM "$PID" >/dev/null 2>&1 || true; sleep 2; if ps -p "$PID" >/dev/null 2>&1; then kill -KILL "$PID" >/dev/null 2>&1 || true; fi; fi' EXIT
# poll /health; try both 127.0.0.1 and localhost
END=$((SECONDS + TIMEOUT_SECONDS))
HEALTH_OK=0
while [ $SECONDS -le $END ]; do
  for host in 127.0.0.1 localhost; do
    if curl -sS --fail "http://$host:$PORT/health" >/dev/null 2>&1; then HEALTH_OK=1; break 2; fi
  done
  sleep 0.2
done
if [ $HEALTH_OK -ne 1 ]; then echo "validation failed: /health not reachable on port $PORT" >&2; echo "server log:"; tail -n 200 "$LOG"; exit 7; fi
echo "validation ok: /health responded on port $PORT"
# run tests
TEST_STATUS=0
if command -v npm >/dev/null 2>&1; then npm test --silent --no-audit --no-fund || TEST_STATUS=$?; fi
# graceful shutdown
if ps -p "$PID" >/dev/null 2>&1; then kill -TERM "$PID" >/dev/null 2>&1 || true; sleep 2; if ps -p "$PID" >/dev/null 2>&1; then kill -KILL "$PID" >/dev/null 2>&1 || true; fi; fi
wait "$PID" 2>/dev/null || true
# evidence summary
echo "--- evidence ---"
echo "node=${NODE_V} npm=${NPM_V} npm_ci_status=${NPM_CI_STATUS} test_status=${TEST_STATUS}"
echo "--- server log (tail 200 lines) ---"
tail -n 200 "$LOG" || true
trap - EXIT
if [ ${TEST_STATUS:-0} -ne 0 ]; then echo 'tests failed' >&2; exit 8; fi
exit 0
