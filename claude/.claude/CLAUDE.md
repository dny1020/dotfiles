# Claude Global Context

## About Me
- **Platform**: WSL2 Debian on Windows
- **Roles**: VoIP/Telephony engineer · AI/voicebot engineer · Backend developer · DevOps/SRE
- **Primary languages**: Python · Go and JS/TS for smaller pieces · Bash for scripting
- **Response language**: reply in the language I write in

## Environment
- Shell: zsh, WSL2 — all paths are Linux (`~/...`)
- Containers: Docker / Podman · System packages: `apt`
- Editors: Neovim (primary) and VSCode over Remote-WSL; don't assume a GUI IDE is available.

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
- **Concise** — no padding.
- **Exact** — `file:line` when pointing at code; commands with flags, not directions.
- **VoIP debug order**: signaling → SDP → RTP → NAT → firewall → media path → codec

## Agents
- `voip` — SIP, Kamailio, Asterisk, Genesys, LiveKit/WebRTC, ICE/STUN/TURN, media-plane
- `iac-expert` — Ansible, Docker Compose, homelab/RPi provisioning (AWS/Terraform → `terraform-deploy` skill)
- `ai` — LLM pipelines, RAG, prompt engineering
- `graph-ml` — knowledge graphs, NLP, embeddings (pgvector)
- `architect` — system design, trade-off review, complexity control

Backend work runs through the `build-backend` skill, not an agent.

## Memory (doction MCP)
doction is my wiki and shared memory with my agents. Workspaces: `personal` (homelab, dotfiles, projects), `work`, `bussisnes`, `agente` (my RPi agent's memory, read-only for you).
- Before answering about my homelab, a project or a past decision, run `search_knowledge` in the matching workspace (prefer it over `search_pages`, which is keyword-only) and read with `get_rag_context` or `read_page_raw`.
- When the question is about one specific project, service or page, also run `get_linked_knowledge` on its page: the wikilinks lead to the runbooks, decisions and incidents that a text search misses.
- After a non-obvious fix or decision, offer to record it with `upsert_page_section` in the page it belongs to; write only once I say yes. After writing, run `suggest_links` and add the `[[links]]` that fit.
- Never write secrets, tokens or IPs of private services to doction.

## Engineering Guidelines
@AGENTS.md
