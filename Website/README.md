docker build --no-cache -t openclone-website:1.0 .

Environment Variables:

OpenClone_CUDA_VISIBLE_DEVICES = 0,1
OpenClone_DB_Host = 192.168.0.100
OpenClone_DB_Port = 5433
OpenClone_DefaultConnection = Host=%OpenClone_DB_Host%;Port=%OpenClone_DB_Port%;Database=%OpenClone_OpenCloneDB_Name%;Username=%OpenClone_OpenCloneDB_User%;Password=%OpenClone_OpenCloneDB_Password%;Include Error Detail=true;
OpenClone_DefaultConnection_Super = Host=%OpenClone_DB_Host%;Port=%OpenClone_DB_Port%;Database=%OpenClone_OpenCloneDB_Name%;Username=postgres;Password=%OpenClone_postgres_superuser_password%;Include Error Detail=true;
OpenClone_ElevenLabsAPIKey = <Your Key>
OpenClone_GoogleClientId = <Your Key>
OpenClone_GoogleClientSecret = <Your Key>
OpenClone_JWT_Audience = OpenClone
OpenClone_JWT_Issuer = https://openclone.ai
OpenClone_JWT_SecretKey = 5EC40A39-A73C-46F5-B620-40E317CB40A6-7DD04875-FD50-4F95-B45B-B969750467DF
OpenClone_LogDB_Name = open_clone_logging
OpenClone_LogDB_Password = logs
OpenClone_LogDB_User = logs
OpenClone_LogDbConnection = Host=%OpenClone_DB_Host%;Port=%OpenClone_DB_Port%;Database=%OpenClone_LogDB_Name%;Username=%OpenClone_LogDB_User%;Password=%OpenClone_LogDB_Password%;
OpenClone_LogDbConnection_Super = Host=%OpenClone_DB_Host%;Port=%OpenClone_DB_Port%;Database=%OpenClone_LogDB_Name%;Username=postgres;Password=%OpenClone_postgres_superuser_password%;
OpenClone_OPENAI_API_KEY = <Your Key>
OpenClone_OpenCloneDB_Name = open_clone
OpenClone_OpenCloneDB_Password = openclone
OpenClone_OpenCloneDB_User = openclone
OpenClone_OpenCloneFS = C:\Users\seanm\Desktop\OpenCloneFS
OpenClone_OpenCloneLogLevel = Information
OpenClone_postgres_superuser_password = openclone-super
OpenClone_Root_Dir = C:/OpenClone
OpenClone_SadTalker_HostAddress = http://127.0.0.1:5001
OpenClone_SystemLogLevel = Error
OpenClone_U2Net_HostAddress = http://127.0.0.1:5002
OpenClone_Vultr_API_Key = <Your Key>
OpenClone_ZOHO_EMAIL_PASSWORD = <Your Key>