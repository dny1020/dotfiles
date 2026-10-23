---
name: etl-pipeline
description: "ETL/data pipelines. Invoked when: writing a data extraction, transformation, or load job, or reviewing one for production-readiness."
---

<skill>
Build or review the ETL pipeline against this checklist. Fix every issue found and explain each change in one line.

## Idempotency
- Re-running on the same input produces the same result — no duplicate rows after a partial failure.
- Upsert (`ON CONFLICT DO UPDATE` or equivalent) where records can recur.
- Resume from the last successful checkpoint instead of restarting, if a run is long enough to matter.

## Logging
- Each stage (extract, transform, load) logs record counts in and out, and every run ends with processed, failed and duration — silent data loss must show up in the logs.
- Failures log enough context (source, batch id, record identifier) to debug without re-running everything.
- No secrets or raw PII in logs.

## Retry
- Transient failures (network, rate limits, timeouts) retry with backoff, bounded by a max attempts; once exhausted, fail loudly.
- Non-transient failures (bad schema, malformed record) are not retried.

## Bad records
- A bad record doesn't crash the batch: log it with its identifier, set it aside, continue.
- Schema/type mismatches are checked explicitly at the boundary, not left to blow up deep in the transform.
</skill>
