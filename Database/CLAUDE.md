# Database Project

## Overview
The Database component is the central hub for all database operations in OpenClone. It handles more than just the database itself - it manages database logic, bootstrap scripts, migrations, and provides the PostgreSQL RDBMS via VS Code extensions.

## Technology Stack
- **Database**: PostgreSQL
  - Chosen over MS SQL Server for cost efficiency and vector data type support
  - Vector data type enables phrase similarity matching for user questions
  - Cross-platform compatibility (Windows/Linux/Mac)
- **Framework**: Entity Framework (code-first approach)
- **Language**: Python 3.11.5 (better PostgreSQL integration than .NET)

## Architecture Principles
- Code-first database design with Entity Framework
- Stored procedures only when necessary (complexity reduction)
- ASP.NET Identity tables integrated with main database (complexity reduction)
- Designed for Kubernetes deployment but supports local development

## Directory Structure
```
Database/
├── Backups/                    # Bootstrap data for system initialization
│   ├── OpenCloneFS/           # File system bootstrap (single version)
│   ├── open_clone_db/         # Main database SQL scripts
│   ├── open_clone_logging_db/ # Logging database SQL scripts
│   └── openclone_db_prod_db/  # Production DB (same as main for now)
├── BatchScripts/              # Development lifecycle automation
│   ├── backup.bat            # Captures current state as new bootstrap
│   ├── migrate.bat           # Applies EF schema changes
│   └── restore.bat           # Resets to clean bootstrap state
├── Container/                 # Docker configuration
├── SQL/                      # Manual setup scripts
│   ├── DBConfiguration/      # Database configuration scripts
│   └── StoredProcedures/     # Custom stored procedures
├── Main.py                   # Python entry point
├── DatabaseInterface.py      # Data Access Layer for Python scripts
└── requirements.txt          # Python dependencies
```

## Development Workflow

### Container Setup (Recommended)
1. Use `../StartStopScripts/Database/start.bat` to run PostgreSQL container
2. Container name: `openclone-database`
3. Port mapping: host 5433 → container 5432
4. Dockerfile handles basic PostgreSQL setup

### Manual Local Setup
1. Run scripts in `./SQL/DBConfiguration/`
2. Run scripts in `./SQL/StoredProcedures/`
3. Additional manual configuration steps required

### Batch Script Operations
- **migrate.bat**: Builds Website project → applies EF changes to database schema
- **restore.bat**: Complete reset to clean state
  - Deletes existing databases and root `/OpenCloneFS`
  - Restores from bootstrap versions in `Database/Backup`
  - Perfect for "I broke something" recovery
- **backup.bat**: Captures current state as new baseline
  - Replaces `/Backups` SQL scripts with current database state
  - Replaces `/Backups/OpenCloneFS` with current `/OpenCloneFS` contents

## Environment Configuration

### Required Host Environment Variables
The following environment variables must be set on the host system for the Database project:

**Database Configuration:**
- `OpenClone_DefaultConnection_Super` - Super user connection string for main database (used during EF migrations)
- `OpenClone_LogDbConnection_Super` - Super user connection string for logging database (used during EF migrations)
- `OpenClone_DefaultConnection` - Regular connection string for main database (used by web application)
- `OpenClone_LogDbConnection` - Regular connection string for logging database (used by web application)
- `OpenClone_postgres_superuser_password` - PostgreSQL superuser password
- `OpenClone_OpenCloneDB_User` - Main database username
- `OpenClone_OpenCloneDB_Password` - Main database password
- `OpenClone_OpenCloneDB_Name` - Main database name
- `OpenClone_LogDB_User` - Logging database username
- `OpenClone_LogDB_Password` - Logging database password
- `OpenClone_LogDB_Name` - Logging database name
- `OpenClone_DB_Host` - Database host address
- `OpenClone_DB_Port` - Database port

**File System:**
- `OpenClone_Root_Dir` - Root directory path for OpenClone project
- `OpenClone_OpenCloneFS` - OpenCloneFS directory path for backup/restore operations

### EF Migration Security Model
Entity Framework migrations require special handling for security:

- **During Migration** (`OpenClone_EF_MIGRATION=True`): 
  - Uses super user connection strings (`OpenClone_DefaultConnection_Super`, `OpenClone_LogDbConnection_Super`)
  - Set by `Migrations.py` when running EF migration commands
  - Required because schema changes need elevated privileges

- **During Normal Operation** (`OpenClone_EF_MIGRATION` not set):
  - Uses regular user connection strings (`OpenClone_DefaultConnection`, `OpenClone_LogDbConnection`)
  - Web application runs with limited database privileges
  - Configured in `Website/OpenClone.UI/Configuration/DbContextConfigurator.cs`

This dual-connection approach ensures migrations can modify schema while keeping the running application secure with minimal database permissions.

## Python Components
- **Main.py**: Entry point, parses environment variables, orchestrates operations
- **DatabaseInterface.py**: Data Access Layer for all Database project Python scripts
- **Purpose**: External tooling for database operations (migrate/restore/backup/initialization)
- **Note**: Python runs **outside** the container, not inside PostgreSQL container

## Bootstrap System
The `/Backups` directory contains complete bootstrap data for rapid system setup:
- Environment-specific SQL scripts for minimal database population
- Single OpenCloneFS version (not yet environment-specific)
- Supports the architectural goal: download repo → setup dependencies → click build → entire solution runs

## Database Management
- **VS Code Extension**: [ckolkman.vscode-postgres](https://marketplace.visualstudio.com/items?itemName=ckolkman.vscode-postgres)
- **Focus**: Database work should primarily be schema-focused
- **Deep Changes**: Place in `/Database/SQL/` startup scripts
- **Development State**: 99% complete, mainly edge cases remaining

## Vector Search Implementation
User questions → vector similarity matching → find similar Q&A pairs → feed to LLM for clone responses