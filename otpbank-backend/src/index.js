const { createApp } = require('./app');
const { env } = require('./config/env');
const http = require('http');
const { startWs } = require('./realtime/wsServer');

const app = createApp();

const server = http.createServer(app);
startWs(server);

server.listen(env.port, () => {
  console.log(`Backend listening on port ${env.port}`);
});
