#!/bin/sh
set -e

DATABASE_URL=${DATABASE_URL:-postgresql+asyncpg://postgres:postgres@db:5432/$POSTGRES_DB}
DATABASE_URL_SYNC=${DATABASE_URL_SYNC:-postgresql://postgres:postgres@db:5432/$POSTGRES_DB}

export DATABASE_URL
export DATABASE_URL_SYNC

echo "Waiting for database..."
until pg_isready -h db -U postgres > /dev/null 2>&1; do
    echo "Waiting for database..."
    sleep 2
done

echo "Ensuring database exists..."
until PGPASSWORD=postgres psql -h db -U postgres -d postgres -c "SELECT 1" > /dev/null 2>&1; do
    echo "Waiting for database to accept connections..."
    sleep 2
done

PGPASSWORD=postgres psql -h db -U postgres -d postgres -c "SELECT 1 FROM pg_database WHERE datname = '$POSTGRES_DB'" | grep -q 1 || \
    PGPASSWORD=postgres psql -h db -U postgres -d postgres -c "CREATE DATABASE $POSTGRES_DB"

echo "Database ready"

echo "Running migrations..."
alembic upgrade head

echo "Starting uvicorn..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
