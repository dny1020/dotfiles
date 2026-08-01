# Template: chatbot

Genera un chatbot (FastAPI + LangGraph + llama.cpp OpenAI-compatible, con memoria de conversacion) listo para conectar a WhatsApp/Telegram/webchat, siguiendo la arquitectura fija definida en `SPEC.md` (raiz del repo).

Reusa el mismo patron de `templates/agentic` (agente LangGraph + llama.cpp, tools planas) y le agrega `memory.py` para recordar la conversacion por `session_id`.

## Uso

```bash
../../new.sh chatbot ./mi-bot
# o equivalente:
uvx copier copy --trust templates/chatbot ./mi-bot
```

## Preguntas

| Variable | Que controla |
|---|---|
| `project_name` / `project_slug` / `project_description` / `author_name` | Metadatos del proyecto |
| `llama_model` | Modelo por defecto que usa `ChatOpenAI` (`LLAMA_MODEL` en `.env`) |
| `use_auth` | Protege `/chat` con un API key simple (header `X-API-Key`) |
| `use_rag` | Agrega RAG local: `sentence-transformers` + Chroma, expuesto como herramienta del agente (`search_knowledge`) |
| `use_nlp` | Agrega `app/nlp.py`: extraccion de entidades (spaCy, expuesto como herramienta del agente) y fuzzy matching (RapidFuzz, funcion utilitaria para tu propio codigo, ej. matchear texto libre contra una lista fija de opciones) |
| `python_version` | Version usada en `pyproject.toml`, Dockerfile y CI |

## Lo que genera

- `app/` plano: `main.py`, `config.py`, `chatbot.py` (arma el agente de LangGraph), `prompts.py`, `tools.py`, `memory.py` (historial de conversacion en memoria por `session_id`), `services.py` (une memoria + agente), `routes.py` (`POST /chat`), `utils.py`
- `tests/`: agente y memoria se inyectan via `Depends`, reemplazados en los tests por stubs (sin llamar a llama.cpp real)
- `docker-compose.yml` con un servicio de modelo no incluido (usa llama.cpp en host)
- Para conectar un canal real (WhatsApp Business API, Telegram Bot API, webchat), agrega el webhook del proveedor en `routes.py` llamando a `services.handle_message` — no dupliques la logica del agente

## Validar el template despues de editarlo

```bash
uvx copier copy --trust --data project_name="Demo Bot" --data project_description="demo" -f templates/chatbot /tmp/demo-chatbot
cd /tmp/demo-chatbot && uv sync && uv run ruff check . && uv run ruff format --check . && uv run pyright app tests && uv run pytest
```
