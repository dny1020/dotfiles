# Global Engineering Guidelines

Stack, tooling and agent list live in `CLAUDE.md`. This file is the "how", not the "what".

## Philosophy

- Minimalism is the default everywhere: fewer decisions, less friction, less visual noise, less to maintain. When two options both work, ship the one with the smaller surface.
- Simple over clever; boring, predictable and stable over trendy.
- No over-engineering, no speculative abstraction. A solution needing more than two levels of abstraction: propose the simpler version first.
- Unix philosophy: small, composable modules that do one thing well. Composition over inheritance.
- Backend-first, CLI-first, API-first: build the contract before the UI.
- Declarative infrastructure over imperative scripts. Automate a manual process before documenting it.
- Every dependency is a liability — keep them minimal.
- Python unless another language has a clear, concrete advantage.
- A junior engineer should understand the code six months from now.

## Architecture

- Business logic separated from infrastructure; infra is replaceable, domain logic is testable.
- The API layer carries no business rules.
- Dependency injection only when it improves clarity. Avoid unnecessary abstractions.

## Code Quality

Intermediate level — production-ready, clean but pragmatic, understandable by a junior. Code must never look AI-generated: no filler comments, no gratuitous abstraction, no padding.

Avoid

- Enterprise patterns without necessity: factory for everything, generic repositories, excessive interfaces, magic metaclasses.
- Clever one-liners.
- Classes unless complex state truly requires one: prefer plain functions, `dict` and `list`. No registries, managers or design patterns for simple tasks.
- `async` / `await` / `asyncio` unless strictly necessary (WebSockets, massive parallel HTTP). Synchronous, blocking code is the default.
- Single-call helper functions — inline the logic instead.
- Regular expressions unless they're clearly the best fit — prefer plain string operations.
- `from __future__ import annotations`.
- Comments that restate what the code already says.
- Type hints beyond basic ones in function signatures (`def fn(a: str) -> str:`) for readability and autocomplete. No complex or library-internal types (`Union`, `Literal`, advanced generics, `ChatCompletionMessageParam`). Flexibility over satisfying a static checker.
- Exception handling for scenarios that can't happen (every external call still needs it — see Mandatory Baseline).

Prefer

- Explicit code; small functions, small classes, good names.
- Direct, short, readable code — the style of a senior Unix engineer.
- Docstrings only for public APIs or genuinely complex logic.
- Logging where useful.

## Mandatory Baseline

Scope: this applies to a **project** — an app, API, ETL job, or scheduled worker meant to run somewhere on its own. A one-off script, a debug session, or a throwaway investigation only owes the first two points (exception handling on external calls, configurable logging); it does not need Docker/CI/deploy scaffolding unless it's headed for production.

Every project ships with:

- **Exception handling** on every external call (DB, HTTP, filesystem, queue). No bare `except:`.
- **Logging** with a log level configurable via config file or env var — never hardcoded.
- **Local log files**: logs written to a local file; in Docker, the log directory is mounted as a local volume so logs survive container restarts.
- **Tests** (pytest for Python) covering the happy path and the main failure modes.
- **Docker**: the default packaging is a Docker container.
- **Automated deployment**, provisioned per the Infrastructure section below (Ansible + Compose for homelab/RPi, Terraform for AWS), CI/CD via GitHub Actions — no manual production deploys.

## Testing

### Python check gate

Any Python change is only done once this passes, in this order:

```bash
uv run ruff check . && uv run ruff format --check . && uv run pytest
```

- Run it yourself before reporting work as finished — don't hand back a change for the user to validate.
- `ruff` covers both lint and format; `--check` never rewrites files, so fix what it reports with `uv run ruff format .`.
- No type checker (pyright/mypy) in any project.
- Same three commands in CI, same order — the local gate and the pipeline never diverge.

### React check gate

Any React/TypeScript change is only done once this passes, in this order:

```bash
npm run lint && npm run format:check && npm run build
```

- Ship it as a `check` script in `package.json` so the gate is one command, not three to remember.
- `build` runs `tsc -b` first, so it type-checks; a separate `typecheck` step is for CI, not for you.
- `format:check` is `prettier --check .` and never rewrites — fix what it reports with `npm run format`.
- Tests are their own step (`npm run test`, vitest) — outside this gate, but CI runs them and so should you when the change touches tested behavior.
- A project without a `format:check` script gets prettier added rather than the gate quietly reduced.

Prefer unit and integration tests that exercise real behavior: `tmp_path`, real local resources. No heavy `unittest.mock` / `@patch`: if a test needs several mocked layers, simplify the function instead.

## Infrastructure

Infrastructure as Code only. Everything reproducible. No manual production changes.

Two valid deployment paths — pick based on the target, not habit:

- **Self-hosted (default for homelab/RPi)**: Ansible + Docker Compose. Idempotent playbooks, ARM-aware images, secrets via `ansible-vault`. See the `iac-expert` agent for conventions.
- **Cloud (AWS)**: Terraform first. Modular, remote state, least-privilege IAM.

## Documentation

- Every public API has documentation.
- Every complex decision explains WHY.
- README stays updated.
- Code, comments, docstrings, commit messages and READMEs are always in English — regardless of the conversation language. (Academic/UNIR docs are the exception, handled separately in Spanish.)

## Project Setup

Every project repository has, at minimum:

- **`CLAUDE.md`** — project-specific facts only: build/run/test commands, architecture, naming conventions, gotchas. Global rules already load every session — don't repeat them here. It is a **local, gitignored** file, never committed: add it to `.gitignore` and `.dockerignore` when setting up the repo.
- **`SPEC.md`** — the design/spec doc: problem statement, chosen approach, key decisions and why. Write it before large changes; update it when the approach changes.

Agents and skills are global (`~/.claude/agents/`, `~/.claude/skills/`) and apply to every project. Don't redefine or duplicate them per repo — only add a project-local one for something genuinely specific to that codebase.
