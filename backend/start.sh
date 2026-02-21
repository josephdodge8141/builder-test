#!/bin/sh
set -e

SERVICE_TYPE=${SERVICE_TYPE:-backend}
PORT=${PORT:-8000}
HOST_PORT=${HOST_PORT:-$PORT}

if [ "$SERVICE_TYPE" = "db" ]; then
    echo "Starting PostgreSQL..."
    exec postgres \
        -c postgres \
        -c user=${POSTGRES_USER:-postgres} \
        -c password=${POSTGRES_PASSWORD:-postgres} \
        -c database=${POSTGRES_DB:-app}
fi

if [ "$SERVICE_TYPE" = "backend" ]; then
    DATABASE_URL=${DATABASE_URL:-postgresql+asyncpg://postgres:postgres@db:5432/$POSTGRES_DB}
    DATABASE_URL_SYNC=${DATABASE_URL_SYNC:-postgresql://postgres:postgres@db:5432/$POSTGRES_DB}
    
    export DATABASE_URL
    export DATABASE_URL_SYNC
    
    echo "Waiting for database..."
    until pg_isready -h db -U postgres > /dev/null 2>&1; do
        echo "Waiting for database..."
        sleep 2
    done
    
    echo "Running migrations..."
    alembic upgrade head
    
    echo "Starting uvicorn on port ${PORT}..."
    exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT} --reload
fi

echo "Unknown SERVICE_TYPE: $SERVICE_TYPE"
exit 1
