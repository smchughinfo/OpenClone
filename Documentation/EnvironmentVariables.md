# Environment Variables Setup

Copy these settings and update with your own values. You can set these in your system environment or create a `.env` file:

## Required API Keys
```bash
# AI Services (Required)
OpenClone_OPENAI_API_KEY=<your-openai-api-key>
OpenClone_ElevenLabsAPIKey=<your-elevenlabs-api-key>

# Google Login (Required)
OpenClone_GoogleClientId=<your-google-client-id>
OpenClone_GoogleClientSecret=<your-google-client-secret>

# Security (Generate a random string)
OpenClone_JWT_SecretKey=<your-jwt-secret-key>
```

## Database Settings (Default values work for local development)
```bash
# Database Configuration
OpenClone_DB_Host=127.0.0.1
OpenClone_DB_Port=5433
OpenClone_Postgres_Password=puppies
OpenClone_postgres_superuser_password=openclone-super

# Main Database
OpenClone_OpenCloneDB_Name=open_clone
OpenClone_OpenCloneDB_User=openclone
OpenClone_openclonedb_password=kittens
OpenClone_DefaultConnection=Host=127.0.0.1;Port=5433;Database=open_clone;Username=openclone;Password=kittens;Include Error Detail=true;
OpenClone_DefaultConnection_Super=Host=127.0.0.1;Port=5433;Database=open_clone;Username=postgres;Password=openclone-super;Include Error Detail=true;

# Logging Database
OpenClone_LogDB_Name=open_clone_logging
OpenClone_LogDB_User=logs
OpenClone_logdb_password=bunnies
OpenClone_LogDbConnection=Host=127.0.0.1;Port=5433;Database=open_clone_logging;Username=logs;Password=bunnies;
OpenClone_LogDbConnection_Super=Host=127.0.0.1;Port=5433;Database=open_clone_logging;Username=postgres;Password=openclone-super;
```

## Miscellaneous Settings
```bash
# Your Information
OpenClone_Admin_Email=<your@email.com>
OpenClone_JWT_Issuer=https://www.clonezone.me
OpenClone_JWT_Audience=OpenClone

# Self-Hosting Configuration (Only for HTTPS self-hosting)
OpenClone_Self_Hosting_Domain=app.clonezone.me  # Your domain name
OpenClone_Admin_Email=<your@email.com>          # For Let's Encrypt certificates

# File Storage (Update paths for your system)
OpenClone_Root_Dir=C:/Users/seanm/Desktop/OpenClone
OpenClone_OpenCloneFS=C:/Users/seanm/Desktop/OpenClone/OpenCloneFS

# AI Service Endpoints (Default local addresses)
OpenClone_SadTalker_HostAddress=http://127.0.0.1:5001
OpenClone_U2Net_HostAddress=http://127.0.0.1:5002

# Email (Optional - for DKIM)
OpenClone_email_dkim=v=<your-dkim-public-key>
OpenClone_ZOHO_EMAIL_PASSWORD=<your-zoho-password>

# Cloud Deployment (Optional - for Vultr hosting)
OpenClone_Vultr_API_Key=<your-vultr-api-key>
OpenClone_Server_0_IP_Address=<your-server-ip>
OpenClone_Server_0_Password=<your-server-password>
OpenClone_FTP_User=<your-ftp-username>
OpenClone_FTP_Password=<your-ftp-password>

# System Settings
OpenClone_CUDA_VISIBLE_DEVICES=0,1
OpenClone_OpenCloneLogLevel=Information
OpenClone_SystemLogLevel=Error
```