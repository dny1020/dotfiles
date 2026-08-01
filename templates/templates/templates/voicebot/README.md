# Template: voicebot

Genera un voicebot (FastAPI + faster-whisper + LangGraph/llama.cpp + Piper) listo para IVR/voice AI, siguiendo la arquitectura fija definida en `SPEC.md` (raiz del repo).

## Uso

```bash
../../new.sh voicebot ./mi-ivr
# o equivalente:
uvx copier copy --trust templates/voicebot ./mi-ivr
```

Antes de correrlo de verdad necesitas descargar un modelo de voz de [Piper](https://github.com/OHF-Voice/piper1-gpl/blob/main/docs/VOICES.md) (`.onnx` + `.onnx.json`) y colocarlo en `models/` (la ruta configurable via `PIPER_MODEL_PATH`). faster-whisper descarga su modelo solo la primera vez que se usa.

## Preguntas

| Variable | Que controla |
|---|---|
| `project_name` / `project_slug` / `project_description` / `author_name` | Metadatos del proyecto |
| `llama_model` | Modelo por defecto que usa `ChatOpenAI` (`LLAMA_MODEL` en `.env`) |
| `whisper_model` | Modelo de faster-whisper para STT (`tiny`, `base`, `small`, ...) |
| `piper_model_path` | Ruta al modelo `.onnx` de Piper para TTS |
| `use_auth` | Protege `/voice` con un API key simple (header `X-API-Key`) |
| `python_version` | Version usada en `pyproject.toml`, Dockerfile y CI |

## Lo que genera

- `app/` plano: `main.py`, `config.py`, `speech.py` (arma el agente LangGraph y orquesta el pipeline voz -> texto -> agente -> voz), `stt.py` (faster-whisper), `tts.py` (Piper), `prompts.py`, `tools.py`, `routes.py` (`POST /voice`, audio en/audio fuera), `utils.py`
- `POST /voice` recibe un archivo de audio y devuelve WAV con el `X-Transcript` en el header (util para depurar sin necesitar reproducir el audio)
- `tests/`: el pipeline completo se inyecta via `Depends(get_pipeline)` y se reemplaza por un stub en los tests — no requieren modelos de Whisper/Piper descargados
- `docker-compose.yml` con un servicio de modelo no incluido (usa llama.cpp en host) y un volumen `models/` para los pesos de Whisper/Piper
- `pyproject.toml` gestionado con `uv` (ruff (lint+format) + pyright + pytest configurados)

## Validar el template despues de editarlo

```bash
uvx copier copy --trust --data project_name="Demo Voicebot" --data project_description="demo" -f templates/voicebot /tmp/demo-voicebot
cd /tmp/demo-voicebot && uv sync && uv run ruff check . && uv run ruff format --check . && uv run pyright app tests && uv run pytest
```

Nota: los tests no ejercitan `stt.py`/`tts.py` con modelos reales (serian pesados de descargar en CI) — al integrar de verdad, prueba manualmente `POST /voice` con un audio real despues de descargar los modelos.
