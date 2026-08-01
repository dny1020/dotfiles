---
name: graphify
description: "Use for any question about a codebase, its architecture, file relationships, or project content — especially when graphify-out/ exists, where the question should be treated as a graphify query first. Turns any input (code, docs, papers, images, videos) into a persistent knowledge graph with god nodes, community detection, and query/path/explain tools."
---

# /graphify

Turn any folder of files into a navigable knowledge graph with community detection, an honest audit trail, and three outputs: interactive HTML, GraphRAG-ready JSON, and a plain-language GRAPH_REPORT.md.

## Quick Reference

```
/graphify                                             # full pipeline on current directory
/graphify <path>                                      # full pipeline on specific path
/graphify https://github.com/<owner>/<repo>           # clone + full pipeline
/graphify <path> --update                             # incremental update
/graphify <path> --cluster-only                       # rerun clustering
/graphify <path> --no-viz                             # skip visualization
/graphify query "<question>"                          # BFS traversal
/graphify path "A" "B"                                # shortest path
/graphify explain "Node"                              # node explanation
```

## What graphify is for

Drop any folder of code, docs, papers, images, or video into graphify and get a queryable knowledge graph. Persistent across sessions, honest audit trail (EXTRACTED/INFERRED/AMBIGUOUS), community detection surfaces cross-document connections you wouldn't think to ask about.

## What You Must Do When Invoked

**Fast path — existing graph:** Before doing anything else, check whether `graphify-out/graph.json` exists. If it exists AND the user's request is a natural-language question (not a rebuild command): **skip Steps 1–5 entirely and jump straight to `## For /graphify query`.** Run `graphify query "<question>"` immediately.

If no path was given, use `.` (current directory). Do not ask the user for a path.

Follow these steps in order. Do not skip steps.

### Step 0 - GitHub repos (only if URL)

Only when the path is a `https://github.com/...` URL. See `references/github-and-merge.md` for the clone flow, then continue with the resolved local path.

### Step 1 - Ensure graphify is installed

```bash
PYTHON=""
GRAPHIFY_BIN=$(which graphify 2>/dev/null)
if [ -z "$PYTHON" ] && command -v uv >/dev/null 2>&1; then
    _UV_PY=$(uv tool run --from graphifyy python -c "import sys; print(sys.executable)" 2>/dev/null)
    if [ -n "$_UV_PY" ]; then PYTHON="$_UV_PY"; fi
fi
if [ -z "$PYTHON" ] && [ -n "$GRAPHIFY_BIN" ]; then
    _SHEBANG=$(head -1 "$GRAPHIFY_BIN" | tr -d '#!')
    case "$_SHEBANG" in *[!a-zA-Z0-9/_.@-]*) ;; *) "$_SHEBANG" -c "import graphify" 2>/dev/null && PYTHON="$_SHEBANG" ;; esac
fi
if [ -z "$PYTHON" ]; then PYTHON="python3"; fi
if ! "$PYTHON" -c "import graphify" 2>/dev/null; then
    if command -v uv >/dev/null 2>&1; then
        uv tool install --upgrade graphifyy -q 2>&1 | tail -3
        _UV_PY=$(uv tool run --from graphifyy python -c "import sys; print(sys.executable)" 2>/dev/null)
        if [ -n "$_UV_PY" ]; then PYTHON="$_UV_PY"; fi
    else
        "$PYTHON" -m pip install graphifyy -q 2>/dev/null || "$PYTHON" -m pip install graphifyy -q --break-system-packages 2>&1 | tail -3
    fi
fi
mkdir -p graphify-out
"$PYTHON" -c "import sys; open('graphify-out/.graphify_python', 'w', encoding='utf-8').write(sys.executable)"
echo "$(cd INPUT_PATH && pwd)" > graphify-out/.graphify_root
```

If the import succeeds, print nothing and move straight to Step 2.

**In every subsequent bash block, replace `python3` with `$(cat graphify-out/.graphify_python)` to use the correct interpreter.**

### Step 2 - Detect files

```bash
$(cat graphify-out/.graphify_python) -c "
import json
from graphify.detect import detect
from pathlib import Path
result = detect(Path('INPUT_PATH'))
print(json.dumps(result, ensure_ascii=False))
" > graphify-out/.graphify_detect.json
```

Replace INPUT_PATH with the actual path. Do NOT cat or print the JSON - read it silently and present a clean summary instead. If `total_files` is 0: stop. If `total_words` > 2,000,000 OR `total_files` > 500: show warning and ask which subfolder to run on.

### Step 2.5 - Video and audio (only if video files detected)

Skip this step entirely if `detect` returned zero `video` files. See `references/transcribe.md` for video transcription.

### Step 3 - Extract entities and relationships

**Part A - AST extraction** (code files, deterministic, free):
```bash
$(cat graphify-out/.graphify_python) -c "
import sys, json
from graphify.extract import collect_files, extract
from pathlib import Path
code_files = []
detect = json.loads(Path('graphify-out/.graphify_detect.json').read_text(encoding=\"utf-8\"))
for f in detect.get('files', {}).get('code', []):
    code_files.extend(collect_files(Path(f)) if Path(f).is_dir() else [Path(f)])
if code_files:
    result = extract(code_files, cache_root=Path('INPUT_PATH'))
    Path('graphify-out/.graphify_ast.json').write_text(json.dumps(result, indent=2, ensure_ascii=False), encoding=\"utf-8\")
    print(f'AST: {len(result[\"nodes\"])} nodes, {len(result[\"edges\"])} edges')
else:
    Path('graphify-out/.graphify_ast.json').write_text(json.dumps({'nodes':[],'edges':[],'input_tokens':0,'output_tokens':0}, ensure_ascii=False), encoding=\"utf-8\")
    print('No code files - skipping AST extraction')
"
```

**Part B - Semantic extraction** (docs/papers/images, LLM): See `references/extraction-spec.md` for subagent prompts and dispatch. Run Part A and Part B in parallel.

**Part C - Merge AST + semantic**: See `references/extraction-spec.md` for merge logic.

### Step 4 - Build graph, cluster, analyze

```bash
$(cat graphify-out/.graphify_python) -c "
import sys, json
from graphify.build import build_from_json
from graphify.cluster import cluster, score_all
from graphify.analyze import god_nodes, surprising_connections, suggest_questions
from graphify.report import generate
from graphify.export import to_json
from pathlib import Path

extraction = json.loads(Path('graphify-out/.graphify_extract.json').read_text(encoding=\"utf-8\"))
detection  = json.loads(Path('graphify-out/.graphify_detect.json').read_text(encoding=\"utf-8\"))

G = build_from_json(extraction, root='INPUT_PATH', directed=IS_DIRECTED)
if G.number_of_nodes() == 0:
    print('ERROR: Graph is empty - extraction produced no nodes.')
    raise SystemExit(1)
communities = cluster(G)
cohesion = score_all(G, communities)
tokens = {'input': extraction.get('input_tokens', 0), 'output': extraction.get('output_tokens', 0)}
gods = god_nodes(G)
surprises = surprising_connections(G, communities)
labels = {cid: 'Community ' + str(cid) for cid in communities}
questions = suggest_questions(G, communities, labels)

wrote = to_json(G, communities, 'graphify-out/graph.json')
if not wrote:
    print('ERROR: refused to shrink graphify-out/graph.json (#479).')
    raise SystemExit(1)
report = generate(G, communities, cohesion, labels, gods, surprises, detection, tokens, 'INPUT_PATH', suggested_questions=questions)
Path('graphify-out/GRAPH_REPORT.md').write_text(report, encoding=\"utf-8\")
analysis = {'communities': {str(k): v for k, v in communities.items()}, 'cohesion': {str(k): v for k, v in cohesion.items()}, 'gods': gods, 'surprises': surprises, 'questions': questions}
Path('graphify-out/.graphify_analysis.json').write_text(json.dumps(analysis, indent=2, ensure_ascii=False), encoding=\"utf-8\")
print(f'Graph: {G.number_of_nodes()} nodes, {G.number_of_edges()} edges, {len(communities)} communities')
"
```

Replace INPUT_PATH and IS_DIRECTED (True/False) as needed.

### Step 5 - Label communities

Read `graphify-out/.graphify_analysis.json`. For each community key, write a 2-5 word plain-language name. Then regenerate the report with labels. See `references/extraction-spec.md` for the label update code.

### Step 6 - Generate HTML

```bash
graphify export html
```

Obsidian vault only if `--obsidian` was explicitly given: `graphify export obsidian`

### Steps 6b-8 - Optional exports

Only run when their flag is present: `--wiki`, `--neo4j`, `--falkordb`, `--svg`, `--graphml`, `--mcp`. See `references/exports.md` for each.

### Step 9 - Save manifest, clean up

```bash
$(cat graphify-out/.graphify_python) -c "
import json
from pathlib import Path
from datetime import datetime, timezone
from graphify.detect import save_manifest

detect = json.loads(Path('graphify-out/.graphify_detect.json').read_text(encoding=\"utf-8\"))
save_manifest(detect.get('all_files') or detect['files'], root='INPUT_PATH')

extract = json.loads(Path('graphify-out/.graphify_extract.json').read_text(encoding=\"utf-8\"))
input_tok = extract.get('input_tokens', 0)
output_tok = extract.get('output_tokens', 0)

cost_path = Path('graphify-out/cost.json')
if cost_path.exists():
    cost = json.loads(cost_path.read_text(encoding=\"utf-8\"))
else:
    cost = {'runs': [], 'total_input_tokens': 0, 'total_output_tokens': 0}

cost['runs'].append({'date': datetime.now(timezone.utc).isoformat(), 'input_tokens': input_tok, 'output_tokens': output_tok, 'files': detect.get('total_files', 0)})
cost['total_input_tokens'] += input_tok
cost['total_output_tokens'] += output_tok
cost_path.write_text(json.dumps(cost, indent=2, ensure_ascii=False), encoding=\"utf-8\")
print(f'This run: {input_tok:,} input tokens, {output_tok:,} output tokens')
print(f'All time: {cost[\"total_input_tokens\"]:,} input, {cost[\"total_output_tokens\"]:,} output ({len(cost[\"runs\"])} runs)')
"
rm -f graphify-out/.graphify_detect.json graphify-out/.graphify_extract.json graphify-out/.graphify_ast.json graphify-out/.graphify_semantic.json graphify-out/.graphify_analysis.json
find graphify-out -maxdepth 1 -name '.graphify_chunk_*.json' -delete 2>/dev/null
rm -f graphify-out/.needs_update 2>/dev/null || true
```

Replace INPUT_PATH with the actual path.

Tell the user:
```
Graph complete. Outputs in PATH_TO_DIR/graphify-out/
  graph.html            - interactive graph
  GRAPH_REPORT.md       - audit report
  graph.json            - raw graph data
```

Then paste God Nodes, Surprising Connections, and Suggested Questions from GRAPH_REPORT.md. Pick the most interesting suggested question and ask: "The most interesting question this graph can answer: **[question]**. Want me to trace it?"

---

## Interpreter guard for subcommands

Before running any subcommand (`--update`, `--cluster-only`, `query`, `path`, `explain`, `add`), check that `.graphify_python` exists:

```bash
if [ ! -f graphify-out/.graphify_python ]; then
    GRAPHIFY_BIN=$(which graphify 2>/dev/null)
    if [ -n "$GRAPHIFY_BIN" ]; then
        PYTHON=$(head -1 "$GRAPHIFY_BIN" | tr -d '#!')
        case "$PYTHON" in *[!a-zA-Z0-9/_.@-]*) PYTHON="python3" ;; esac
    else
        PYTHON="python3"
    fi
    mkdir -p graphify-out
    "$PYTHON" -c "import sys; open('graphify-out/.graphify_python', 'w', encoding='utf-8').write(sys.executable)"
fi
```

## For --update and --cluster-only

See `references/update.md` for both flows.

## For /graphify query

When `graphify-out/graph.json` exists and user asks a question:

```bash
graphify query "<question>"
```

Before traversal, expand the question against the graph's vocabulary. See `references/query.md` for vocab-expansion, BFS/DFS modes, `--budget`, NetworkX fallback, and `/graphify path`/`/graphify explain` flows.

## For /graphify add and --watch

See `references/add-watch.md`.

## For commit hook and CLAUDE.md integration

See `references/hooks.md`.

---

## Honesty Rules

- Never invent an edge. If unsure, use AMBIGUOUS.
- Never skip the corpus check warning.
- Always show token cost in the report.
- Never hide cohesion scores behind symbols - show the raw number.
- Never run HTML viz on a graph with more than 5,000 nodes without warning the user.
