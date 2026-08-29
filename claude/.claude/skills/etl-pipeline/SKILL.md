---
name: etl-pipeline
description: "ETL/data pipelines. Invoked when: writing a data extraction, transformation, or load job, or reviewing one for production-readiness."
---

<skill>
Build or review the ETL pipeline and apply the following checklist. Fix every issue found and explain each change in one line.

## Style
- No AI-looking code: no filler comments, no single-call helpers, no premature Factory/Manager/Repository/Service abstraction.
- Prefer plain string operations over regex unless regex is clearly the better fit.
- Type hints and docstrings only where they aid comprehension — not on every line. No `from __future__ import annotations`.

## Idempotency
- Re-running the pipeline on the same input produces the same result — no duplicate rows from a re-run after a partial failure.
- Upserts (`ON CONFLICT DO UPDATE` or equivalent) used instead of blind inserts where records can recur.
- Pipeline can resume from the last successful checkpoint rather than always restarting from scratch, if a run is long enough to matter.

## Logging
- Each stage (extract, transform, load) logs record counts in and out, so a silent data-loss bug shows up in the logs.
- Failures log enough context (source, batch id, offending record identifier) to debug without re-running the whole pipeline.
- No secrets (API keys, DB credentials) or raw PII logged.

## Retry
- Transient failures (network, rate limits, timeouts) are retried with backoff — not treated as fatal on the first attempt.
- Retries are bounded (max attempts) and the pipeline fails loudly, not silently, once exhausted.
- Non-transient failures (bad schema, malformed record) are not retried blindly — they're routed to a dead-letter path instead.

## Metrics
- Pipeline emits at least: records processed, records failed, duration, last successful run timestamp.
- Metrics are queryable/alertable, not just printed to a log no one watches.

## Error handling
- Bad records don't crash the whole batch — isolate and quarantine them, then continue.
- Schema/type mismatches are caught explicitly, not left to throw a generic exception deep in the transform step.

## Checks
- The pipeline isn't done until the Python check gate in AGENTS.md passes — run it yourself.
- In pandas transforms, filter rows with `df.loc[mask]` rather than `df[mask]` — bare `[]` is ambiguous in the stubs and pyright can't type its return.

## Output format
For each issue found:
```
[ISSUE] <file>:<line or section> — <description>
[FIX]   <what was changed and why>
```
Then show the corrected pipeline code.
</skill>
