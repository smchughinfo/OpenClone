# LogViewer - Real-Time Log Monitoring

[![LogViewer Overview](https://img.youtube.com/vi/SMhwddNQSWQ/0.jpg)](https://www.youtube.com/watch?v=SMhwddNQSWQ)

## What is this?

This is a Flask/React web application for real-time monitoring of logs from all OpenClone services. It connects to the PostgreSQL logging database  and provides a color-coded interface with filtering, search, and live updates. The application supports HTML content in logs, allowing embedded media for monitoring deepfake generation progress and other visual debugging.

The frontend uses React with localStorage caching for efficient log management and periodic polling for real-time updates. Each application has distinct color schemes for easy identification, and the interface supports detailed and compact viewing modes.

## Setup

1. Install VS Code Theme [solvable.shades](https://vscodethemes.com/e/Solvable.shades/shades)
2. [Install Python 3.11.5](https://www.python.org/downloads/release/python-3115/)
3. `ctrl+shift+p > Python: Create Environment > Venv > Python 3.11.5` (yes to requirements.txt)
4. `.venv/scripts/activate`
5. Update database connection parameters in `GlobalVariables.py`

## How to run it

Set environment variables for database connection (see root README.md). Run with environment parameter: `python API.py --environment local|remote|kind` to target the appropriate database. The application runs on port 1234 by default. Use the scripts in `/StartStopScripts/LogViewer/` for different environment configurations.

For more technical details and architecture information, see [CLAUDE.md](CLAUDE.md).