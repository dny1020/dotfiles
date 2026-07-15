---
name: build-agentic-agent
description: "Builds or reviews a LangGraph tool-calling agent (the `templates/agentic`/`chatbot`/`voicebot` pattern). Invoked when: adding or changing an agent tool, editing the LangGraph graph, wiring MCP exposure, or adding RAG search as a tool. Covers: plain-function tools shared with MCP, stateless-by-default agents injected via `Depends`, prompt-as-artifact, and offline/stub testing."
---

<skill>
Build or review the agentic feature and apply the following checklist. Fix every issue found and explain each change in one line.

## Style
- No AI-looking code: no filler comments, no single-call helpers, no premature Factory/Manager/Repository/Service abstraction.
- Type hints and docstrings only where they aid comprehension — not on every line.

## Graph and tools
- Tools are plain functions in `tools.py`, not classes or a tool-registry abstraction — LangGraph and MCP both call the same function.
- The graph (`ai.py`) wires nodes and routes state; it doesn't contain business logic — that belongs in `tools.py`/`services.py`.
- Prompts live in `prompts.py`, not as inline strings inside the graph — easier to diff and version.
- No persisted conversation history unless the task explicitly asks for it — the agent is stateless by default.

## MCP (when `use_mcp`)
- Every tool exposed to the LangGraph agent is exposed identically via `mcp_server.py` — no divergent second implementation.
- MCP tool descriptions are accurate enough for a client to call them without reading the source.

## RAG (when `use_rag`)
- Retrieval lives in `embeddings.py`/`vectorstore.py`; ingestion is re-runnable via `python -m app.ingest` — never hand-edit the vector store or its persisted index.
- `search_knowledge` is exposed as an ordinary tool, not a special-cased code path in the graph.

## Testing
- The agent is injected via `Depends(get_agent)`; tests override it with a stub (`app.dependency_overrides`) — no live Ollama call, no network, in the test suite.
- If a dependency override needs to hold state across requests (e.g. fake memory), build the instance once and close over it — a fresh instance per call silently breaks anything that expects continuity.

## Output format
For each issue found:
```
[ISSUE] <file>:<line or section> — <description>
[FIX]   <what was changed and why>
```
Then show the corrected code.
</skill>
