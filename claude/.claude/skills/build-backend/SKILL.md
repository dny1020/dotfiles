---
name: build-backend
description: "Python/FastAPI/PostgreSQL server-side work. Invoked when: adding or reviewing an endpoint, designing a schema or Alembic migration, writing business logic or auth, or adding a background worker."
---

<skill>
Build or review the backend change and apply the following checklist. Fix every issue found and explain each change in one line.

Stack: **Python** (managed with `uv`), **FastAPI**, **PostgreSQL**, **Redis** when caching or queues are needed. Style rules live in AGENTS.md and already apply; the one FastAPI-specific note is that `Depends(...)` in an argument default trips ruff's `B008`, so projects ignore that rule rather than fight the idiom.

## Layering
- Routers thin, services fat: `routers/` wires HTTP to `services/`, `services/` holds business logic, `repositories/` or `models/` hold data access. The domain doesn't know about HTTP.
- No generic repository pattern or interface layer until there are already multiple implementations that need it.
- Background work (emails, ETL, long jobs) goes through a worker or queue, never inline in the request path.

## Request/response validation
- Request body, query params, and path params are typed Pydantic models — never raw `dict` or untyped `**kwargs`.
- Response model declared via `response_model=` so the OpenAPI schema and the actual response can't drift apart.
- Constrained fields (`min_length`, `max_length`, `ge`, `le`, regex) used wherever the domain has a real constraint — don't leave it to the caller to find out at runtime.

## Dependency injection
- DB sessions, current user, and config come through `Depends()` — no global session or module-level client.
- Auth/permission checks live in a dependency, not duplicated inline in every handler that needs them.

## Database and migrations
- SQLAlchemy or raw parameterized queries — never string-formatted SQL.
- Migrations via Alembic, one migration per schema change, reversible when feasible. Show the migration alongside the model change.

## Error handling
- Every external call (DB, HTTP, cache) is wrapped; failures raise `HTTPException` with the correct status code, not a raw 500 leaking a stack trace.
- 4xx for caller errors (validation, not found, forbidden), 5xx only for genuine server-side failures.
- No bare `except:` — catch specific exceptions and translate them to the right HTTP response. Don't wrap code that can't fail.

## OpenAPI documentation
- Endpoint has a `summary` and, if the behavior isn't obvious from the name, a `description`.
- Response model and status codes are declared so `/docs` reflects reality, including documented error responses via `responses=`.

## Logging
- Log at the service boundary (not inside the router) with enough context to debug in production: request id, user id if available, operation name.
- Never log the raw request body, auth headers, or any field that could carry secrets or PII.

## Checks
- New packages go in via `uv add <package>` (or `uv add --dev`) — never edit `pyproject.toml` dependencies by hand, never `pip install`.
- The change isn't done until `uv run ruff check . && uv run ruff format --check . && uv run pyright app tests && uv run pytest` passes — run it yourself. `pyright` is the type checker, not mypy; adapt the paths if the layout isn't `app`/`tests`.

## Output format
For each issue found:
```
[ISSUE] <file>:<line or section> — <description>
[FIX]   <what was changed and why>
```
Then show the corrected code. Call out any endpoint missing auth or input validation rather than silently adding it. End with the exact route signature and an example request/response.
</skill>
