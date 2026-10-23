---
name: build-backend
description: "Python/FastAPI/PostgreSQL server-side work. Invoked when: adding or reviewing an endpoint, Pydantic models, dependency injection, auth, a schema or Alembic migration, business logic, or a background worker."
---

<skill>
Build or review the backend change against this checklist. Fix every issue found and explain each change in one line.

Stack: **Python** (`uv`), **FastAPI**, **PostgreSQL**, **Redis** only when caching or queues are needed. `Depends(...)` in an argument default trips ruff's `B008`, so projects ignore that rule rather than fight the idiom.

## Layering
- Routers thin, services fat: `routers/` wires HTTP to `services/`, `services/` holds business logic, `repositories/` or `models/` hold data access. The domain doesn't know about HTTP.
- No generic repository pattern or interface layer until there are already multiple implementations that need it.
- Background work (emails, ETL, long jobs) goes through a worker or queue, never inline in the request path.

## App setup
- Config via `pydantic-settings`, not scattered `os.environ` reads.
- Long-lived clients (DB engine, Redis, AMI/ARI) are created once in `lifespan` (not `on_event`) and injected with `Depends()` — never one connection per request.
- Blocking I/O (`requests`, a sync DB driver, `time.sleep`) never runs inside `async def`; use a plain `def` route, which FastAPI runs in a threadpool.

## Request/response validation
- Request body, query and path params are typed Pydantic models — never raw `dict` or untyped `**kwargs`.
- `response_model=` is declared and ORM models are never returned directly, so OpenAPI and the real response can't drift.
- Constrained fields (`min_length`, `max_length`, `ge`, `le`) wherever the domain has a real constraint.

## Dependency injection
- DB sessions, current user and config come through `Depends()` — no global session or module-level client.
- Auth/permission checks live in a dependency, not duplicated inline in every handler.

## Database and migrations
- SQLAlchemy or parameterized queries — never string-formatted SQL.
- Alembic, one migration per schema change, reversible when feasible; never `create_all()` at startup. Show the migration alongside the model change.

## Error handling
- External calls (DB, HTTP, cache) translate failures into `HTTPException` with the right status code, not a raw 500 leaking a stack trace.
- 4xx for caller errors, 5xx only for genuine server-side failures. Catch specific exceptions; no bare `except:`.

## OpenAPI
- Every endpoint has a `summary`; add `description` and `responses=` when behavior or errors aren't obvious from the name.

## Logging
- Log at the service boundary with request id, user id if available, and operation name.
- Never log raw request bodies, auth headers, or fields that could carry secrets or PII.

## Done
- New packages via `uv add` (or `uv add --dev`) — never hand-edit `pyproject.toml` dependencies, never `pip install`.
- Call out any endpoint missing auth or input validation rather than silently adding it. End with the route signature and an example request/response.
</skill>
