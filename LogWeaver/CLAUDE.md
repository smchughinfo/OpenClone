# LogWeaver

## Overview
LogWeaver is a custom real-time logging system designed for Python applications in the OpenClone project. It provides database-backed logging with queuing, threading, and automatic cleanup to avoid blocking main application threads during log operations.

## Purpose
- **Target Applications**: Currently used by SadTalker and U-2-Net Python services
- **Architecture**: Queues logs in memory and periodically writes them to the PostgreSQL database
- **Performance**: Non-blocking logging operations to maintain application responsiveness

## Key Features

### Asynchronous Database Logging
- **Queue-based**: Logs are queued in memory using `queue.Queue()`
- **Periodic Writes**: Background thread writes logs to database every 1 second (configurable)
- **Non-blocking**: Main application threads never wait for database operations

### Run Number Tracking
- **Session Management**: Each application restart gets a unique run number
- **History**: Enables tracking logs across different application sessions
- **Synchronization**: Multiple LogWeaver instances for the same application share run numbers

### Rich Metadata Collection
- **Application Context**: Application name, machine name, IP address
- **Timestamps**: US/Eastern timezone with ISO format
- **Log Classification**: Distinguishes OpenClone logs from third-party library logs
- **Tagging**: Support for custom tags array for log categorization

### Dual Logger Modes
1. **Default Logger Mode** (`loggerName=None`):
   - Uses Python's root logger
   - Formats messages automatically
   - Standard logging interface
   
2. **Named Logger Mode** (`loggerName` specified):
   - Creates isolated logger instance
   - Expects pre-formatted JSON messages
   - Prevents log propagation to avoid duplicates

## Technical Architecture

### Core Components
```python
# Initialization
LogWeaver(applicationName, applicationServerIpAddress, level, loggerName)

# Database setup
InitializeLogWeaver(dbHost, dbPort, dbName, dbUser, dbUserPassword)
```

### Threading Model
- **Main Thread**: Queues log entries without blocking
- **Background Thread**: Daemon thread handles database writes
- **Cleanup**: `atexit` handler ensures final log flush and database connection cleanup

### Database Schema
Logs stored in `log` table with fields:
- `run_number`: Session identifier
- `application_name`: Source application
- `open_clone_log`: Boolean flag (OpenClone vs third-party)
- `timestamp`: US/Eastern timezone timestamp
- `message`: Log content
- `tags`: Comma-separated tag list
- `level`: Log level (INFO, WARNING, ERROR, etc.)
- `machine_name`: Host machine identifier
- `ip_address`: Application server IP

## Installation & Usage

### Package Installation
LogWeaver is installed as a local editable package:
```bash
# Referenced in requirements.txt as:
-e ../../LogWeaver
```

### Basic Usage
```python
import LogWeaver

# Initialize database connection
LogWeaver.InitializeLogWeaver(host, port, db, user, password)

# Create logger instance
logger = LogWeaver.LogWeaver("MyApp", "192.168.1.100")

# Log messages
logger.log("Application started", LogWeaver.LogWeaver.INFO)
logger.log("Error occurred", LogWeaver.LogWeaver.ERROR, ["error", "startup"])
```

### Configuration
- **Log Frequency**: `LogWeaver.set_db_log_frequency(seconds)`
- **Log Levels**: INFO, WARNING, DEBUG, ERROR, CRITICAL
- **Custom Tags**: Array of strings for log categorization

## Error Handling
- **Database Failures**: Logged to console with `print()` statements
- **Graceful Degradation**: Application continues running if logging fails
- **Connection Recovery**: Database connection handled per operation

## Dependencies
- **psycopg2**: PostgreSQL database connectivity
- **pytz**: Timezone handling (US/Eastern)
- **Standard Library**: logging, threading, queue, json, datetime

## Project Integration
- **SadTalker Service**: Real-time AI video generation logging
- **U-2-Net Service**: Image segmentation processing logging
- **Database Component**: Logs stored in centralized PostgreSQL database
- **Log Viewer**: Provides web interface for log analysis (separate component)

## Development Notes
- **Thread Safety**: Queue operations are thread-safe
- **Memory Management**: Queue size not limited - relies on periodic flushing
- **Timezone**: Hardcoded to US/Eastern timezone
- **Performance**: 1-second write frequency balances responsiveness vs database load