const fetch = require('node-fetch');
let server, addr;
beforeAll(async () => {
  const app = require('../index');
  server = app.listen(0);
  const port = server.address().port;
  addr = `http://127.0.0.1:${port}`;
  for (let i = 0; i < 50; i++) {
    try {
      const r = await fetch(`${addr}/health`);
      if (r.ok) return;
    } catch (e) {}
    await new Promise(r => setTimeout(r, 100));
  }
  throw new Error('health did not respond in time');
});
afterAll(async () => { if (server && server.close) await new Promise(r => server.close(r)); });
test('health endpoint responds', async () => {
  const r = await fetch(`${addr}/health`);
  expect(r.ok).toBeTruthy();
});
