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

## Engineering Guidelines
@AGENTS.md
