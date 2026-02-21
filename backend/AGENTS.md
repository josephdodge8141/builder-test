# Backend AGENTS.md

## Overview

FastAPI backend with SQLAlchemy ORM and Alembic migrations. All database operations use async SQLAlchemy with asyncpg.

## Project Structure

```
backend/
├── AGENTS.md              # This file
├── Dockerfile             # For FastAPI app
├── Dockerfile.db          # For PostgreSQL
├── requirements.txt       # Python dependencies
├── alembic.ini           # Alembic configuration
├── wait-and-release.sh   # Port allocation wrapper
├── start.sh              # Service startup script
├── app/
│   ├── __init__.py
│   ├── main.py           # FastAPI application entrypoint
│   ├── database.py       # SQLAlchemy async engine setup
│   ├── models/           # SQLAlchemy ORM models
│   │   ├── __init__.py
│   │   └── <model_name>.py
│   ├── schemas/           # Pydantic request/response schemas
│   │   ├── __init__.py
│   │   └── <schema_name>.py
│   └── api/              # API route handlers
│       ├── __init__.py
│       └── routes/
│           ├── __init__.py
│           └── <route_name>.py
└── alembic/
    ├── env.py            # Alembic environment config
    └── versions/         # Migration files
```

## Models

- Each model in its own file under `app/models/`
- Use `Base` from `database.py` as parent class
- Include `__init__.py` that imports all models for easy access
- Use SQLAlchemy's `Column`, `Integer`, `String`, `DateTime`, etc.
- Always include `id` as primary key and `created_at`/`updated_at` timestamps

Example model:
```python
# app/models/user.py
from sqlalchemy import Column, Integer, String, DateTime
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
```

## Schemas

- Pydantic models for request/response validation
- Separate schemas for: Request, Response, Update
- Use `BaseModel` from pydantic
- Include `model_config = ConfigDict(from_attributes=True)` for ORM compatibility

Example schema:
```python
# app/schemas/user.py
from pydantic import BaseModel, ConfigDict, EmailStr
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    username: str

class UserCreate(UserBase):
    password: str

class UserResponse(UserBase):
    id: int
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)

class UserUpdate(BaseModel):
    email: EmailStr | None = None
    username: str | None = None
```

## API Routes

- Each route in its own file under `app/api/routes/`
- Use APIRouter from FastAPI
- Include tags for OpenAPI documentation
- Follow RESTful conventions

Example route:
```python
# app/api/routes/users.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.models import User
from app.schemas import UserCreate, UserResponse

router = APIRouter(prefix="/users", tags=["users"])

@router.post("/", response_model=UserResponse)
async def create_user(
    user: UserCreate,
    db: AsyncSession = Depends(get_db)
):
    # Implementation here
    pass
```

## Database

- Async SQLAlchemy with asyncpg driver
- Use `get_db` dependency for async session injection
- All queries must be async/await

```python
# app/database.py
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from sqlalchemy.orm import declarative_base

DATABASE_URL = os.environ.get("DATABASE_URL", "postgresql+asyncpg://user:pass@localhost/db")

engine = create_async_engine(DATABASE_URL, echo=True)
async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

Base = declarative_base()

async def get_db():
    async with async_session() as session:
        yield session
```

## Commands

### Format
```bash
black .
isort .
```

### Lint
```bash
ruff check .
ruff check --fix .
```

### Typecheck
```bash
mypy .
```

### Test
```bash
pytest -v
pytest -v --cov=app --cov-report=html
```

### Migrations
```bash
# Create migration
alembic revision --autogenerate -m "description"

# Run migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```

## Testing

### Test Database Setup

The project includes a test database configuration. To use:

1. Create a test database:
   ```sql
   CREATE DATABASE test_appname;
   ```

2. Set environment variable:
   ```
   TEST_DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost/test_appname
   ```

3. Use the test database in conftest.py:
   ```python
   # tests/conftest.py
   import os
   import pytest
   from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
   from app.database import Base
   
   TEST_DATABASE_URL = os.environ.get(
       "TEST_DATABASE_URL",
       "postgresql+asyncpg://postgres:postgres@localhost/test_appname"
   )
   
   @pytest.fixture(scope="session")
   def engine():
       engine = create_async_engine(TEST_DATABASE_URL, echo=False)
       yield engine
       await engine.dispose()
   
   @pytest.fixture(scope="function")
   async def db_session(engine):
       async with engine.begin() as conn:
           await conn.run_sync(Base.metadata.create_all)
       
       async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
       async with async_session() as session:
           yield session
           await session.rollback()
       
       async with engine.begin() as conn:
           await conn.run_sync(Base.metadata.drop_all)
   ```

### Writing Tests

- ALWAYS write tests FIRST before implementing features
- Test edge cases thoroughly
- NEVER use mocks - connect to real test database
- Use test fixtures for database setup
- Test all API endpoints with actual HTTP requests via `TestClient` or `httpx`

Example:
```python
# tests/test_users.py
import pytest
from httpx import AsyncClient
from app.main import app

@pytest.mark.asyncio
async def test_create_user(db_session):
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/users/",
            json={"email": "test@example.com", "username": "test", "password": "password123"}
        )
    
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"
    assert "id" in data

@pytest.mark.asyncio
async def test_create_user_duplicate_email(db_session):
    # First create
    # Then try duplicate - should fail with 400
    pass
```

## Dependency Injection

Use FastAPI's Depends for:
- Database sessions
- Authentication
- Authorization
- Common operations

```python
async def get_current_user(
    current_user: User = Depends(get_current_user_from_token)
):
    if not current_user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    return current_user
```

## Error Handling

- Use HTTPException for expected errors
- Create custom exception handlers in main.py for consistent error responses
- Always return meaningful error messages

```python
from fastapi import HTTPException, status

@router.get("/{user_id}")
async def get_user(user_id: int, db: AsyncSession = Depends(get_db)):
    user = await get_user_by_id(user_id, db)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
```

## Security

- Never store plain passwords - use bcrypt or similar
- Use environment variables for secrets
- Implement proper CORS configuration
- Validate all inputs with Pydantic schemas

## Performance

- Use indexing on frequently queried columns
- Implement pagination for list endpoints
- Use lazy loading appropriately
- Consider caching for expensive operations
