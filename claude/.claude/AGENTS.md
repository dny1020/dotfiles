# Global Engineering Guidelines

## Philosophy

- Prefer simplicity over cleverness.
- Avoid over-engineering.
- Deliver maintainable software.
- Optimize for readability before optimization.
- Keep implementations boring, predictable and stable.
- Follow the Unix philosophy: small, composable, do one thing well.
- Prefer composition over inheritance.
- Small reusable modules.
- Clear naming beats comments.
- Backend-first, CLI-first, API-first: build the contract before the UI.
- Prefer declarative infrastructure over imperative scripts.
- Automate a manual process before documenting it as a manual process.
- Prefer Python unless another language has a clear, concrete advantage.
- Keep dependencies to a minimum — every dependency is a liability.
- Prefer stable, boring technology over trends.
- Code should be understandable by a junior engineer six months from now.

---

# Architecture

- Keep business logic separated from infrastructure.
- API should not contain business rules.
- Domain logic must be testable.
- Infrastructure must be replaceable.
- Prefer dependency injection when it improves clarity.
- Avoid unnecessary abstractions.

---

# Code Quality

Target level:

- Intermediate — no over-engineering.
- Understandable by a junior coder.
- Production ready.
- Clean but pragmatic.
- Code should never look AI-generated: no filler comments, no gratuitous abstraction, no padding.

Avoid

- Enterprise patterns without necessity.
- Factory for everything.
- Generic repositories.
- Excessive interfaces.
- Magic metaclasses.
- Clever one-liners.
- Single-call helper functions — inline the logic instead.
- Regular expressions unless they're clearly the best fit — prefer plain string operations.
- `from __future__ import annotations`.
- Comments that restate what the code already says.
- Type hints beyond what improves comprehension — annotation is not a goal in itself.
- Exception handling for scenarios that can't happen (every external call still needs it — see Mandatory Baseline).
- Solutions that need more than two levels of abstraction — propose the simpler version first.

Prefer

- Explicit code.
- Small functions.
- Small classes.
- Good variable names.
- Direct, short, readable code — the style of a senior Unix engineer.
- Docstrings only for public APIs or genuinely complex logic.
- Logging where useful.

---

# Mandatory Baseline

Every app, API, ETL job, or script — no exceptions — ships with:

- **Exception handling** on every external call (DB, HTTP, filesystem, queue). No bare `except:`.
- **Logging** with a log level configurable via config file or env var — never hardcoded.
- **Local log files**: logs written to a local file; in Docker, the log directory is mounted as a local volume so logs survive container restarts.
- **Tests** (pytest for Python) covering the happy path and the main failure modes.
- **Docker**: the default packaging is a Docker container.
- **Automated deployment**: AWS and/or Raspberry Pi, provisioned with Terraform, CI/CD via GitHub Actions — no manual deploys.

---

# Security

Always assume production.

Never

- Hardcode secrets.
- Commit credentials.
- Disable SSL.
- Ignore authentication.
- Ignore authorization.
- Trust client input.
- Trust environment variables blindly.

Always

- Validate every input.
- Escape SQL properly.
- Use parameterized queries.
- Sanitize logs.
- Rotate secrets.
- Use least privilege.
- Encrypt sensitive data.
- Enable HTTPS.
- Validate JWT.
- Validate permissions.

---

# Performance

Optimize only after measuring.

Prefer

- PostgreSQL indexes
- Bulk operations
- Async IO when appropriate
- Pagination
- Streaming for large datasets

Avoid premature optimization.

---

# Testing

## Python check gate

Any Python change is only done once this passes, in this order:

```bash
uv run ruff check . && uv run ruff format --check . && uv run pyright app tests && uv run pytest
```

- Run it yourself before reporting work as finished — don't hand back a change for the user to validate.
- `ruff` covers both lint and format; `--check` never rewrites files, so fix what it reports with `uv run ruff format .`.
- `pyright` is the type checker, not mypy. Adjust the paths to the project's real layout when it isn't `app`/`tests`.
- Same four commands in CI, same order — the local gate and the pipeline never diverge.

## React check gate

Any React/TypeScript change is only done once this passes, in this order:

```bash
npm run lint && npm run format:check && npm run build
```

- Ship it as a `check` script in `package.json` so the gate is one command, not three to remember.
- `build` runs `tsc -b` first, so it type-checks; a separate `typecheck` step is for CI, not for you.
- `format:check` is `prettier --check .` and never rewrites — fix what it reports with `npm run format`.
- Tests are their own step (`npm run test`, vitest) — outside this gate, but CI runs them and so should you when the change touches tested behavior.
- A project without a `format:check` script gets prettier added rather than the gate quietly reduced.

Prefer

- Unit tests
- Integration tests

Avoid

- Overmocking
- Brittle tests

---

# Infrastructure

Infrastructure as Code only. Everything reproducible. No manual production changes.

Two valid deployment paths — pick based on the target, not habit:

- **Self-hosted (default for homelab/RPi)**: Ansible + Docker Compose. Idempotent playbooks, ARM-aware images, secrets via `ansible-vault`. See the `iac-expert` agent for conventions.
- **Cloud (AWS)**: Terraform first. Modular, remote state, least-privilege IAM.

---

# Documentation

Every public API must have documentation.

Every complex decision must explain WHY.

README must always stay updated.

Code, comments, docstrings, commit messages, and READMEs are always in English — regardless of what language the conversation happens in. (Academic/UNIR docs are the one exception and are handled separately, in Spanish.)

---

# Preferred Stack

Backend

- Python, managed with `uv` (`uv add`, `uv run`, `uv sync`, `uv.lock` committed) — never `pip install` or `poetry` in new projects.
- FastAPI
- PostgreSQL
- Redis

Frontend

- React
- TypeScript

Infrastructure

- Self-hosted: Raspberry Pi, Ansible, Docker Compose, WireGuard, Certbot, nginx
- Cloud: AWS, Terraform
- CI/CD: GitHub Actions, Gitea Actions

AI

- Local LLM
- Ollama
- ML
- ETL
- Knowledge graphs (NetworkX, pgvector), NLP (spaCy, sentence-transformers)

Telephony / RTC

- WebRTC, LiveKit (SFU)
- SIP: Asterisk (PJSIP), Kamailio
- Genesys Cloud (Platform API, BYOC)
- coturn (STUN/TURN)

General

- Linux
- SSH
- Editor: Neovim — terminal-first workflows; never assume a GUI IDE (no "open in VS Code", no GUI-only debugger steps)

---

# Project Setup

Every project repository has, at minimum:

- **`CLAUDE.md`** — project-specific facts only: build/run/test commands, architecture, naming conventions, gotchas. Global rules in this file already load automatically every session — don't repeat them here.
- **`SPEC.md`** — the design/spec doc for that project: problem statement, chosen approach, key decisions and why. Write it before large changes; update it when the approach changes.

Agents and skills are global (`~/.claude/agents/`, `~/.claude/skills/`) and apply to every project automatically. Don't redefine or duplicate them per repo — only add a project-local agent/skill for something genuinely specific to that codebase that doesn't belong globally.
