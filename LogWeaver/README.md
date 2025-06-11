# LogWeaver - Python Database Logging Package

[![LogWeaver Overview](https://img.youtube.com/vi/SMhwddNQSWQ/0.jpg)](https://www.youtube.com/watch?v=SMhwddNQSWQ)

## What is this?

This is a custom Python logging package that provides asynchronous database-backed logging for OpenClone services written in Python. It uses queue-based logging with background threads to write logs to PostgreSQL without blocking the main application. The package tracks application sessions with run numbers and supports rich metadata including timestamps, IP addresses, etc.

LogWeaver is used by SadTalker and U-2-Net Python services for real-time logging during AI processing. Logging distinguishes between OpenClone application logs and third-party library logs, with configurable log levels and periodic database writes.

## Setup

This is installed as a local editable package. In the consuming application's `requirements.txt`, add:
```
-e ../../LogWeaver
```

Then run `pip install -r requirements.txt` to install in editable mode.

## How to run it

Initialize the database connection with `LogWeaver.InitializeLogWeaver(host, port, db, user, password)`, then create logger instances with `LogWeaver.LogWeaver("AppName", "ip_address")`. Use the logger methods for different levels: `logger.log("message", LogWeaver.LogWeaver.INFO)`. The package handles background database writes automatically with configurable frequency.

For more technical details and architecture information, see [CLAUDE.md](CLAUDE.md).