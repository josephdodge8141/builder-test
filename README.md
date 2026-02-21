# Fullstack Template

A fullstack application template with FastAPI, React, and PostgreSQL designed for running multiple instances simultaneously in Docker-in-Docker environments.

## Structure

```
.
├── port-finder/           # Shared port allocation service (run once)
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── app.py            # Flask API for port management
│   └── requirements.txt
│
└── fullstack-template/     # Template for each new app
    ├── startup.sh         # Single command to start app
    ├── docker-compose.yml
    ├── AGENTS.md          # Agent guidelines
    ├── backend/
    │   ├── AGENTS.md     # Backend patterns
    │   ├── app/          # FastAPI application
    │   └── alembic/      # Database migrations
    └── frontend/
        ├── AGENTS.md     # Frontend patterns
        ├── src/
        │   └── features/ # Page-based modules
        └── tests/         # Playwright tests
```

## Quick Start

### 1. Start Port Finder (One-Time)

```bash
cd port-finder
docker compose up -d
```

The port-finder service runs on port 8080 and manages dynamic port allocation for all instances.

### 2. Create New App

```bash
# Copy template to new directory
cp -r fullstack-template my-new-app
cd my-new-app

# Setup environment
cp .env.example .env
# Edit .env - set PROJECT_NAME=mynewapp
```

### 3. Start the Application

```bash
./startup.sh
```

This single command:
- Waits for port-finder to be ready
- Allocates 3 unique ports (db, backend, frontend)
- Starts all services with allocated ports
- Releases ports on shutdown

## Running Multiple Instances

Each instance gets its own set of ports starting at 40000:

```bash
# Terminal 1 - Instance 1
cd instance1
./startup.sh

# Terminal 2 - Instance 2
cd instance2
./startup.sh
```

Check allocated ports:
```bash
curl http://localhost:8080/status
```

## Accessing Services

After startup, services are available at:
- **Frontend**: http://localhost:{FRONTEND_PORT}
- **Backend API**: http://localhost:{BACKEND_PORT}
- **Backend Health**: http://localhost:{BACKEND_PORT}/health
- **Database**: localhost:{DB_PORT}

## Commands

### Fullstack Template
```bash
./startup.sh              # Start all services
./startup.sh -d           # Start in detached mode
docker compose down       # Stop services (releases ports)

# Rebuild
docker compose build
./startup.sh
```

### Port Finder
```bash
cd port-finder
docker compose up -d      # Start
docker compose down       # Stop

# Check allocated ports
curl http://localhost:8080/status

# Release specific port
curl http://localhost:8080/release/service-name
```

## Development

### Backend
```bash
# Inside backend container
black .                   # Format
isort .                  # Import sort
ruff check .             # Lint
mypy .                   # Type check
pytest -v               # Tests
alembic upgrade head    # Run migrations
```

### Frontend
```bash
# Inside frontend container
npm run format           # Format
npm run lint             # Lint
npm run typecheck        # Type check
npx playwright test     # E2E tests
```

See `fullstack-template/AGENTS.md` for detailed development patterns.
