#!/bin/sh
set -e

SERVICE_TYPE=${SERVICE_TYPE:-backend}
PROJECT_NAME=${PROJECT_NAME:-app}
PORT_FINDER_URL=${PORT_FINDER_URL:-http://port-finder:8080}

SERVICE_NAME="${PROJECT_NAME}-${SERVICE_TYPE}"

echo "Waiting for port-finder service..."
until wget -qO- "${PORT_FINDER_URL}/health" > /dev/null 2>&1; do
    echo "Waiting for port-finder..."
    sleep 2
done

echo "Allocating port for ${SERVICE_NAME}..."
PORT=$(wget -qO- "${PORT_FINDER_URL}/allocate?service=${SERVICE_NAME}" | grep -o '"port":[0-9]*' | cut -d: -f2)

if [ -z "$PORT" ]; then
    echo "Failed to allocate port"
    exit 1
fi

export PORT
export HOST_PORT=$PORT

echo "Allocated port ${PORT} for ${SERVICE_NAME}"

trap "echo 'Releasing port ${PORT} for ${SERVICE_NAME}...'; wget -qO- '${PORT_FINDER_URL}/release/${SERVICE_NAME}' || true" EXIT

echo "Starting service with PORT=${PORT}..."
exec /app/start.sh
