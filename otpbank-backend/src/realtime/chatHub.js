const connectionsByUserId = new Map();

function addConnection(userId, ws) {
  const key = String(userId);
  if (!connectionsByUserId.has(key)) connectionsByUserId.set(key, new Set());
  connectionsByUserId.get(key).add(ws);
}

function removeConnection(userId, ws) {
  const key = String(userId);
  const set = connectionsByUserId.get(key);
  if (!set) return;
  set.delete(ws);
  if (set.size === 0) connectionsByUserId.delete(key);
}

function sendToUser(userId, payload) {
  const key = String(userId);
  const set = connectionsByUserId.get(key);
  if (!set) return;

  const data = JSON.stringify(payload);
  for (const ws of set) {
    if (ws.readyState === ws.OPEN) {
      ws.send(data);
    }
  }
}

module.exports = {
  addConnection,
  removeConnection,
  sendToUser
};
