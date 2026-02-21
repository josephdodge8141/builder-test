#!/bin/sh
set -e

PORT=${PORT:-5173}

echo "Starting frontend on port ${PORT}..."
exec npm run dev -- --host 0.0.0.0 --port ${PORT}
