const express = require('express');
const { exec } = require('child_process');
const util = require('util');
const fs = require('fs').promises;
const path = require('path');
const execPromise = util.promisify(exec);
const router = express.Router();

router.post('/start-cluster', async (req, res) => {
  // Ensure logs directory exists
  const logsDir = path.join(__dirname, '../logs');
  try {
    await fs.mkdir(logsDir, { recursive: true });
  } catch (err) {
    console.error('Error creating logs directory:', err);
  }

  const logFile = path.join(logsDir, 'start-cluster.log');
  const timestamp = new Date().toISOString();
  
  // Add timestamp header to log file
  const logHeader = `\n=== Cluster Start Initiated: ${timestamp} ===\n`;
  try {
    await fs.appendFile(logFile, logHeader);
  } catch (err) {
    console.error('Error writing to log file:', err);
  }

  // Fire and forget - start the script in background with logging
  exec(`./start-cluster.sh >> ${logFile} 2>&1`, (error, stdout, stderr) => {
    const endTimestamp = new Date().toISOString();
    const logFooter = `\n=== Cluster Start Completed: ${endTimestamp} ===\n`;
    
    // Append completion timestamp
    fs.appendFile(logFile, logFooter).catch(err => {
      console.error('Error writing completion timestamp:', err);
    });

    if (error) {
      console.error('Error executing start-cluster.sh:', error);
      const errorLog = `\nERROR: ${error.message}\n`;
      fs.appendFile(logFile, errorLog).catch(err => {
        console.error('Error writing error to log:', err);
      });
    } else {
      console.log('Cluster script completed successfully');
    }
  });
  
  // Return immediately
  res.json({
    success: true,
    message: 'Cluster start initiated - running in background',
    timestamp: timestamp
  });
});

// Alternative endpoint that returns YAML kube config
router.get('/get-kube-config-yaml', async (req, res) => {
  const { password } = req.query;
  
  if (password !== process.env.CLUSTER_PASSWORD) {
    return res.status(401).json({
      success: false,
      error: 'Unauthorized'
    });
  }

  try {
    const { stdout: containerList } = await execPromise('docker ps -aq');
    const containerIds = containerList.trim().split('\n').filter(id => id);
    
    if (containerIds.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'No container found'
      });
    }

    const containerId = containerIds[0];
    const tempConfigPath = `/tmp/kubeconfig-${Date.now()}.yaml`;
    
    // Updated to use the correct path inside the container
    await execPromise(`docker cp ${containerId}:/terraform/vultr-dev-kube-config.yaml ${tempConfigPath}`);
    const kubeConfig = await fs.readFile(tempConfigPath, 'utf8');
    await fs.unlink(tempConfigPath);

    // Set Content-Type to text/yaml and return raw YAML
    res.setHeader('Content-Type', 'text/yaml');
    res.setHeader('Content-Disposition', 'attachment; filename="kube-config.yaml"');
    res.send(kubeConfig);

  } catch (error) {
    console.error('Error getting kube config:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

module.exports = router;