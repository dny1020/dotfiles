# Template: webservice

Genera un servicio FastAPI enfocado en **consumir/integrar APIs externas** (sin ORM propio), siguiendo la arquitectura fija definida en `SPEC.md` (raiz del repo).

Si en cambio necesitas duenio de tu propia base de datos (CRUD), usa `templates/api`.

## Uso

```bash
../../new.sh webservice ./mi-integracion
# o equivalente:
uvx copier copy --trust templates/webservice ./mi-integracion
```

## Preguntas

| Variable | Que controla |
|---|---|
| `project_name` / `project_slug` / `project_description` / `author_name` | Metadatos del proyecto |
| `upstream_base_url` | URL base de la API externa (`app/clients.py`, `.env`) |
| `use_auth` | Protege los endpoints de negocio con un API key simple (header `X-API-Key`) |
| `python_version` | Version usada en `pyproject.toml`, Dockerfile y CI |

## Lo que genera

- `app/` plano: `main.py`, `config.py`, `routes.py`, `clients.py` (cliente HTTPX hacia la API externa, inyectado via `Depends` igual que una sesion de DB), `services.py` (logica de negocio, convierte errores de red en `502`), `schemas.py`, `utils.py` (+ `auth.py` si `use_auth: true`)
- `tests/`: usa `httpx.MockTransport` para simular la API externa (sin red real), cubriendo el caso feliz y el caso de fallo (502)
- `Dockerfile` + `docker-compose.yml`
- `pyproject.toml` gestionado con `uv` (ruff (lint+format) + pyright + pytest configurados)
- `.github/workflows/ci.yml`: lint, type-check, test, build de imagen

## Validar el template despues de editarlo

```bash
uvx copier copy --trust --data project_name="Demo Webservice" --data project_description="demo" -f templates/webservice /tmp/demo-webservice
cd /tmp/demo-webservice && uv sync && uv run ruff check . && uv run ruff format --check . && uv run pyright app tests && uv run pytest
```
