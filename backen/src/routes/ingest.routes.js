const express = require('express');
const router = express.Router();
const pool = require('../db');

router.post('/', async (req, res) => {
  const { text } = req.body;
  if (!text) {
    return res.status(400).json({ ok: false, error: "text requerido" });
  }

  await pool.query('INSERT INTO knowledge (content) VALUES ($1)', [text]);
  res.json({ ok: true, message: "Texto guardado correctamente." });
});

module.exports = router;
