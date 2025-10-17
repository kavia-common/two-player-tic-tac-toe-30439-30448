const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;
const state = { games: {} };
let server;
app.use(express.json());
app.get('/health', (req, res) => res.json({ status: 'ok' }));
app.get('/', (req, res) => res.sendFile(path.join(__dirname, 'public', 'index.html')));
app.post('/game', (req, res) => { const id = Date.now().toString(); state.games[id] = { board: Array(9).fill(null) }; res.json({ id }); });
app.get('/game/:id', (req, res) => { const g = state.games[req.params.id]; return g ? res.json(g) : res.status(404).end(); });
// export for programmatic testing
module.exports = app;
function start() { server = app.listen(PORT, () => console.log(`Server listening on ${PORT}`)); }
function stop(cb){ if(server) server.close(cb); else cb && cb(); }
// graceful shutdown hooks
process.on('SIGTERM', () => { console.log('SIGTERM received, shutting down'); stop(()=>process.exit(0)); });
process.on('SIGINT', () => { console.log('SIGINT received, shutting down'); stop(()=>process.exit(0)); });
if (require.main === module) { start(); }
