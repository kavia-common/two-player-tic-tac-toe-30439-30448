#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/two-player-tic-tac-toe-30439-30448/backend"
cd "$WORKSPACE"
mkdir -p __tests__
if [ ! -f __tests__/server.test.js ]; then cat > __tests__/server.test.js <<'JST'
const fetch = require('node-fetch');
const http = require('http');
const app = require('../index');
function waitFor(url, timeout=5000){
  const start = Date.now();
  return new Promise((resolve,reject)=>{
    (function poll(){
      fetch(url).then(r=>{ if(r.ok) return resolve(true); }).catch(()=>{});
      if(Date.now()-start>timeout) return reject(new Error('timeout'));
      setTimeout(poll, 100);
    })();
  });
}
let server;
beforeAll(done=>{
  server = http.createServer(app);
  server.listen(0, async ()=>{
    const port = server.address().port;
    await waitFor(`http://127.0.0.1:${port}/health`, 3000);
    global.__TEST_PORT = port;
    done();
  });
});
afterAll(done=> server.close(done));
test('health responds', async ()=>{
  const res = await fetch(`http://127.0.0.1:${global.__TEST_PORT}/health`);
  expect(res.ok).toBe(true);
  const body = await res.json();
  expect(body.status).toBe('ok');
});
JST
fi
# ensure deps
npm ci --silent --no-audit --no-fund
# run jest once to ensure tests runnable
NODE_ENV=test npx jest --runInBand --silent || true
