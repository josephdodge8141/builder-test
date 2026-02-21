# AGENTS.md

## Overview

This is a fullstack template with FastAPI backend, React frontend, and PostgreSQL database. It is designed to run in Docker-in-Docker environments where volumes do not work.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  port-finder (external service - must be running)       │
│  - Manages dynamic port allocation                      │
│  - Persists state in named volume                       │
│  - Endpoints: /allocate, /release, /status              │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│     db     │──▶│   backend   │──▶│  frontend   │
│  (postgres)│   │  (fastapi)  │   │   (react)   │
└─────────────┘   └─────────────┘   └─────────────┘
```

## Getting Started

### Prerequisites

1. Start the port-finder service (one-time):
   ```bash
   cd ../port-finder
   docker compose up -d
   ```

2. Copy template to new project:
   ```bash
   cp -r fullstack-template my-new-app
   cd my-new-app
   ```

3. Setup environment:
   ```bash
   cp .env.example .env
   # Edit .env - set PROJECT_NAME
   ```

4. Start the application:
   ```bash
   docker compose up --build
   ```

### Port Allocation

Ports are dynamically allocated starting at 40000. The port-finder service manages port assignments:
- Each service requests a port on startup
- Ports are released when services stop
- Check allocated ports: `curl http://localhost:8080/status`

### Important: No Data Persistence

Since this runs in Docker-in-Docker without volumes:
- Database data is LOST when containers stop/restart
- This is intentional for development/testing
- Do not use for production data

## Project Structure

```
fullstack-template/
├── AGENTS.md              # This file
├── docker-compose.yml     # Orchestrates all services
├── .env.example          # Environment template
├── backend/
│   ├── AGENTS.md         # Backend-specific patterns
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── alembic.ini
│   ├── app/              # Application code
│   │   ├── main.py       # FastAPI entrypoint
│   │   ├── database.py   # SQLAlchemy setup
│   │   ├── models/       # SQLAlchemy models
│   │   ├── schemas/      # Pydantic schemas
│   │   └── api/          # API routes
│   └── alembic/          # Database migrations
└── frontend/
    ├── AGENTS.md         # Frontend-specific patterns
    ├── Dockerfile
    ├── playwright.config.ts
    ├── tests/            # Playwright tests
    └── src/
        ├── features/     # Page-based feature modules
        │   └── <page>/
        │       ├── README.md    # REQUIRED: Product spec
        │       ├── components/
        │       └── index.ts
        └── ...
```

## Multi-Instance Running

When running multiple instances of this template:

1. Each instance needs a unique `PROJECT_NAME` in `.env`
2. The port-finder service maintains port state across all instances
3. Each instance gets its own set of ports (db, backend, frontend)
4. Services clean up their ports on shutdown via the release endpoint

Example:
```bash
# Instance 1
cd app1 && docker compose up  # Gets ports 40000, 40001, 40002

# Instance 2 (runs concurrently)
cd app2 && docker compose up  # Gets ports 40003, 40004, 40005
```

## Commands Reference

### All Services
```bash
docker compose up --build     # Build and start
docker compose down           # Stop and remove
docker compose logs -f        # Follow logs
docker compose ps             # Check status
```

### Backend
```bash
# Inside container
black .                       # Format
isort .                       # Import sort
ruff check .                  # Lint
ruff check --fix .            # Lint & fix
mypy .                        # Type check
pytest -v                     # Run tests
pytest -v --cov=app           # With coverage
```

### Frontend
```bash
# Inside container
npm run format               # Format (prettier)
npm run lint                 # Lint
npm run lint:fix             # Lint & fix
npm run typecheck            # Type check (tsc)
npx playwright test          # Run tests
npx playwright test --ui     # UI mode
```

## Testing Guidelines

### Backend
- Write tests FIRST, then implement code
- Test edge cases thoroughly
- NEVER use mocks - use testcontainers or real test DB
- All API endpoints require test coverage

### Frontend
- Create feature README.md BEFORE writing code
- Write Playwright test that describes expected user experience
- Implement code to pass the test
- Update tests when requirements change
- Focus on user experience, not implementation details

## Troubleshooting

### Port Conflicts
If services fail to start due to port conflicts:
```bash
# Check what's using ports
curl http://localhost:8080/status

# Manually release if needed
curl http://localhost:8080/release/<service-name>
```

### Container Won't Start
```bash
# Check logs
docker compose logs <service-name>

# Rebuilddocker compose build --
no-cache <service-name>
```
