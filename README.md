# Fullstack Template

A fullstack application template with FastAPI, React, and PostgreSQL.

## Prerequisites

- Docker and Docker Compose
- The [port-finder](https://github.com/anomalyco/port-finder) service must be running (required for startup to allocate ports)

## Quick Start

```bash
# Setup environment
cp .env.example .env
# Edit .env - set PROJECT_NAME

# Start the application
docker compose up --build
```

## Accessing Services

After startup, services are available at:
- **Frontend**: http://localhost:{FRONTEND_PORT}
- **Backend API**: http://localhost:{BACKEND_PORT}
- **Backend Health**: http://localhost:{BACKEND_PORT}/health

## Commands

```bash
docker compose up --build     # Build and start
docker compose down           # Stop services
docker compose logs -f        # Follow logs
docker compose ps             # Check status

# Rebuild
docker compose build
docker compose up
```

## Development

### Backend
```bash
black .                   # Format
isort .                  # Import sort
ruff check .             # Lint
mypy .                   # Type check
pytest -v               # Tests
alembic upgrade head    # Run migrations
```

### Frontend
```bash
npm run format           # Format
npm run lint             # Lint
npm run typecheck        # Type check
npx playwright test     # E2E tests
```

See `AGENTS.md` for detailed development patterns.
