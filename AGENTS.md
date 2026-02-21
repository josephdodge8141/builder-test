# AGENTS.md

## Overview

Fullstack application with FastAPI backend, React frontend, and PostgreSQL database.

## Architecture

```
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│     db     │──▶│   backend   │──▶│  frontend   │
│  (postgres)│   │  (fastapi)  │   │   (react)   │
└─────────────┘   └─────────────┘   └─────────────┘
```

## Getting Started

The [port-finder](https://github.com/anomalyco/port-finder) service must be running for startup to work.

```bash
# Setup environment
cp .env.example .env
# Edit .env - set PROJECT_NAME

# Start the application
docker compose up --build
```

## Project Structure

```
.
├── AGENTS.md              # This file
├── docker-compose.yml     # Service orchestration
├── .env.example          # Environment template
├── backend/
│   ├── AGENTS.md         # Backend patterns & commands
│   ├── requirements.txt
│   ├── alembic.ini
│   ├── app/
│   │   ├── main.py       # FastAPI entrypoint
│   │   ├── database.py   # SQLAlchemy setup
│   │   ├── models/       # ORM models
│   │   ├── schemas/      # Pydantic schemas
│   │   └── api/          # Route handlers
│   └── alembic/          # Migrations
└── frontend/
    ├── AGENTS.md         # Frontend patterns & commands
    ├── package.json
    ├── playwright.config.ts
    ├── tests/            # E2E tests
    └── src/
        ├── features/     # Page-based modules
        │   └── <page>/
        │       ├── README.md    # Product spec (REQUIRED)
        │       └── ...
        └── ...
```

## Commands

### All Services
```bash
docker compose up --build     # Build and start
docker compose down           # Stop and remove
docker compose logs -f        # Follow logs
docker compose ps             # Check status
```

### Backend
```bash
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
npm run format               # Format (prettier)
npm run lint                 # Lint
npm run lint:fix            # Lint & fix
npm run typecheck           # Type check (tsc)
npx playwright test         # Run tests
npx playwright test --ui    # UI mode
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

## Feature Development

### Frontend

Each feature lives in `src/features/<page-name>/`:

```
src/features/<page-name>/
├── README.md           # Product spec (REQUIRED)
├── index.ts            # Exports
├── <PageName>Page.tsx  # Main page component
└── components/         # Feature-specific components
```

See `frontend/AGENTS.md` for detailed feature README template.

## Database Migrations

```bash
# Create migration
alembic revision --autogenerate -m "description"

# Run migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```
