const express = require('express');
const router = express.Router();

//ejemplo temporal
router.post('/', (req, res ) => {
    res.json({ msg: 'Chat Ok' });
});

module.exports = router;