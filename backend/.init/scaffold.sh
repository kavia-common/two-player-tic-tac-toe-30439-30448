#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/two-player-tic-tac-toe-30439-30448/backend"
cd "$WORKSPACE"
# create package.json if missing
if [ ! -f package.json ]; then cat > package.json <<'JSON'
{
  "name": "tic-tac-toe-backend",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js",
    "test": "jest --runInBand"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "nodemon": "^2.0.22",
    "jest": "^29.6.1",
    "node-fetch": "^2.6.7"
  }
}
JSON
fi
# index.js (exports app, listens when run directly)
if [ ! -f index.js ]; then cat > index.js <<'JS'
const express = require('express');
const app = express();
const path = require('path');
app.use(express.json());
app.get('/health', (req, res) => res.json({status: 'ok'}));
app.get('/', (req, res) => res.sendFile(path.join(__dirname, 'public', 'index.html')));
// simple in-memory game state
const state = {moves: []};
app.post('/move', (req, res) => { state.moves.push(req.body); res.json({ok:true, state}); });
if (require.main === module) {
  const PORT = process.env.PORT || 3000;
  const server = app.listen(PORT, () => console.log(`listening ${PORT}`));
  const shutdown = () => { console.log('shutdown signal'); server.close(() => { console.log('server closed'); process.exit(0); }); setTimeout(()=>process.exit(1), 5000); };
  process.on('SIGTERM', shutdown);
  process.on('SIGINT', shutdown);
}
module.exports = app;
JS
fi
# public/index.html
mkdir -p public
if [ ! -f public/index.html ]; then cat > public/index.html <<'HTML'
<!doctype html><html><head><meta charset="utf-8"><title>TicTacToe</title></head><body><h1>TicTacToe Backend</h1></body></html>
HTML
fi
# .gitignore
if [ ! -f .gitignore ]; then echo "node_modules
/tmp/backend_server.log
" > .gitignore; fi
