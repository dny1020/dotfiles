---
name: build-agentic-agent
description: "LangGraph tool-calling agents (the `templates/agentic`/`chatbot`/`voicebot` pattern). Invoked when: adding or changing an agent tool, editing the graph, wiring MCP exposure, or adding RAG search as a tool."
---

<skill>
Build or review the agentic feature and apply the following checklist. Fix every issue found and explain each change in one line.

Stack: **FastAPI** + **LangGraph** + **llama.cpp** (OpenAI-compatible API), managed with **`uv`**; MCP exposure and local RAG (`sentence-transformers` + Chroma) are opt-in per project. Style rules live in AGENTS.md and already apply.

## Graph and tools
- Tools are plain functions in `tools.py`, not classes or a tool-registry abstraction — LangGraph and MCP both call the same function.
- The graph (`ai.py`) wires nodes and routes state; it doesn't contain business logic — that belongs in `tools.py`/`services.py`.
- Prompts live in `prompts.py`, not as inline strings inside the graph — easier to diff and version.
- No persisted conversation history unless the task explicitly asks for it — the agent is stateless by default, deliberately.
- `LLAMA_MODEL` comes from `config.py` (pydantic-settings) — never hardcode a model name in `ai.py`.
- Prefer the simplest graph that meets the task — no extra nodes or conditional edges until the plain-prompt version has been shown to fall short.

## MCP (when `use_mcp`)
- Every tool exposed to the LangGraph agent is exposed identically via `mcp_server.py` — no divergent second implementation.
- MCP tool descriptions are accurate enough for a client to call them without reading the source.

## RAG (when `use_rag`)
- Retrieval lives in `embeddings.py`/`vectorstore.py`; ingestion is re-runnable via `python -m app.ingest` — never hand-edit the vector store or its persisted index.
- `search_knowledge` is exposed as an ordinary tool, not a special-cased code path in the graph.

## Testing and checks
- The agent is injected via `Depends(get_agent)`; tests override it with a stub (`app.dependency_overrides`) — no live llama.cpp call, no network, in the test suite.
- If a dependency override needs to hold state across requests (e.g. fake memory), build the instance once and close over it — a fresh instance per call silently breaks anything that expects continuity.
- The change isn't done until the Python check gate in AGENTS.md passes — run it yourself.

## Output format
For each issue found:
```
[ISSUE] <file>:<line or section> — <description>
[FIX]   <what was changed and why>
```
Then show the corrected code, stating which file a new tool/node touches and whether it needs the MCP or RAG toggle. If the request needs a new toggle rather than code within the existing structure, say so — extending the template's shape is the human's decision, not something to route around silently.
</skill>
