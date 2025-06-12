# Database - PostgreSQL Database Management

![OpenClone Database Overview](Documentation/database.png)

## What is this?

This is the database management project for OpenClone. It provides PostgreSQL database operations including schema migrations, backup/restore functionality, and bootstrap data management. The project uses Python scripts to handle database lifecycle operations and Entity Framework for schema management. It also manages OpenCloneFS - the shared file system used across all OpenClone containers.

The database runs as a PostgreSQL container and supports dual connection strings (super user for migrations, regular user for application access). The backup/restore system maintains bootstrap data in the `/Backups` directory for rapid environment setup.

## Setup

1. Install VSCode PostgreSQL extension [ckolkman.vscode-postgres](https://marketplace.visualstudio.com/items?itemName=ckolkman.vscode-postgres)
2. Install VS Code Theme [Cyberpunk 2077 rebuild](https://vscodethemes.com/e/carlos18mz.cyberpunk-2077-rebuild/cyberpunk-2077-rebuild)
3. [Install Python 3.11.5](https://www.python.org/downloads/release/python-3115/)
4. `git clone https://github.com/smchughinfo/Database.git`
5. `cd Database`
6. `code .`
7. `ctrl+shift+p > Python: Create Environment > Venv > Python 3.11.5` (requirements.txt or do step 9)
8. If environment not activated: `.venv/scripts/activate`
9. `pip install -r requirements.txt`

## Container

To build the container, cd into the root directory (same one as this README.md file) and run `docker build --no-cache -t openclone-database:1.0 -f Container/Dockerfile .`. You will need Docker Desktop, WSL, WSL enabled in Docker Desktop, etc. To run the container use the script in `/StartStopScripts/Database/start.bat`.

## How to run it

Set the required environment variables (see root README.md for complete list). Use the batch scripts in `/BatchScripts/` for database operations: `migrate.bat` for schema changes, `restore.bat` for clean state reset, `backup.bat` for capturing current state as new baseline.

For more technical details and architecture information, see [CLAUDE.md](CLAUDE.md).