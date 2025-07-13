const express = require('express');
const { exec } = require('child_process');
const fs = require('fs');
const router = express.Router();

// Debug endpoint for server logs - protected by simple password
router.get('/server-0-logs', (req, res) => {
  // Simple password protection
  const debugPassword = process.env.SERVER_0_LOGS_PASSWORD;
  if (!debugPassword || req.query.password !== debugPassword) {
    return res.status(401).json({ error: 'Unauthorized - SERVER_0_LOGS_PASSWORD required' });
  }

  const logData = {
    timestamp: new Date().toISOString(),
    server_info: {},
    pm2_logs: '',
    pm2_status: '',
    system_info: '',
    recent_requests: []
  };

  // Get PM2 logs (last 100 lines)
  exec('pm2 logs --lines 100 --nostream', (error, stdout, stderr) => {
    if (!error) {
      logData.pm2_logs = stdout;
    } else {
      logData.pm2_logs = `Error getting PM2 logs: ${error.message}`;
    }

    // Get PM2 status
    exec('pm2 status', (error, stdout, stderr) => {
      if (!error) {
        logData.pm2_status = stdout;
      } else {
        logData.pm2_status = `Error getting PM2 status: ${error.message}`;
      }

      // Get basic system info
      exec('ps aux | grep node', (error, stdout, stderr) => {
        if (!error) {
          logData.system_info = stdout;
        } else {
          logData.system_info = `Error getting system info: ${error.message}`;
        }

        // Add server process info
        logData.server_info = {
          node_version: process.version,
          platform: process.platform,
          uptime: process.uptime(),
          memory_usage: process.memoryUsage(),
          env: process.env.NODE_ENV || 'development'
        };

        // Return as JSON or HTML based on Accept header
        if (req.headers.accept && req.headers.accept.includes('application/json')) {
          res.json(logData);
        } else {
          // Return as formatted HTML for browser viewing
          const html = `
<!DOCTYPE html>
<html>
<head>
    <title>Server-0 Debug Logs</title>
    <style>
        body { font-family: monospace; margin: 20px; background: #f5f5f5; }
        .section { background: white; margin: 20px 0; padding: 15px; border-radius: 5px; }
        .section h3 { margin-top: 0; color: #333; }
        pre { background: #f8f8f8; padding: 10px; border-radius: 3px; overflow-x: auto; }
        .timestamp { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <h1>Server-0 Debug Information</h1>
    <div class="timestamp">Generated: ${logData.timestamp}</div>
    
    <div class="section">
        <h3>Server Info</h3>
        <pre>${JSON.stringify(logData.server_info, null, 2)}</pre>
    </div>
    
    <div class="section">
        <h3>PM2 Status</h3>
        <pre>${logData.pm2_status}</pre>
    </div>
    
    <div class="section">
        <h3>PM2 Logs (Last 100 lines)</h3>
        <pre>${logData.pm2_logs}</pre>
    </div>
    
    <div class="section">
        <h3>Node Processes</h3>
        <pre>${logData.system_info}</pre>
    </div>
    
    <div style="margin-top: 30px; padding: 10px; background: #e8f4fd; border-radius: 5px;">
        <strong>Usage:</strong> Add <code>?password=YOUR_SERVER_0_LOGS_PASSWORD</code> to access this endpoint<br>
        <strong>JSON format:</strong> Add <code>Accept: application/json</code> header for JSON response
    </div>
</body>
</html>`;
          res.send(html);
        }
      });
    });
  });
});

// Health check endpoint
router.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

module.exports = router;