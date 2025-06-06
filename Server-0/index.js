require('dotenv').config();
const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

// Setup middleware
require('./middleware')(app);

// Setup auth
require('./config/auth')(app);

// Setup routes
require('./routes')(app);

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`CloneZone server running on port ${PORT}`);
  console.log(`Visit: http://localhost:${PORT}`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\nShutting down gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

module.exports = app;