# Claude Global Context

@AGENTS.md
@~/.claude/CLAUDE.local.md

# About Me

1. Roles: VoIP/Telephony, AI/Voicebot, Backend y DevOps/SRE.
2. Lenguajes: Python (principal); Go, JS/TS para componentes pequeños; Bash para scripting.
3. Responder en el idioma en que escribo.

# Environment

1. WSL2 Debian, zsh. Rutas siempre Linux (`~/...`).
2. Docker y Podman; paquetes con `apt`.
3. Neovim (principal), VSCode vía Remote-WSL. No asumir IDE gráfico.

# Domain Stack

1. Telephony: Kamailio SBC, Asterisk (PJSIP), SIP/RTP, rtpengine, sngrep, coturn.
2. RTC: WebRTC, LiveKit (SFU, SIP, Agents, Egress), ICE/STUN/TURN.
3. Contact Center: Genesys Cloud (Platform API, BYOC, Architect, analytics y extracción masiva).
4. Backend: FastAPI, PostgreSQL, Redis, SQLAlchemy async, Alembic, Pydantic.
5. AI/ML: LangChain, LangGraph, MCP, Langfuse, LiteLLM, llama.cpp (API OpenAI), NetworkX, pgvector, spaCy, sentence-transformers.
6. IaC y CI/CD: Ansible (roles idempotentes), Terraform, GitHub/Gitea Actions.
7. Infra: Linux, systemd, nginx, Docker, WireGuard, Certbot, AWS (ECS Fargate, Lambda, API Gateway), homelab RPi.
8. Frontend: React, TypeScript, Tailwind; solo cuando sea necesario y mínimo.

# Working Style

1. Conciso y directo: resultados, no narración ni relleno.
2. No describir comandos, herramientas ni archivos tocados; no repetir el contexto.
3. Explicar decisiones solo si son relevantes o se piden.
4. Reportar avances solo ante cambios importantes, bloqueos o decisiones del usuario.
5. Nunca ocultar errores, riesgos ni verificaciones fallidas; la brevedad no reduce la calidad.
6. Usar `file:line` y comandos ejecutables con flags exactos.

# VoIP Debugging

1. Orden: signaling → SDP → RTP → NAT → firewall → media path → codec.

# Memory (doction MCP)

1. doction es mi wiki y memoria compartida con mis agentes. Workspaces: `personal` (homelab, dotfiles, proyectos), `work`, `bussisnes`, `agente` (memoria de mi agente RPi, solo lectura).
2. Antes de responder sobre homelab, un proyecto o una decisión pasada: `search_knowledge` en el workspace correspondiente (preferir sobre `search_pages`, solo keywords); leer con `get_rag_context` o `read_page_raw`.
3. Si la pregunta es sobre un proyecto, servicio o página concreta: también `get_linked_knowledge` sobre su página; los wikilinks llevan a runbooks, decisiones e incidentes que la búsqueda de texto no encuentra.
4. Tras un fix o decisión no obvia, ofrecer registrarlo con `upsert_page_section` en su página; escribir solo si digo que sí. Después, `suggest_links` y añadir los `[[links]]` que encajen.
5. Nunca escribir secretos, tokens ni IPs de servicios privados en doction.

# Agents

1. `voip`: SIP, Kamailio, Asterisk, Genesys, LiveKit/WebRTC, ICE/STUN/TURN, media-plane.
2. `iac-expert`: Ansible, Docker Compose, homelab/RPi.
3. `ai`: LLM pipelines, RAG, prompt engineering.
4. `graph-ml`: knowledge graphs, NLP, embeddings, pgvector.
5. `architect`: diseño, trade-offs, control de complejidad.
6. Skills: AWS/Terraform → `terraform-deploy`; backend → `build-backend` (obligatorio, no agente).
