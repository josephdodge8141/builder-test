#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PORT_FINDER_URL="${PORT_FINDER_URL:-http://localhost:8080}"
PROJECT_NAME="${PROJECT_NAME:-app}"

echo "Waiting for port-finder service..."
until curl -s "$PORT_FINDER_URL/health" > /dev/null 2>&1; do
    echo "Waiting for port-finder..."
    sleep 2
done

echo "Allocating 3 ports for $PROJECT_NAME..."

RESPONSE=$(curl -s "$PORT_FINDER_URL/allocate?service=${PROJECT_NAME}&quantity=3")
echo "Port allocation response: $RESPONSE"

DB_PORT=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['ports'][0])")
BACKEND_PORT=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['ports'][1])")
FRONTEND_PORT=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['ports'][2])")

echo "Allocated ports: db=$DB_PORT, backend=$BACKEND_PORT, frontend=$FRONTEND_PORT"

# Generate .env file for docker compose
cat > .env << EOF
PROJECT_NAME=$PROJECT_NAME
DB_PORT=$DB_PORT
BACKEND_PORT=$BACKEND_PORT
FRONTEND_PORT=$FRONTEND_PORT
EOF

trap "echo 'Releasing ports...'; curl -s '$PORT_FINDER_URL/release/${PROJECT_NAME}' || true; rm -f .env" EXIT

echo "Starting services..."
docker compose up --build "$@"
