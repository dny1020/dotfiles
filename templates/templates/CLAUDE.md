# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repo holds a collection of [Copier](https://copier.readthedocs.io/) templates so new AI/automation projects (API, ETL, agentic, chatbot, voicebot, robot, frontend) can be scaffolded consistently instead of rebuilt from scratch or designed ad hoc by an LLM. `SPEC.md` is the authoritative design document — read it in full before touching any template; this file only summarizes the parts that constrain how Claude should act, plus the copier conventions established while building the first template.

## The LLM's role here (from SPEC.md "Rol del LLM")

- The LLM does **not** design the architecture, decide the file structure, or invent new templates ad hoc.
- The template defines the architecture — Claude's job is to implement features *within* a generated project, or to build/extend a template in this repo strictly following the conventions below (which is itself a legitimate, requested task, not "inventing architecture" per project).
- If a request implies deviating from the structure below (extra folders, new abstractions, a different base stack), point this out rather than silently doing it.

## Repo layout

One directory per template under `templates/`, each an independent Copier template:

```
templates/
  api/
    copier.yml       # questions, validators, _tasks
    README.md        # meta-doc: what this template generates, how to use it (NOT copied into generated projects)
    template/        # _subdirectory — actual project skeleton, this is what gets rendered
```

All 8 templates are built and validated: `api`, `agentic`, `etl`, `webservice`, `chatbot`, `voicebot`, `robot`, `frontend`. Use them as reference implementations for anything new.

**Decisions (superseding earlier ones — the user gave concrete per-template file structures, which is their call to make, not the LLM's):**
- **`webservice` IS a separate template from `api`**, not `api` with `use_database: false`. Earlier we'd decided a lightweight webservice = api-without-a-database; the user's own sketch made `webservice` distinct on purpose: it has `clients.py` for consuming external APIs and no `database.py`/`models.py` at all — a different shape, not a toggle of `api`. `api` owns its data (CRUD); `webservice` proxies/integrates someone else's.
- `chatbot` and `voicebot` reuse `agentic`'s LangGraph + llama.cpp + plain-function-tools pattern, but each renames the agent-builder module to fit its domain (`chatbot.py`, `speech.py`) rather than keeping `ai.py` — follow the user's exact file list per template instead of forcing identical filenames everywhere.
- `robot` has no FastAPI/routes at all — it's a background worker (`BlockingScheduler`), not a web service. Don't add HTTP to it just for consistency with the others.
- `tests/` is added to every template even where the user's sketch omitted it (`etl`, `robot`), per the global mandatory baseline ("Tests... no exceptions"). This was called out rather than silently changed.
- Go is out of scope for now (user's call, revisit later if needed).
- Default stack is Python backend + React frontend — **including for frontend-heavy projects**. `SPEC.md` mentions a NestJS-backend exception for frontend-dominant apps, but the user's explicit call was to keep using `api`/`webservice` (already built, already minimal) behind `templates/frontend` rather than build a NestJS template. Don't build a NestJS template unless asked again — this isn't a gap, it's a decision. `templates/frontend` doesn't bundle a backend; generate it as a sibling project next to whichever Python backend template fits (`api` if it owns data, `webservice` if it's a thin proxy/BFF, `agentic`/`chatbot` if it's AI-backed), and point `api_base_url` at it.

## Shared `auth.py` / `utils.py` convention

`api`, `webservice`, `chatbot`, and `voicebot` all offer a `use_auth` toggle (default `false`) with an identical pattern — copy it verbatim into any new HTTP-facing template rather than reinventing:
- `app/utils.py::mask_secret(value, visible=4)` — masks all but the last N chars, for safe logging of secrets.
- `app/auth.py` (conditional file, no `.jinja` needed — see gotcha below): `require_api_key(x_api_key: str | None = Header(default=None))` raises `401` on missing/wrong key, logs the masked attempt via `structlog` + `mask_secret`.
- `routes.py` always splits into `public_router` (health check, no auth) and `router` (`APIRouter(dependencies=[Depends(require_api_key)])` when `use_auth`, plain otherwise) — `main.py` includes both and never changes based on the toggle.
- Tests: the `client` fixture sets `TestClient(app, headers={"X-API-Key": get_settings().api_key})` when `use_auth`, so individual test functions don't need per-request header plumbing; a separate unauthenticated `TestClient(app)` is used only for the one test that asserts `401`.

## Entrypoint: `new.sh`

Don't make people remember `--trust` or figure out relative paths to `templates/<name>` — that friction is exactly what pushed the user to reconsider copier in the first place. Use the wrapper instead:

```bash
./new.sh <template> <destino> [opciones extra de copier]
# ej: ./new.sh api ../mi-proyecto
# ej: ./new.sh agentic ../mi-agente --data use_mcp=false
```

It resolves `templates/<name>` relative to the script's own location (works from any cwd), validates the template exists, and always passes `--trust`. Keep it a thin wrapper — no reimplementation of copier's logic in bash. If you add a template, no change to `new.sh` is needed; it discovers templates by directory listing.

## Copier conventions used (apply these to every new template)

- `_subdirectory: template` in `copier.yml` so the template's own `README.md` (meta-doc about the template) doesn't collide with the generated project's `README.md.jinja`.
- Files whose **content** needs `{{ }}` / `{% %}` must end in `.jinja` (stripped on render). Files with static content don't need the suffix, even if their path is conditional.
- Conditional inclusion is done via the **filename itself**, e.g. a file literally named `{% if use_database %}database.py{% endif %}` — copier skips it entirely when the expression renders empty. Works for directories too (e.g. `{% if use_database %}alembic{% endif %}/`).
- `.env` is generated from `.env.example` via a copier `_tasks` entry (`cp .env.example .env`), not by templating both files identically.
- Any template using `_tasks` requires `--trust` when running `copier copy`/`update` (copier treats `_tasks` as a "potentially unsafe" feature).
- Application (non-library) projects: set `[tool.uv] package = false` in `pyproject.toml` and drop `[build-system]` entirely — otherwise `uv sync` fails trying to get hatchling to figure out wheel contents when `project_slug` (hyphenated) doesn't match the `app/` directory name.
- FastAPI's `Depends(...)` in argument defaults trips ruff's `B008`; add `ignore = ["B008"]` under `[tool.ruff.lint]` rather than fighting the idiom.
- SQLAlchemy models returned from routes should keep their real ORM type as the function return annotation (e.g. `-> Item`), with `response_model=ItemRead` doing the serialization — annotating the return type as the Pydantic schema itself fails static type checking (pyright/mypy alike), since the ORM object doesn't structurally satisfy it.
- Tests against an in-memory SQLite engine **must** use `poolclass=StaticPool` (plus `connect_args={"check_same_thread": False}`) — otherwise FastAPI's `TestClient` runs the app in a worker thread that gets its own empty in-memory database and every query 404s/500s with "no such table".
- **Never combine a conditional filename with a `.jinja` content-suffix in one file**, e.g. `{% if x %}foo.py.jinja{% endif %}`. Copier decides "is this file a template?" by checking whether the *raw, pre-render* filename literally ends in `.jinja` — and `{% if x %}foo.py.jinja{% endif %}` ends in `{% endif %}`, not `.jinja`, so it silently copies the file verbatim (unrendered `{{ vars }}` and all) while still keeping the literal `.jinja` in the output name. If a conditionally-included file needs templated content, remove the need for `{{ }}` in its body instead (e.g. read values from `get_settings()` at runtime rather than baking them in at generation time) so the file can stay suffix-free, matching the working `database.py`/`models.py` pattern.
- Agent/LLM dependencies (`get_agent`, or any live-model call) should be injected via FastAPI `Depends(...)` exactly like `get_db`, so tests can override them with an in-memory stub (`app.dependency_overrides[...]`) and run fully offline — no live llama.cpp/network call required in CI. See `templates/agentic/template/tests/conftest.py`.
- **A dependency-override lambda must return the *same* instance across calls if the dependency is meant to hold state across requests** — `app.dependency_overrides[get_memory] = lambda: ConversationMemory()` looked right but silently broke `chatbot`'s history test, because FastAPI calls the override fresh on *every* request, so each of the two requests in the test got its own empty memory. Fix: build the instance once in the fixture (`memory = ConversationMemory()`) and have the lambda return that closure variable (`lambda: memory`), matching a real singleton dependency's behavior. Only stateless fakes (like `FakeAgent()`) are safe to re-instantiate per call.
- **Never let `uv run` be the container `CMD`.** `uv run <cmd>` re-resolves and syncs the environment against `pyproject.toml`'s *full* dependency set (dev-group included) every time it starts, regardless of `--no-dev` used at build time — confirmed by watching a "production" container re-download ruff/pyright/pytest from PyPI on every `docker run`. Fix used in every template's `Dockerfile.jinja`: `ENV PATH="/app/.venv/bin:$PATH"` right after `WORKDIR /app`, then `CMD` invokes the binary directly (`CMD ["uvicorn", ...]` or `CMD ["python", "-m", "app.main"]`) — no `uv` in the runtime path at all.
- **Type checker is `pyright`, not `mypy`** — this is the user's actual daily command (`uv run ruff check . && uv run ruff format --check . && uv run pyright app tests && uv run pytest`), not an assumption. Don't set `typeCheckingMode = "strict"` in `[tool.pyright]`: it flags `Unknown`-propagation from third-party stubs (httpx's `TestClient` in particular) that mypy strict never complained about, producing 16 spurious errors in `api`'s own test file on first try. Leave `typeCheckingMode` unset (pyright's default) and only set `include = ["app", "tests"]` + `pythonVersion`. `pyright` itself needs no system Node — the PyPI package pulls in `nodeenv` and manages its own isolated Node runtime.
- **`ruff format --check .` is part of the standard flow and templates must actually satisfy it**, not just `ruff check`. Hand-written `.jinja` source commonly violates it in two ways that only show up after rendering: (1) a `{% if %}` block placed between two top-level `def`/`class`s renders with only *one* blank line where ruff's formatter wants *two* — put two blank lines inside the conditional block, not one; (2) a static blank line placed *before* a conditional block that can render to nothing (e.g. both `use_database` and `use_auth` false) leaves a orphaned trailing blank line at EOF — move the blank line *inside* each branch instead of before the `{% if %}`. Caught both in `templates/api/template/app/routes.py.jinja` only when testing the combo where every toggle was off.
- `faster-whisper` (`WhisperModel(model_size, device="cpu", compute_type="int8")`, `.transcribe(io.BytesIO(...))` returns `(segments, info)`) and `piper-tts` (`PiperVoice.load(model_path)`, `.synthesize_wav(text, wave.Wave_write)` — not `.synthesize()`, which returns raw `AudioChunk`s instead) both install cleanly under Python 3.13 via `uv add`; verified their real APIs in a scratch project before writing `templates/voicebot` rather than guessing from memory.

## Local-AI/ML toggles (RAG, NLP, classical ML)

Added on request after an audit found that Alembic/SQLAlchemy/structlog/pydantic were already correctly scoped, but transformers/scikit-learn/sentence-transformers/spaCy/RapidFuzz weren't wired in anywhere — intentionally, since those are heavy/specific enough that baking them into every generated project would violate "every dependency is a liability". Each is an opt-in toggle on the one template where the user named a concrete use case:

- **`use_rag`** (`agentic`, `chatbot`): `sentence-transformers` (embeddings) + `chromadb` (embedded vector store, no separate server) exposed as an agent tool (`search_knowledge`). Adds `app/embeddings.py`, `app/vectorstore.py`, `app/ingest.py`, and a `data/knowledge/*.txt` seed folder. `uv run python -m app.ingest` loads docs; `data/chroma/` persists the index (gitignored, mounted as a volume in `docker-compose.yml`).
- **`use_nlp`** (`chatbot`): spaCy entity extraction (`extract_entities`, registered as an agent tool) + RapidFuzz (`fuzzy_match`, a plain utility for matching free text against a fixed list of choices — deliberately *not* an agent tool, since the agent has no natural way to supply a `choices` list).
- **`use_fuzzy_dedup`** (`etl`): RapidFuzz-based near-duplicate removal (`fuzzy_deduplicate`) layered on top of pandas' exact `drop_duplicates()`.
- **`use_ml_check`** (`robot`): `IsolationForest` (scikit-learn) trained on the *real* accumulated `response_time_ms` history in `JobRun` (not synthetic placeholder data) — flags an anomalous check, on top of the existing pass/fail check.

Gotchas hit building these (verify-first discipline paid off again — none of these were guessable from training data):

- **`sentence-transformers` silently pulls ~40 CUDA/`nvidia-*` packages and 4.8GB via `torch`, even on a CPU-only box** — completely wrong for this user's actual target (Raspberry Pi / ARM homelab). Fix, needed in every template that adds `sentence-transformers`: declare `torch` as an **explicit direct dependency** (not just transitive via sentence-transformers) *and* add `[tool.uv.sources]` + `[[tool.uv.index]]` pointing it at `https://download.pytorch.org/whl/cpu`. The source-override is silently ignored for purely-transitive dependencies — confirmed by testing both ways side by side. Result: `torch==X.Y.Z+cpu`, 0 nvidia packages, ~1.1GB instead of 4.8GB.
- **spaCy models should be pinned as a direct URL dependency**, not fetched via a separate `python -m spacy download` step: `"en-core-web-sm @ https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-3.8.0/en_core_web_sm-3.8.0-py3-none-any.whl"` in `dependencies`. This makes the model part of `uv sync`/`uv.lock` like anything else — no extra Dockerfile step, no drift between "what's declared" and "what's installed".
- **`df[bool_mask]` is untypeable in pandas' stubs** (`reportReturnType`: `Series | Unknown | DataFrame`) because bare `__getitem__` is inherently ambiguous between column-selection and row-filtering overloads. **Use `df.loc[bool_mask]` instead** — confirmed by testing both against pyright directly; `.loc`/`.iloc` have precise DataFrame-returning overloads that plain `[]` doesn't.
- **scikit-learn's bundled type stub types `IsolationForest(contamination=...)` as `str` only** (not `float | str` despite the real docs/runtime accepting a float) — pass `contamination="auto"` (also the better default: it's the paper's own formula rather than an arbitrary guessed rate) instead of fighting the stub with a float.
- **A zero-variance synthetic training set is degenerate for `IsolationForest`**: with every training point identical, `contamination="auto"` scores the training point itself as anomalous (`score_samples` exactly at the `-0.5` threshold), producing false positives even on in-distribution data. Any anomaly-detection test needs training data with realistic jitter, not repeated identical values — caught because a "detects outlier" test also flagged the *normal* value as anomalous.

## `templates/frontend`-specific notes (React/Vite/TS)

Before writing this template, `npm create vite@latest -- --template react-ts` was run for real in a scratch dir to see the *current* scaffold rather than assume — it's since moved to **Vite 8, React 19.2, TypeScript ~6.0, oxlint** (not ESLint) as the default linter. Don't "correct" the template back to ESLint/older versions from training-data memory; re-probe with `npm create vite@latest` if something looks outdated.

- `tsconfig.app.json`'s `erasableSyntaxOnly` (new-ish TS compiler option) forbids any TS syntax that needs codegen beyond type-stripping — notably **constructor parameter properties** (`constructor(message: string, public status: number)`). Write the field + plain constructor instead; caught this because `npm run build` failed with `TS1294` on first try.
- **No `use_auth` toggle needed for this template.** `src/lib/api-client.ts` reads `VITE_API_KEY` and conditionally sets the `X-API-Key` header only if it's set — the same file works whether or not the paired backend has `use_auth` on, so there's nothing for copier to branch on. Not every backend toggle needs a frontend mirror.
- **`VITE_*` env vars are baked into the JS bundle at `npm run build` time, not read at container runtime** — unlike the Python templates' `.env`. This means `.env` must NOT be excluded via `.dockerignore` here (it was, by copy-paste from the Python templates' `.dockerignore`, and that silently breaks `VITE_API_BASE_URL` in the built bundle — caught by grepping the built JS for the expected URL after `docker build`). Changing an env var for a new environment requires a rebuild, not just a container restart; the generated README says so explicitly.
- Tailwind v4 needs no `tailwind.config.js`/`postcss.config.js` — just the `@tailwindcss/vite` plugin in `vite.config.ts` and `@import "tailwindcss";` in `index.css`.
- nginx's `try_files $uri $uri/ /index.html;` is required for React Router client-side routes to survive a hard refresh/direct URL hit — verified by curling a non-root route (`/contacto`) against the built container and confirming `200`, not nginx's default `404`.
- **Prettier does the formatting, oxlint stays the linter** — they don't overlap and both are in the gate (`npm run check` = `lint && format:check && build`, the user's real daily command). `.prettierrc.json` mirrors the user's own projects: `semi: false`, `singleQuote: true`, `printWidth: 100`. Vite's scaffold is double-quoted, so adding prettier reformatted all of `src/` at once; that's expected, not a mistake to revert.
- **`prettier --check .` checks the *whole rendered project*, not just `src/`** — YAML, JSON and the compose file included. Two consequences: `docker-compose.yml`/`tsconfig.json` had to be prettier-formatted too, and `.github/workflows/ci.yml.jinja` (the one `.jinja` file prettier reaches) needs `node-version: '{{ node_version }}'` with **single** quotes, because prettier rewrites double-quoted YAML scalars to single and the *rendered* file is what CI checks. Caught by rendering and running `npm run check` — invisible when reading the template source.
- `react-router@8` requires Node `>=22.22`; the sandbox's Node 20 only warns (`EBADENGINE`) and still works for `npm install`/build/test, but `node_version` defaults to `"22"` in `copier.yml` for the Dockerfile/CI so generated projects don't hit this in a stricter environment.

## Validating a template after editing it

```bash
uvx copier copy --trust --data project_name="Demo" --data project_description="d" -f templates/<name> /tmp/demo
cd /tmp/demo && uv sync && uv run ruff check . && uv run ruff format --check . && uv run pyright app tests && uv run pytest
docker build -t demo:test .   # confirm the Dockerfile actually builds
```
For `templates/frontend`, swap the middle line for `npm install && npm run check && npm run typecheck && npm run test` (`check` is the user's own gate: `lint && format:check && build`). Re-run with the other meaningful `--data` combinations (every boolean/choice flag) before considering a template change done — `templates/api` was caught failing `uv sync`, mypy, ruff, and pytest on its first pass despite looking correct by inspection, and later `ruff format --check` + `pyright` (added after the fact to match the user's real daily command) caught more issues that `ruff check`/mypy alone had missed. `templates/frontend`'s `.dockerignore` silently broke the baked-in `VITE_API_BASE_URL` until the built JS was actually grepped for it.

## Structure convention inside a generated project

Flat `app/` directory, no multi-level packages unless there's a clear, demonstrated need. `main.py` (entrypoint, logging/structlog setup) and `config.py` (pydantic-settings) are in every template; everything past that is domain-specific per the table below — don't force identical filenames across templates that don't share a shape:

| Template | `app/` contents beyond `main.py`/`config.py` |
|---|---|
| `api` | `database.py`/`models.py` (opt-in), `schemas.py`, `services.py`, `routes.py`, `utils.py`, `auth.py` (opt-in) |
| `agentic` | `ai.py` (LangGraph agent), `prompts.py`, `tools.py`, `schemas.py`, `routes.py`, `mcp_server.py` (opt-in), `embeddings.py`/`vectorstore.py`/`ingest.py` (opt-in via `use_rag`) |
| `etl` | `extract.py`, `transform.py` (`@timed` dedup + opt-in `fuzzy_deduplicate` via `use_fuzzy_dedup`), `load.py`, `database.py`, `utils.py` |
| `webservice` | `clients.py` (external API client), `services.py`, `schemas.py`, `routes.py`, `utils.py`, `auth.py` (opt-in) |
| `chatbot` | `chatbot.py` (LangGraph agent), `prompts.py`, `tools.py`, `memory.py` (session history), `services.py`, `schemas.py`, `routes.py`, `auth.py` (opt-in), `embeddings.py`/`vectorstore.py`/`ingest.py` (opt-in via `use_rag`), `nlp.py` (opt-in via `use_nlp`) |
| `voicebot` | `speech.py` (agent + pipeline orchestration), `stt.py`, `tts.py`, `prompts.py`, `tools.py`, `schemas.py`, `routes.py`, `auth.py` (opt-in) |
| `robot` | `scheduler.py`, `jobs.py`, `services.py`, `alerts.py`, `database.py`, `models.py`, `utils.py` (`@retry` decorator), `anomaly.py` (opt-in via `use_ml_check`) — no `routes.py`, it's not a web service |

`frontend` is the one Node/TS template and doesn't follow the `app/` convention above — it uses Vite's own `src/` layout instead (`main.tsx`, `App.tsx`, `lib/` for the API client + query client, `pages/`, `components/`). Don't force the Python `app/` shape onto it.

Every generated project ships at minimum: `Dockerfile`, `docker-compose.yml`, `.env` + `.env.example`, `README.md`, `.gitignore`, tests, and a CI workflow — `pyproject.toml` + `app/` for the seven Python templates, `package.json` + `src/` for `frontend`.

## Base tooling for every template

- Python 3.13+, managed with `uv` (`uv init`, `uv sync`, `pyproject.toml`, `uv.lock` committed) — **never** `requirements.txt` or bare `pip install`.
- Docker + Docker Compose for packaging.
- Ruff (lint + format) + Pyright for types, Pytest for tests, Structlog for logging (level from env var, written to `logs/` which is Docker-volume-mounted).

## Template catalog and their stacks

| Template | Use cases | Key libraries | Status |
|---|---|---|---|
| API | REST backend, CRUD, owns its own DB | FastAPI, Pydantic, SQLAlchemy, Alembic (opt-in via `use_database`), Docker | **built** (`templates/api/`) |
| Agentic | AI agents, tool calling, MCP | FastAPI, LangGraph, `langchain-openai`, MCP SDK (opt-in via `use_mcp`) | **built** (`templates/agentic/`) |
| ETL | Data processing, automation | Pandas, HTTPX, DuckDB (default) or Postgres/SQLAlchemy (opt-in via `destination`) | **built** (`templates/etl/`) |
| Webservice | Consumes/integrates an external API, no ORM | FastAPI, HTTPX (`clients.py`), no SQLAlchemy | **built** (`templates/webservice/`) |
| Chatbot | WhatsApp/Telegram/Teams/WebChat | FastAPI, LangGraph, `langchain-openai`, in-memory session history | **built** (`templates/chatbot/`) |
| VoiceBot | IVR, telephony, voice AI | FastAPI, faster-whisper (STT), Piper (TTS), LangGraph/llama.cpp | **built** (`templates/voicebot/`) |
| Robot | Monitoring, scheduled automation | APScheduler, HTTPX, SQLAlchemy/SQLite | **built** (`templates/robot/`) |
| Frontend | SPA consuming any backend above | React 19, TypeScript, Vite 8, React Router, TanStack Query, React Hook Form + Zod, Tailwind v4, oxlint + Prettier, Vitest | **built** (`templates/frontend/`) |

The user's day-to-day favors a narrower "small but powerful" subset of the full SPEC.md library menu — when touching NLP/ML, prefer spaCy/RapidFuzz/scikit-learn over the long tail (Stanza, FlashText, River, etc.) unless asked. Go is deliberately out of scope for now. Prometheus/OpenTelemetry from SPEC.md's "Robot" stack weren't added to `templates/robot` — structlog + the `JobRun` SQLite history covered the actual need; add Prometheus only if the user asks for metrics scraping specifically.

## Non-negotiable simplicity rules (from SPEC.md)

- One responsibility per file/module.
- No empty folders, no more files than necessary, no classes where a function suffices.
- Avoid design patterns and abstractions that don't solve a real, current problem.
- Composition over inheritance.
- Code must be understandable by a junior developer in a few minutes.

## Intended lifecycle for a project generated from a template

```
./new.sh <name> ./my-project → uv sync → git init → develop with Codex/Claude → test → Docker → deploy
```

`SPEC.md` is written in Spanish; keep it that way when editing it. Code, comments, and docs inside `templates/*/template/` (i.e. what gets generated for end users) follow the global English-only convention from the user's `AGENTS.md`. Per-template meta `README.md` files in this repo (like `templates/api/README.md`) may be in Spanish since they're addressed to the repo's Spanish-speaking maintainer, not to a generated project's end user.
