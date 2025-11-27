require('dotenv').config();
const express = require('express');
const cors = require('cors');
const ingestRoutes = require('./routes/ingest.routes');
const chatRoutes = require('./routes/chat.routes');

const app = express();

app.use(cors());
app.use(express.json());

// Aquí deben estar montadas las rutas
app.use('/ingest', ingestRoutes);
app.use('/chat', chatRoutes);

app.get('/health', (req, res) => {
  res.json({ ok: true, now: new Date() });
});

app.listen(3000, () => {
  console.log('Server listening on http://localhost:3000');
});
