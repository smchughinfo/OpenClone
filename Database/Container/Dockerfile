# Use the official PostgreSQL base image from the Docker Hub
FROM postgres:15

# Expose PostgreSQL port
EXPOSE 5432

# Install dependencies for pgvector
RUN apt-get update && \
    apt-get install -y postgresql-server-dev-15 gcc make curl

# Install pgvector
RUN curl -L https://github.com/pgvector/pgvector/archive/refs/tags/v0.6.0.tar.gz -o pgvector.tar.gz && \
    tar -xzf pgvector.tar.gz && \
    cd pgvector-0.6.0 && \
    make && \
    make install

# Copy SQL files for postgres to run when it starts
COPY ./SQL/DBConfiguration /docker-entrypoint-initdb.d/
COPY ./SQL/StoredProcedures /docker-entrypoint-initdb.d/

# Run PostgreSQL
CMD ["/bin/bash", "-c", "docker-entrypoint.sh postgres"]