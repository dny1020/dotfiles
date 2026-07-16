---
name: build-robot
description: "Builds or reviews a scheduled background worker (the `templates/robot` pattern: APScheduler + retry-wrapped checks + alerts + run history). Invoked when: adding or changing a scheduled job, a check in `services.py`, an alert path, or anomaly detection on top of the check history. Covers: retry/backoff on external calls, log-only-when-no-webhook alerting, real-data anomaly training, and scheduler-safe tests."
---

<skill>
Build or review the scheduled-worker feature and apply the following checklist. Fix every issue found and explain each change in one line.

## Style
- No AI-looking code: no filler comments, no single-call helpers, no premature Factory/Manager/Repository/Service abstraction.
- Type hints and docstrings only where they aid comprehension — not on every line.

## Scheduler and jobs
- No `routes.py`, no FastAPI — this is a background worker, not a web service.
- Every job follows `jobs.py`'s flow: run the check → persist the result → alert on failure. No orchestration logic duplicated elsewhere.
- Interval and target (URL, threshold, etc.) come from `config.py` (pydantic-settings) — never hardcoded in `scheduler.py`.

## Checks and retries
- The check itself (`services.py`) and any outbound call (alert webhook) go through the `@retry` decorator in `utils.py` — a transient failure must not crash the scheduler process.
- A new check is a new function in `services.py` called from `jobs.py`, not a new scheduler instance or a parallel orchestration path.

## Alerts
- `alert_webhook_url` empty means log-only — `alerts.py` must handle that case without raising.
- Alert payloads don't leak secrets (API keys, tokens) into the message body or logs.

## Anomaly detection (when `use_ml_check`)
- `IsolationForest` trains on the real accumulated `response_time_ms` history in `JobRun` — never on synthetic/placeholder data.
- Detection only activates once there's enough history (the template's bar: ≥10 runs) — don't flag anomalies off a handful of points.

## Testing
- Each module is tested in isolation with `monkeypatch` — no real network calls, and no test that actually blocks on the scheduler's interval.
- The change isn't done until `uv run ruff check . && uv run ruff format --check . && uv run pyright app tests && uv run pytest` passes — run it yourself. `pyright` is the type checker, not mypy.

## Output format
For each issue found:
```
[ISSUE] <file>:<line or section> — <description>
[FIX]   <what was changed and why>
```
Then show the corrected code.
</skill>
