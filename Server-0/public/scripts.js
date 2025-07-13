// Set up event listeners on page load
document.addEventListener('DOMContentLoaded', () => {
  const startClusterBtn = document.getElementById('startClusterBtn');
  if (startClusterBtn) {
    startClusterBtn.addEventListener('click', async () => {
      const statusDiv = document.getElementById('clusterStatus');
      const button = document.getElementById('startClusterBtn');
      
      // Disable button and show loading
      button.disabled = true;
      button.textContent = 'Starting...';
      statusDiv.innerHTML = '<p style="color: blue;">Initiating cluster start...</p>';
      
      try {
        const response = await fetch('/cluster/start-cluster', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({})
        });
        
        const result = await response.json();
        
        if (result.success) {
          statusDiv.innerHTML = `<p style="color: green;">${result.message}</p>`;
          statusDiv.innerHTML += `<p><small>Started at: ${result.timestamp}</small></p>`;
        } else {
          statusDiv.innerHTML = `<p style="color: red;">Error: ${result.error}</p>`;
        }
      } catch (error) {
        statusDiv.innerHTML = `<p style="color: red;">Failed to start cluster: ${error.message}</p>`;
      } finally {
        // Re-enable button
        button.disabled = false;
        button.textContent = 'Start Cluster';
      }
    });
  }
});