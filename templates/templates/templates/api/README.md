# Template: api

Genera un backend REST con FastAPI listo para produccion con cambios minimos, siguiendo la arquitectura fija definida en `SPEC.md` (raiz del repo).

## Uso

```bash
../../new.sh api ./mi-proyecto
# o equivalente:
uvx copier copy --trust templates/api ./mi-proyecto

cd mi-proyecto
uv sync
uv run uvicorn app.main:app --reload
```

## Preguntas

| Variable | Que controla |
|---|---|
| `project_name` / `project_slug` / `project_description` | Metadatos del proyecto (pyproject, README, docker-compose) |
| `author_name` | Autor en metadatos |
| `use_database` | Incluye `app/database.py`, `app/models.py`, Alembic, servicio Postgres/SQLite y CRUD de ejemplo (`/items`) |
| `db_engine` | `postgresql` (servicio Docker) o `sqlite` (archivo local) |
| `use_redis` | Agrega servicio Redis a docker-compose y `REDIS_URL` |
| `use_auth` | Protege los endpoints de negocio con un API key simple (header `X-API-Key`, ve `app/auth.py`) — `/health` siempre queda publico |
| `python_version` | Version usada en `pyproject.toml`, Dockerfile y CI |

Si necesitas un servicio enfocado en consumir APIs externas (sin ORM propio), usa `templates/webservice` en vez de este.

## Lo que genera

- `app/` plano: `main.py`, `config.py`, `schemas.py`, `services.py`, `routes.py`, `utils.py` (+ `database.py`/`models.py` si hay DB, `auth.py` si hay auth)
- `tests/` con pytest (happy path + 404 + 401 si aplica) usando SQLite en memoria
- `Dockerfile` + `docker-compose.yml` (multi-stage, usuario no-root, logs montados como volumen)
- `pyproject.toml` gestionado con `uv` (ruff (lint+format) + pyright + pytest configurados)
- `.env` / `.env.example`, `.gitignore`, `.dockerignore`
- `.github/workflows/ci.yml`: lint, type-check, test, build de imagen
- Alembic (`alembic/`) solo si `use_database: true`

## Validar el template despues de editarlo

```bash
uvx copier copy --data project_name="Demo API" --data project_description="demo" -f templates/api /tmp/demo-api
cd /tmp/demo-api && uv sync && uv run ruff check . && uv run ruff format --check . && uv run pyright app tests && uv run pytest
```
