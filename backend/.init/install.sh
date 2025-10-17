#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/two-player-tic-tac-toe-30439-30448/backend"
cd "$WORKSPACE"
# Ensure node and npm present
command -v node >/dev/null 2>&1 || { echo "node not found" >&2; exit 2; }
command -v npm >/dev/null 2>&1 || { echo "npm not found" >&2; exit 3; }
NODE_V=$(node -v)
NODE_MAJOR=${NODE_V#v}
NODE_MAJOR=${NODE_MAJOR%%.*}
if [ "${NODE_MAJOR:-0}" -lt 18 ]; then echo "warning: node major version <18: $NODE_V" >&2; fi
# Install dependencies deterministically if express not resolvable
if ! node -e "require('express')" >/dev/null 2>&1; then
  export NODE_ENV="${NODE_ENV:-development}"
  npm ci --silent --no-audit --no-fund
fi
