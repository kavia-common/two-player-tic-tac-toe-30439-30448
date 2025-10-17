#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/two-player-tic-tac-toe-30439-30448/backend"
cd "$WORKSPACE"
PORT="${PORT:-3000}"
LOG=/tmp/backend_server.log
rm -f "$LOG"
NODE_ENV="${NODE_ENV:-development}" node index.js > "$LOG" 2>&1 &
echo $!
