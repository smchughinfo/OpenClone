CREATE OR REPLACE PROCEDURE create_db_user(
    db_name TEXT,
    db_user TEXT,
    db_user_password TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    schema_owner_oid OID;
    schema_owner TEXT;
BEGIN
    -- Ensure the procedure is executed in the target database
    -- Cannot switch databases in a procedure

    -- Create the new user if it doesn't exist
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = db_user) THEN
        RAISE NOTICE 'Creating user %', db_user;
        EXECUTE format('CREATE ROLE %I WITH LOGIN PASSWORD %L', db_user, db_user_password);
    ELSE
        RAISE NOTICE 'User % already exists', db_user;
    END IF;

    -- Grant CONNECT privilege on the database to the user
    RAISE NOTICE 'Granting CONNECT privilege on database % to user %', db_name, db_user;
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO %I', db_name, db_user);

    -- Grant USAGE and CREATE privileges on the public schema to the user
    RAISE NOTICE 'Granting USAGE and CREATE privileges on schema public to user %', db_user;
    EXECUTE format('GRANT USAGE, CREATE ON SCHEMA public TO %I', db_user);

    -- Grant privileges on all existing tables and sequences in the public schema
    RAISE NOTICE 'Granting CRUD privileges on all existing tables and sequences in schema public to user %', db_user;
    EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO %I', db_user);
    EXECUTE format('GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO %I', db_user);

    -- Get the owner of the public schema
    SELECT nspowner INTO schema_owner_oid FROM pg_namespace WHERE nspname = 'public';
    SELECT rolname INTO schema_owner FROM pg_roles WHERE oid = schema_owner_oid;
    RAISE NOTICE 'Schema public is owned by %', schema_owner;

    -- Ensure future tables and sequences inherit the permissions
    RAISE NOTICE 'Setting default privileges for future tables and sequences';
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE %I IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO %I', schema_owner, db_user);
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE %I IN SCHEMA public GRANT USAGE ON SEQUENCES TO %I', schema_owner, db_user);
END;
$$;
