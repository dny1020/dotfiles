# Template: robot

Genera un proceso de automatizacion/monitoreo programado (APScheduler), listo para produccion con cambios minimos, siguiendo la arquitectura fija definida en `SPEC.md` (raiz del repo).

No es un servicio HTTP: es un worker que corre en background dentro de su contenedor y ejecuta jobs en un intervalo fijo.

## Uso

```bash
../../new.sh robot ./mi-monitor
# o equivalente:
uvx copier copy --trust templates/robot ./mi-monitor
```

## Preguntas

| Variable | Que controla |
|---|---|
| `project_name` / `project_slug` / `project_description` / `author_name` | Metadatos del proyecto |
| `check_url` | URL que el job de ejemplo monitorea (`app/services.py`) |
| `interval_minutes` | Cada cuantos minutos corre el job |
| `alert_webhook_url` | Webhook para alertas (Slack/Discord/generico); vacio = solo se loguea |
| `use_ml_check` | Agrega `app/anomaly.py`: IsolationForest (scikit-learn) entrenado con el historial real de `response_time_ms` en `JobRun`, alerta si el tiempo de respuesta del check actual es anomalo |
| `python_version` | Version usada en `pyproject.toml`, Dockerfile y CI |

## Lo que genera

- `app/` plano: `main.py`, `config.py`, `scheduler.py` (arma el `BlockingScheduler` de APScheduler), `jobs.py` (orquesta un job: chequear -> guardar resultado -> alertar si falla), `services.py` (la logica que se monitorea, con reintentos via `utils.retry`), `alerts.py` (webhook), `database.py`/`models.py` (SQLite, historial de corridas en `JobRun`), `utils.py` (decorador `@retry`) + `anomaly.py` si `use_ml_check: true`
- Con `use_ml_check: true`: `perform_check()` tambien mide `response_time_ms`; una vez que hay al menos 10 corridas en el historial, `is_anomalous()` entrena un `IsolationForest` con esos datos reales y decide si la corrida actual es anomala
- `tests/`: cada modulo se prueba por separado con `monkeypatch` (sin red real, sin bloquear el scheduler)
- `Dockerfile` + `docker-compose.yml` (el contenedor corre `uv run python -m app.main` de forma indefinida)
- `pyproject.toml` gestionado con `uv` (ruff (lint+format) + pyright + pytest configurados)
- `.github/workflows/ci.yml`: lint, type-check, test, build de imagen

## Validar el template despues de editarlo

```bash
uvx copier copy --trust --data project_name="Demo Robot" --data project_description="demo" -f templates/robot /tmp/demo-robot
cd /tmp/demo-robot && uv sync && uv run ruff check . && uv run ruff format --check . && uv run pyright app tests && uv run pytest
```
