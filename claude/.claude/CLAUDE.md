# Claude Global Context

## About Me
- **Platform**: WSL2 Debian on Windows
- **Roles**: VoIP/Telephony engineer · Backend developer · DevOps/SRE
- **Primary languages**: Python, Bash
- **Preferred response language**: Spanish or English (both fine)

## Environment
- Shell: zsh, WSL2 — all paths are Linux (`~/...`)
- Python tooling: `uv` for envs and packages
- Containers: Docker / Podman
- System packages: `apt`

## Domain Stack
| Area | Tools |
|---|---|
| Telephony (primary) | Kamailio SBC, Asterisk PBX, SIP, RTP, rtpengine, sngrep |
| Contact center | Genesys Cloud APIs, analytics, bulk extraction |
| Backend | FastAPI, PostgreSQL, SQLAlchemy (async), Alembic, Pydantic |
| IaC | Ansible (idempotent roles), Terraform |
| Infra | Linux, systemd, nginx, Docker, WireGuard, homelab RPi |
| Frontend | React minimal, Tailwind — only when needed |

## How I Like to Work
- **Concise** — no padding, no trailing summaries of what you just did
- **Exact** — show `file:line` when pointing at code; give commands with flags, not directions
- **No unnecessary comments** in code — only when the WHY is non-obvious
- **Don't refactor beyond the task** — fix what's asked, nothing more
- **VoIP debug order**: signaling → SDP → RTP → NAT → firewall → media path → codec

## Use These Agents
- `voip` — SIP, Kamailio, Asterisk, Genesys, LiveKit/SFU, ICE/STUN/TURN, media plane
- `iac-expert` — Ansible, Docker Compose, WireGuard, systemd, homelab/RPi provisioning
- `ai` — LLM pipelines, RAG, prompt engineering
- `graph-ml` — knowledge graphs, NLP, embeddings (pgvector)
- `architect` — system design, trade-off review, complexity control

Backend and frontend work go through skills, not agents: `build-backend`, `build-react-feature`.

## Engineering Guidelines
@AGENTS.md
