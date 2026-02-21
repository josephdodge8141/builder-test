#!/bin/sh
set -e

echo "Starting frontend..."
exec npm run dev -- --host 0.0.0.0 --port 5173
