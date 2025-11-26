const express = require('express');
const router = express.Router();

// ejemplo temporal
router.get('/', (req, res) => {
  res.json({ msg: 'Ingest OK' });
});

module.exports = router;
