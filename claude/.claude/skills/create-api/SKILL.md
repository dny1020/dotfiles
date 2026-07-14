---
name: create-api
description: "Creates or reviews a production-ready FastAPI endpoint. Invoked when: adding a new REST endpoint, reviewing an existing route for production-readiness, or wiring a router into a FastAPI app. Covers: request/response validation, dependency injection, error handling, OpenAPI docs, and logging."
---

<skill>
Create or review the FastAPI endpoint and apply the following checklist. Fix every issue found and explain each change in one line.

## Dependencies
- New packages go in via `uv add <package>` (or `uv add --dev` for test/dev-only deps) — never edit `pyproject.toml` dependencies by hand or use `pip install`.

## Request/response validation
- Request body, query params, and path params are typed Pydantic models — never raw `dict` or untyped `**kwargs`.
- Response model declared via `response_model=` so the OpenAPI schema and the actual response can't drift apart.
- Constrained fields (`min_length`, `max_length`, `ge`, `le`, regex) used wherever the domain has a real constraint — don't leave it to the caller to find out at runtime.

## Dependency injection
- DB sessions, current user, and config come through `Depends()` — no global session or module-level client.
- Auth/permission checks live in a dependency, not duplicated inline in every handler that needs them.

## Error handling
- Every external call (DB, HTTP, cache) is wrapped; failures raise `HTTPException` with the correct status code, not a raw 500 leaking a stack trace.
- 4xx for caller errors (validation, not found, forbidden), 5xx only for genuine server-side failures.
- No bare `except:` — catch specific exceptions and translate them to the right HTTP response.

## OpenAPI documentation
- Endpoint has a `summary` and, if the behavior isn't obvious from the name, a `description`.
- Response model and status codes are declared so `/docs` reflects reality, including documented error responses via `responses=`.

## Logging
- Log at the service boundary (not inside the router) with enough context to debug in production: request id, user id if available, operation name.
- Never log the raw request body, auth headers, or any field that could carry secrets or PII.

## Output format
For each issue found:
```
[ISSUE] <file>:<line or section> — <description>
[FIX]   <what was changed and why>
```
Then show the corrected endpoint code. End with the exact route signature and an example request/response.
</skill>
