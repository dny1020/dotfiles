# Claude Global Context

## About Me
- **Platform**: WSL2 Debian on Windows
- **Roles**: VoIP/Telephony engineer · AI/voicebot engineer · Backend developer · DevOps/SRE
- **Primary languages**: Python · Go and JS/TS for smaller pieces · Bash for scripting
- **Preferred response language**: Spanish or English (both fine)

## Environment
- Shell: zsh, WSL2 — all paths are Linux (`/home/jnarvaar/...`)
- Python: `uv` only — `uv add` / `uv run` / `uv sync`, `uv.lock` committed, never `pip install` or `poetry`
- Containers: Docker / Podman · System packages: `apt`
- Editors: Neovim (primary, terminal-first) and VSCode over Remote-WSL; both use a local llama.cpp copilot. Don't assume a GUI IDE is available for a given task.

## Domain Stack
| Area | Tools |
|---|---|
| Telephony (primary) | Kamailio SBC, Asterisk PBX (PJSIP), SIP, RTP, rtpengine, sngrep, coturn |
| RTC | WebRTC, LiveKit (SFU), ICE/STUN/TURN |
| Contact center | Genesys Cloud (Platform API, BYOC), analytics, bulk extraction |
| Backend | FastAPI, PostgreSQL, Redis, SQLAlchemy (async), Alembic, Pydantic |
| AI/ML | Voicebot/chatbot agents: LangChain, LangGraph, MCP, Langfuse (tracing); local LLM via llama.cpp (OpenAI-compatible API); NetworkX, pgvector, spaCy, sentence-transformers |
| IaC | Ansible (idempotent roles), Terraform |
| CI/CD | GitHub Actions, Gitea Actions |
| Infra | Linux, systemd, nginx, Docker, WireGuard, Certbot, homelab RPi |
| Frontend | React + TypeScript, Tailwind — minimal, only when needed |

## How I Like to Work
- **Concise** — no padding, no trailing summaries of what you just did
- **Exact** — show `file:line` when pointing at code; give commands with flags, not directions
- **No unnecessary comments** in code — only when the WHY is non-obvious
- **Don't refactor beyond the task** — fix what's asked, nothing more
- **VoIP debug order**: signaling → SDP → RTP → NAT → firewall → media path → codec

## Use These Agents
- `voip` — SIP, Kamailio, Asterisk, Genesys, LiveKit/WebRTC, ICE/STUN/TURN, media-plane
- `iac-expert` — Ansible, Terraform, Docker, homelab/RPi provisioning
- `ai` — LLM pipelines, RAG, prompt engineering
- `graph-ml` — knowledge graphs, NLP, embeddings (pgvector)
- `architect` — system design, trade-off review, complexity control

Backend work runs through the `build-backend` skill, not an agent.

## Engineering Guidelines
@AGENTS.md
