# AI Development Templates Specification

Version: 1.0

## Objetivo

Crear un conjunto de plantillas de desarrollo reutilizables para iniciar proyectos de forma rápida, consistente y mantenible, evitando comenzar desde cero o depender de un LLM para generar la arquitectura base.

Las plantillas deben representar la forma oficial de desarrollar proyectos dentro de mi flujo de trabajo.

El código generado debe ser simple, entendible por un desarrollador junior y evitar la sobreingeniería.

---

# Filosofía

## Simplicidad

- Backend First.
- API First.
- CLI First.
- Todo debe tener un propósito.
- Evitar abstracciones innecesarias.
- Evitar patrones de diseño si no resuelven un problema real.
- Preferir composición antes que herencia.
- Una responsabilidad por archivo.
- Una responsabilidad por módulo.

---

# Principios

- No crear capas innecesarias.
- No crear carpetas vacías.
- No crear más archivos de los necesarios.
- No crear clases cuando una función es suficiente.
- Evitar código "enterprise" para proyectos pequeños.
- Mantener la curva de aprendizaje baja.
- El proyecto debe poder entenderse en pocos minutos.

---

# Herramientas Base

Todos los proyectos utilizarán:

- Python 3.13+
- uv
- pyproject.toml
- Git
- Docker
- Docker Compose
- .env
- .env.example
- .gitignore
- README.md

Nunca usar requirements.txt.

---

# Librerías Base

## API

- FastAPI
- Uvicorn
- Pydantic
- SQLAlchemy (cuando exista base de datos)
- Alembic (solo si hay migraciones)
- HTTPX

---

## IA

- LangGraph
- LangChain (solo cuando sea necesario)
- MCP SDK
- Ollama
- Transformers
- Sentence Transformers
- PyTorch

---

## NLP

- spaCy
- RapidFuzz

---

## Machine Learning

- scikit-learn

---

## Búsqueda

- SQLite FTS5
- DuckDB (analytics o ETL)

---

## CLI

- Typer
- Rich

---

## Observabilidad

- Structlog
- Prometheus Client

---

## Testing

- Pytest

---

## Calidad

- Ruff
- MyPy

---

# Templates

## 1. API

Casos de uso

- REST API
- Backend
- CRUD
- Integraciones

Tecnologías

- FastAPI
- Pydantic
- SQLAlchemy
- Alembic
- Docker

---

## 2. ETL

Casos

- Procesamiento de datos
- Automatización
- Integraciones

Tecnologías

- DuckDB
- Pandas
- HTTPX

---

## 3. Agentic

Casos

- Agentes IA
- Tool Calling
- Automatización

Tecnologías

- LangGraph
- MCP
- Ollama
- FastAPI

---

## 4. Chatbot

Casos

- WhatsApp
- Telegram
- Teams
- WebChat

Tecnologías

- FastAPI
- LangGraph
- Ollama
- Redis (opcional)

---

## 5. VoiceBot

Casos

- IVR
- Telefonía
- Voice AI

Tecnologías

- FastAPI
- Whisper
- Piper
- LangGraph

---

## 6. Robot

Casos

- Monitoreo
- Automatización
- Procesos programados

Tecnologías

- APScheduler
- HTTPX
- Prometheus

---

## 7. Frontend

Cuando el proyecto tenga mayor peso en frontend que backend.

Tecnologías

- React
- TypeScript
- Vite
- React Router
- TanStack Query

Backend

- NestJS

En proyectos Full Stack donde el frontend sea predominante se recomienda utilizar TypeScript tanto para frontend como backend.

---

# Estructura

Toda la lógica de la aplicación vive dentro de:

```
app/
```

No crear múltiples niveles de carpetas.

Ejemplo:

```
app/
    main.py
    config.py
    database.py
    models.py
    schemas.py
    services.py
    routes.py
    auth.py
    ai.py
    prompts.py
    tools.py
    scheduler.py
```

Solo crear una nueva carpeta cuando exista una necesidad clara.

---

# Archivos Base

Todos los proyectos tendrán como mínimo:

```
app/
Dockerfile
docker-compose.yml
pyproject.toml
.env
.env.example
README.md
.gitignore
```

---

# Convenciones

Preferir:

- services.py
- routes.py
- models.py
- schemas.py
- config.py

Antes que crear múltiples subcarpetas.

---

# Automatización

Después de crear una plantilla el flujo será:

```
Crear proyecto
        │
        ▼
uv init
        │
        ▼
Copier
        │
        ▼
uv sync
        │
        ▼
git init
        │
        ▼
Desarrollo con Codex/Claude
        │
        ▼
Testing
        │
        ▼
Docker
        │
        ▼
Deploy
```

---

# Rol del LLM

El LLM NO genera la arquitectura.

El LLM NO decide la estructura de archivos.

El LLM NO crea la plantilla.

La plantilla define la arquitectura.

El LLM ayuda a implementar funcionalidades dentro de esa arquitectura.

---

# Objetivo Final

Contar con una colección de plantillas mantenidas y versionadas para iniciar proyectos de IA y automatización de forma consistente.

Las plantillas deben cubrir los casos de uso del puesto de Desarrollador de Soluciones de IA y Automatización:

- APIs
- ETL
- Chatbots
- Voicebots
- Agentes IA
- Robots de automatización
- Frontend React
- Backend FastAPI
- Backend NestJS cuando el proyecto sea mayoritariamente frontend

Cada plantilla debe ser:

- Simple.
- Consistente.
- Fácil de entender.
- Fácil de mantener.
- Lista para producción con cambios mínimos.
