import DatabaseInterface
import OpenCloneFS
import Migrations
import os
import sys
import argparse

# Set up argparse
parser = argparse.ArgumentParser(description="Manage OpenClone databases.")
parser.add_argument("action", choices=["backup", "restore", "migrate"], help="Action to perform: backup, restore, or migrate")

# running locally or remote/prod
parser.add_argument("--remote", action="store_true", help="Is the database operation being performed on a remote/prod server?")

# get super user connection strings
parser.add_argument("--openclone_db_super_connection_string", help="OpenClone DB connection string")
parser.add_argument("--log_db_super_connection_string", help="Log DB connection string")

# get user creds for the individual databases
parser.add_argument("--openclone_db_user_name", help="The openclone db user's name")
parser.add_argument("--openclone_db_user_password", help="The openclone db user's password")
parser.add_argument("--log_db_user_name", help="The log db user's name")
parser.add_argument("--log_db_user_password", help="The log db user's password")

# Parse arguments
args = parser.parse_args()

# Use connection strings from arguments if provided, otherwise use environment variables
openclone_db_super_connection_string = args.openclone_db_super_connection_string if args.openclone_db_super_connection_string else os.getenv("OpenClone_DefaultConnection_Super")
log_db_super_connnection_string = args.log_db_super_connection_string if args.log_db_super_connection_string else os.getenv("OpenClone_LogDbConnection_Super")

# Use creds from arguments if provided, otherwise use environment variables
openclone_db_user_name = args.openclone_db_user_name if args.openclone_db_user_name else os.getenv("OpenClone_OpenCloneDB_User")
openclone_db_user_password = args.openclone_db_user_password if args.openclone_db_user_password else os.getenv("OpenClone_OpenCloneDB_Password")
log_db_user_name = args.log_db_user_name if args.log_db_user_name else os.getenv("OpenClone_LogDB_User")
log_db_user_password = args.log_db_user_password if args.log_db_user_password else os.getenv("OpenClone_LogDB_Password")

# Initialize database managers
openclone_db_manager = DatabaseInterface.DatabaseManager(openclone_db_super_connection_string)
openclonelogging_db_manager = DatabaseInterface.DatabaseManager(log_db_super_connnection_string)

# Perform the requested action
if args.action == "backup":
    openclone_db_manager.backup_database()
    openclonelogging_db_manager.backup_database()

elif args.action == "restore":
    # Delete old database
    openclone_db_manager.delete_database()
    openclonelogging_db_manager.delete_database()

    # Create new database
    OpenCloneFS.reset_openclone_fs(args.remote)
    openclone_db_manager.create_database()
    openclonelogging_db_manager.create_database()
    Migrations.migrate(openclone_db_super_connection_string, log_db_super_connnection_string, True)

    # Add stored procedures to database
    openclone_db_manager.create_stored_proc("SQL/StoredProcedures/create_db_user.sql")
    openclonelogging_db_manager.create_stored_proc("SQL/StoredProcedures/create_db_user.sql")

    # Create database users
    openclone_db_manager.create_db_user(openclone_db_user_name, openclone_db_user_password)
    openclonelogging_db_manager.create_db_user(log_db_user_name, log_db_user_password)

    # Populate database
    openclone_db_manager.populate_database()
    openclonelogging_db_manager.populate_database()

elif args.action == "migrate":
    Migrations.migrate(openclone_db_super_connection_string, log_db_super_connnection_string)
