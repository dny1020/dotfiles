---
name: build-robot
description: "Scheduled background workers (the `templates/robot` pattern: APScheduler + retry-wrapped checks + alerts + run history). Invoked when: adding or changing a scheduled job, a check in `services.py`, an alert path, or anomaly detection."
---

<skill>
Build or review the scheduled-worker feature against this checklist. Fix every issue found and explain each change in one line.

Stack: **APScheduler** (`BlockingScheduler`) + **SQLAlchemy/SQLite** + **HTTPX**, managed with **`uv`**; anomaly detection (`scikit-learn` `IsolationForest`) is opt-in.

## Scheduler and jobs
- No `routes.py`, no FastAPI — this is a background worker, not a web service. Don't add an HTTP surface for consistency with other templates.
- Every job follows `jobs.py`'s flow: run the check → persist the result (`JobRun`) → alert on failure. No orchestration logic duplicated elsewhere.
- Interval and target (URL, threshold, etc.) come from `config.py` (pydantic-settings) — never hardcoded in `scheduler.py`/`jobs.py`.

## Checks and retries
- The check itself (`services.py`) and any outbound call (alert webhook) go through the `@retry` decorator in `utils.py` — a transient failure must not crash the scheduler process.
- A new check is a new function in `services.py` called from `jobs.py`, not a new scheduler instance or a parallel orchestration path.
- Prefer the simplest check that meets the task — no anomaly detection or extra scheduler jobs until the plain pass/fail check has been shown to fall short.

## Alerts
- `alert_webhook_url` empty means log-only — `alerts.py` must handle that case without raising.
- Alert payloads don't leak secrets (API keys, tokens) into the message body or logs.

## Anomaly detection (when `use_ml_check`)
- `IsolationForest` trains on the real accumulated `response_time_ms` history in `JobRun` — never on synthetic/placeholder data.
- Detection only activates once there's enough history (the template's bar: ≥10 runs) — don't flag anomalies off a handful of points.

## Testing
- Each module is tested in isolation with `monkeypatch` — no real network calls, and no test that actually blocks on the scheduler's interval.

Flag anything that changes the check interval, alert behavior, or what gets persisted to `JobRun` — those affect a process already running in production.
</skill>
