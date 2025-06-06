import os
import subprocess
import shutil
import uuid
from contextlib import contextmanager
import DatabaseInterface

openclone_root_dir = os.getenv("OpenClone_Root_Dir")

#################################################################################
############### POWERSHELL HELPER ###############################################
#################################################################################

def run_powershell_commands(commands):
    print(commands)
    process = subprocess.Popen(["powershell", "-Command", commands], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    # Print output and errors in real-time
    while True:
        output = process.stdout.readline()
        if output == '' and process.poll() is not None:
            break
        if output:
            print(output.strip())

    stderr = process.stderr.read()
    if stderr:
        print(stderr.strip())

#################################################################################
############### CONTEXT MANAGER FOR ENVIRONMENT VARIABLES #######################
#################################################################################

@contextmanager
def temporary_env_vars(new_env_vars):
    original_env_vars = {}
    
    # Store original values and set new environment variables
    for key, value in new_env_vars.items():
        original_env_vars[key] = os.getenv(key)  # Store the original value (could be None)
        os.environ[key] = value
    
    try:
        yield  # Execution of the block within the `with` statement
    finally:
        # Restore original values or remove if they didn't exist before
        for key, original_value in original_env_vars.items():
            if original_value is None:
                del os.environ[key]
            else:
                os.environ[key] = original_value

#################################################################################
############### EF COMMAND BUILDERS #############################################
#################################################################################
    
def get_ef_command(command_type, startup_project, project, db_name):
    return f"dotnet ef {command_type} --startup-project {os.path.join(openclone_root_dir, startup_project)} --project {os.path.join(openclone_root_dir, project)} --context {db_name}"

def get_migration_commands(startup_project, project, db_name):
    return f"""
        {get_ef_command(f"migrations add {db_name}_{uuid.uuid4().hex[:8]}", startup_project, project, db_name)}
        {get_ef_command(f"database update", startup_project, project, db_name)}
    """

#################################################################################
############### FILE SYSTEM RESET ###############################################
#################################################################################

def delete_dir(dir_to_delete):
    if os.path.exists(dir_to_delete): 
        shutil.rmtree(dir_to_delete)

def delete_migrations_directories():
    delete_dir(os.path.join(openclone_root_dir, "Website/OpenClone.Services/Migrations"))
    delete_dir(os.path.join(openclone_root_dir, "Website/OpenClone.Core/Migrations"))

#################################################################################
############### MIGRATION PROCESSES #############################################
#################################################################################

def migrate(openclone_db_connnection_string, log_db_connnection_string, database_reset=True):
    new_env_vars = {
        "OpenClone_DefaultConnection_Super": openclone_db_connnection_string,
        "OpenClone_LogDbConnection_Super": log_db_connnection_string
    }
    
    with temporary_env_vars(new_env_vars):
        if database_reset:
            delete_migrations_directories()

        run_powershell_commands(f"""
            $env:OpenClone_EF_MIGRATION='True' # this is tied to an if check in ServicesSetup.cs
            {get_migration_commands("Website/OpenClone.UI/OpenClone.UI.csproj", "Website/OpenClone.Core/OpenClone.Core.csproj", "LogDbContext")}
            {get_migration_commands("Website/OpenClone.UI/OpenClone.UI.csproj", "Website/OpenClone.Services/OpenClone.Services.csproj", "ApplicationDbContext")}
        """)