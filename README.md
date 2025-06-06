![Splash Image](Documentation/splash.png)

# OpenClone

An AI-powered clone system with deepfake capabilities and comprehensive infrastructure automation.

## Environment Variables

The following environment variables must be set for proper operation. Set these in your system environment or in a `.env` file:

### Database Configuration
```bash
# Database connection settings
OpenClone_DB_Host=192.168.0.100              # Your database host IP
OpenClone_DB_Port=5433                        # Database port
OpenClone_Postgres_Password=puppies           # PostgreSQL superuser password
OpenClone_postgres_superuser_password=openclone-super

# Main application database
OpenClone_OpenCloneDB_Name=open_clone
OpenClone_OpenCloneDB_User=openclone
OpenClone_openclonedb_password=kittens
OpenClone_DefaultConnection=Host=192.168.0.100;Port=5433;Database=open_clone;Username=openclone;Password=kittens;Include Error Detail=true;
OpenClone_DefaultConnection_Super=Host=192.168.0.100;Port=5433;Database=open_clone;Username=postgres;Password=openclone-super;Include Error Detail=true;

# Logging database
OpenClone_LogDB_Name=open_clone_logging
OpenClone_LogDB_User=logs
OpenClone_logdb_password=bunnies
OpenClone_LogDbConnection=Host=192.168.0.100;Port=5433;Database=open_clone_logging;Username=logs;Password=bunnies;
OpenClone_LogDbConnection_Super=Host=192.168.0.100;Port=5433;Database=open_clone_logging;Username=postgres;Password=openclone-super;
```

### Authentication & Security
```bash
# JWT Configuration
OpenClone_JWT_Audience=OpenClone
OpenClone_JWT_Issuer=https://www.clonezone.me  # Your domain
OpenClone_JWT_SecretKey=<your-jwt-secret>      # Generate a secure random key

# Google OAuth
OpenClone_GoogleClientId=<your-google-client-id>
OpenClone_GoogleClientSecret=<your-google-client-secret>

# Email DKIM
OpenClone_email_dkim=v=<your-dkim-public-key>
OpenClone_ZOHO_EMAIL_PASSWORD=<your-zoho-password>
```

### AI Services
```bash
# OpenAI API
OpenClone_OPENAI_API_KEY=<your-openai-api-key>

# ElevenLabs for voice synthesis
OpenClone_ElevenLabsAPIKey=<your-elevenlabs-api-key>

# AI service endpoints
OpenClone_SadTalker_HostAddress=http://127.0.0.1:5001  # Deepfake video service
OpenClone_U2Net_HostAddress=http://127.0.0.1:5002      # Background removal service
```

### Infrastructure
```bash
# File system paths
OpenClone_Root_Dir=C:/Users/seanm/Desktop/OpenClone     # Repository location
OpenClone_OpenCloneFS=C:\Users\seanm\Desktop\OpenClone\OpenCloneFS  # File storage

# FTP/SFTP Configuration
OpenClone_FTP_User=openclone-ftp
OpenClone_FTP_Password=abc123

# Cloud Infrastructure (Vultr)
OpenClone_Vultr_API_Key=<your-vultr-api-key>
OpenClone_Server_0_IP_Address=149.28.35.104    # From Vultr dashboard
OpenClone_Server_0_Password=<vultr-server-password>  # From Vultr dashboard
```

### System Configuration
```bash
# GPU Configuration
OpenClone_CUDA_VISIBLE_DEVICES=0,1            # Available GPU devices

# Logging levels
OpenClone_OpenCloneLogLevel=Information        # Application log level
OpenClone_SystemLogLevel=Error                 # System log level
```

## Quick Start

1. Clone this repository
2. Set all required environment variables above
3. Open the CICD project in VS Code as a dev container
4. Use the action buttons in the status bar to deploy infrastructure

## Architecture

The project consists of several components:
- **Website**: Main ASP.NET Core application
- **Database**: PostgreSQL with vector extensions
- **SadTalker**: AI-powered video generation service
- **U-2-Net**: Background removal service
- **CICD**: Infrastructure automation and deployment tools