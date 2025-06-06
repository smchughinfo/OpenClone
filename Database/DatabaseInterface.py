import psycopg2
import subprocess
import os
import shutil

class DatabaseManager:
    def __init__(self, connection_string):
        connection_object = DatabaseManager.convert_connection_string_to_object(connection_string)
        self.db_name = connection_object["Database"]
        self.user = connection_object["Username"]
        self.password = connection_object["Password"]
        self.host = connection_object["Host"]
        self.port = connection_object["Port"]
        self.backup_directory = "Backups/" + connection_object["Database"] + "_db"

    def backup_database(self):
        self._delete_existing_migrations()
        for table in self._get_all_tables():
            ignore_table = table == "__EFMigrationsHistory"
            if not ignore_table:
                self._export_table_data(table)

    def _delete_existing_migrations(self):
        if os.path.exists(self.backup_directory):
            for filename in os.listdir(self.backup_directory):
                file_path = os.path.join(self.backup_directory, filename)
                try:
                    if os.path.isfile(file_path) or os.path.islink(file_path):
                        os.unlink(file_path)
                    elif os.path.isdir(file_path):
                        shutil.rmtree(file_path)
                except Exception as e:
                    print(f'Failed to delete {file_path}. Reason: {e}')

    def _export_table_data(self, table):
        try:
            command = [
                'pg_dump',
                f'-U{self.user}',
                f'-h{self.host}',
                f'-p{self.port}',
                f'-d{self.db_name}',
                f'-t{table}',
                '--data-only',
                '--column-inserts',
                f'-f{self.backup_directory}/{table}.sql'
            ]
            env = os.environ.copy()
            env['PGPASSWORD'] = self.password
            subprocess.run(command, check=True, env=env)
            self.disable_fk_check(os.path.join(self.backup_directory, table + ".sql"))
            print(f"Data exported successfully for {table}")
        except subprocess.CalledProcessError as e:
            print(f"An error occurred while exporting data: {e}")

    # https://stackoverflow.com/a/49584660
    def disable_fk_check(self, script_path):
        with open(script_path, 'r', encoding='utf-8') as file:
            original_content = file.read()

        new_content = (
            "SET session_replication_role = 'replica';\n" +
            original_content +
            "\nSET session_replication_role = 'origin';"
        )

        with open(script_path, 'w', encoding='utf-8') as file:
            file.write(new_content)

    def _get_all_tables(self):
        try:
            command = [
                'psql',
                f'-U{self.user}',
                f'-h{self.host}',
                f'-p{self.port}',
                f'-d{self.db_name}',
                '-c', '\\dt'
            ]
            env = os.environ.copy()
            env['PGPASSWORD'] = self.password
            result = subprocess.run(command, check=True, capture_output=True, text=True, env=env)
            tables = self._parse_tables(result.stdout)
            return tables
        except subprocess.CalledProcessError as e:
            print(f"An error occurred while retrieving tables: {e}")
            return []

    def _parse_tables(self, psql_output):
        tables = []
        lines = psql_output.splitlines()
        for line in lines:
            if line.startswith(' public |'):
                table_info = line.split('|')
                if len(table_info) > 2:
                    table_name = table_info[1].strip()
                    tables.append(table_name)
        return tables

    def delete_database(self):
        try:
            conn = psycopg2.connect(dbname='postgres', user=self.user, password=self.password, host=self.host, port=self.port)
            conn.autocommit = True
            cursor = conn.cursor()
            
            # Terminate all connections to the target database
            cursor.execute(f"""
            SELECT pg_terminate_backend(pg_stat_activity.pid)
            FROM pg_stat_activity
            WHERE pg_stat_activity.datname = '{self.db_name}'
            AND pid <> pg_backend_pid();
            """)

            # Drop the database
            cursor.execute(f"DROP DATABASE IF EXISTS {self.db_name}")
            
            cursor.close()
            conn.close()
            print(f"Database {self.db_name} deleted successfully.")
        except psycopg2.Error as e:
            print(f"Error during database deletion: {e}")
            raise

    def create_database(self):
        try:
            # Connect to the default 'postgres' database to create the new database
            conn = psycopg2.connect(dbname='postgres', user=self.user, password=self.password, host=self.host, port=self.port)
            conn.autocommit = True
            cursor = conn.cursor()
            
            # Check if database already exists
            cursor.execute("SELECT 1 FROM pg_catalog.pg_database WHERE datname = %s", (self.db_name,))
            exists = cursor.fetchone()
            
            if exists:
                print(f"Database {self.db_name} already exists.")
            else:
                # Create the database
                cursor.execute(f"CREATE DATABASE {self.db_name}")
                print(f"Database {self.db_name} created successfully.")
            
            cursor.close()
            conn.close()
            
        except psycopg2.Error as e:
            print(f"Error during database creation: {e}")
            raise

    def populate_database(self):
        try:
            # List all SQL files in the backup directory
            tables = os.listdir(self.backup_directory)

            for tableScript in tables:
                if tableScript.endswith('.sql'):
                    script_path = os.path.join(self.backup_directory, tableScript)
                    # Execute each SQL file
                    command = [
                        'psql',
                        f'-U{self.user}',
                        f'-h{self.host}',
                        f'-p{self.port}',
                        f'-d{self.db_name}',
                        '-f', script_path
                    ]
                    env = os.environ.copy()
                    env['PGPASSWORD'] = self.password
                    subprocess.run(command, check=True, env=env)
                    print(f"Executed {script_path} successfully.")
        except subprocess.CalledProcessError as e:
            print(f"An error occurred while executing the script {tableScript}: {e}")

    def create_db_user(self, db_user, db_password):
        conn = psycopg2.connect(dbname=self.db_name, user=self.user, password=self.password, host=self.host, port=self.port)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Execute the stored procedure with the provided arguments
        cursor.execute("CALL create_db_user(%s, %s, %s)", (self.db_name, db_user, db_password))
        
        cursor.close()
        conn.close()
        print(f"Stored procedure 'create_db_user for user {db_user} on database {self.db_name}' executed successfully.")

    def create_stored_proc(self, proc_path):
        with open(proc_path, 'r') as file:
            proc_sql = file.read() 
        
        conn = psycopg2.connect(dbname=self.db_name, user=self.user, password=self.password, host=self.host, port=self.port)
        conn.autocommit = True
        cursor = conn.cursor()

        cursor.execute(proc_sql)
        
        cursor.close()
        conn.close()

    def convert_connection_string_to_object(connection_string):
        # Split the string by ';' to separate key-value pairs
        items = connection_string.split(';')
        
        # Remove any empty items from the list (in case the string ends with a ';')
        items = [item for item in items if item]

        # Convert the key-value pairs into a dictionary
        connection_dict = {}
        for item in items:
            key, value = item.split('=')
            connection_dict[key.strip()] = value.strip()
        
        return connection_dict