# Template: agentic

Genera un agente de IA (FastAPI + LangGraph + llama.cpp OpenAI-compatible) listo para produccion con cambios minimos, siguiendo la arquitectura fija definida en `SPEC.md` (raiz del repo).

## Uso

```bash
../../new.sh agentic ./mi-agente
# o equivalente:
uvx copier copy --trust templates/agentic ./mi-agente
```

## Preguntas

| Variable | Que controla |
|---|---|
| `project_name` / `project_slug` / `project_description` / `author_name` | Metadatos del proyecto |
| `llama_model` | Modelo por defecto que usa `ChatOpenAI` contra llama.cpp (`LLAMA_MODEL` en `.env`) |
| `use_mcp` | Incluye `app/mcp_server.py`, que expone las mismas herramientas del agente via el SDK de MCP |
| `use_rag` | Agrega RAG local: `sentence-transformers` (embeddings) + Chroma (vector store embebido, sin servidor aparte), expuesto como una herramienta mas del agente (`search_knowledge`) |
| `python_version` | Version usada en `pyproject.toml`, Dockerfile y CI |

No hay toggle de base de datos: el agente es sin estado por defecto (sin historial persistido). Si mas adelante necesitas persistir conversaciones, es una necesidad clara y ahi se agrega `database.py`/`models.py` a mano.

## Lo que genera

- `app/` plano: `main.py`, `config.py`, `schemas.py`, `routes.py`, `ai.py` (arma el grafo de LangGraph), `prompts.py`, `tools.py` (funciones planas, reusadas por el agente y por MCP) + `embeddings.py`/`vectorstore.py`/`ingest.py` si `use_rag: true`
- `POST /chat` invoca el agente; el agente se inyecta como dependencia (`Depends(get_agent)`) igual que una sesion de DB, para poder reemplazarlo en los tests por un stub sin llamar a llama.cpp de verdad
- Con `use_rag: true`: `uv run python -m app.ingest` carga los `.txt` de `data/knowledge/` al vector store (Chroma persistido en `data/chroma/`, montado como volumen en Docker); el agente puede llamar a `search_knowledge` como cualquier otra herramienta
- `tests/` con pytest, usando un agente falso (sin red, sin llama.cpp); si `use_rag`, `embed`/`get_collection` tambien se reemplazan por stubs en los tests (sin descargar el modelo de embeddings)
- `docker-compose.yml` sin servicio de modelo: asume `llama-server` corriendo en el host
- `pyproject.toml` gestionado con `uv` (ruff (lint+format) + pyright + pytest configurados)
- `.github/workflows/ci.yml`: lint, type-check, test, build de imagen (no necesita llama.cpp corriendo porque los tests usan el stub)

## Validar el template despues de editarlo

```bash
uvx copier copy --trust --data project_name="Demo Agent" --data project_description="demo" -f templates/agentic /tmp/demo-agentic
cd /tmp/demo-agentic && uv sync && uv run ruff check . && uv run ruff format --check . && uv run pyright app tests && uv run pytest
```
