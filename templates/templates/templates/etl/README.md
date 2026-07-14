# Template: etl

Genera un pipeline ETL (extract -> transform -> load) listo para produccion con cambios minimos, siguiendo la arquitectura fija definida en `SPEC.md` (raiz del repo).

## Uso

```bash
../../new.sh etl ./mi-etl
# o equivalente:
uvx copier copy --trust templates/etl ./mi-etl
```

## Preguntas

| Variable | Que controla |
|---|---|
| `project_name` / `project_slug` / `project_description` / `author_name` | Metadatos del proyecto |
| `source_url` | URL de origen (CSV) que usa `app/extract.py` por defecto |
| `destination` | `duckdb` (archivo local, sin infra) o `postgresql` (servicio Docker, via SQLAlchemy) |
| `use_fuzzy_dedup` | Agrega deduplicacion aproximada con RapidFuzz (`fuzzy_deduplicate`) ademas del `drop_duplicates()` exacto de pandas — util para nombres/texto libre con variaciones menores |
| `python_version` | Version usada en `pyproject.toml`, Dockerfile y CI |

## Lo que genera

- `app/` plano: `main.py` (orquesta el pipeline), `config.py`, `extract.py` (HTTPX + pandas), `transform.py`, `load.py` + `database.py` (destino elegido), `utils.py` (decorador de timing)
- `data/`: carpeta para archivos locales (ej. el `.duckdb` generado), vacia en git salvo `.gitkeep`
- `tests/`: `transform.py` se prueba con datos en memoria; `load.py` se prueba contra un motor real (DuckDB en memoria o SQLite via SQLAlchemy), sin necesitar infraestructura externa
- `Dockerfile` + `docker-compose.yml` (incluye servicio `db` solo si `destination: postgresql`)
- `pyproject.toml` gestionado con `uv` (ruff (lint+format) + pyright + pytest configurados)
- `.github/workflows/ci.yml`: lint, type-check, test, build de imagen

Es un job de un solo disparo (`uv run python -m app.main`), no un scheduler — para automatizar corridas periodicas usa el template `robot` o un cron/GitHub Action que invoque este mismo comando.

## Validar el template despues de editarlo

```bash
uvx copier copy --trust --data project_name="Demo ETL" --data project_description="demo" -f templates/etl /tmp/demo-etl
cd /tmp/demo-etl && uv sync && uv run ruff check . && uv run ruff format --check . && uv run pyright app tests && uv run pytest
```
