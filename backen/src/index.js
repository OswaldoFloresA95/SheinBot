require('dotenv').config();
const express = require('express');
const cors = require('cors');

const ingestRoutes = require('./routes/ingest');
const chatRoutes = require('./routes/chat');
const db = require('./db/index');

const app = express();
const PORT = process.env.PORT || 8080;

app.use(cors());
app.use(express.json());

// health
app.get('/health', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT NOW()');
    res.json({ ok: true, now: rows[0].now });
  } catch (err) {
    console.error('Health check DB error', err);
    res.status(500).json({ ok: false, error: 'DB error' });
  }
});

app.use('/ingest', ingestRoutes);
app.use('/chat', chatRoutes);

app.listen(PORT, () => {
  console.log(`Server listening on http://localhost:${PORT}`);
});
