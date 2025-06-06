const express = require('express');
const path = require('path');
const router = express.Router();

// Main page
router.get('/', (req, res) => {
  console.log("INNNNN");
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

console.log("OUTTTT");

module.exports = router;