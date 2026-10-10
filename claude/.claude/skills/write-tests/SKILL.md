---
name: write-tests
description: "Pytest tests for Python code. Invoked when: a feature or fix needs coverage, or an existing suite needs review."
---

<skill>
Write or review tests for the given code and apply the following checklist. Fix every issue found and explain each change in one line.

## Style
- No AI-looking code: no filler comments, no single-call helpers, no test-only abstraction layers a reader has to trace through.
- Type hints and docstrings only where they aid comprehension — not on every line.

## Structure
- Use `pytest`, not `unittest`-style classes, unless the codebase already standardizes on the latter.
- Run tests with `uv run pytest`, not a bare `pytest` or `python -m pytest` — keeps the venv/lockfile authoritative.
- Before calling the work done, run the Python check gate in AGENTS.md — new tests must be lint-clean and formatted, not just green.
- One behavior per test; test names describe the behavior (`test_returns_404_when_user_not_found`), not the implementation (`test_get_user_2`).
- Fixtures for shared setup, not copy-pasted setup code across tests.

## Unit vs integration
- Unit tests cover domain/business logic in isolation — fast, no network, no real DB.
- Integration tests exercise the real boundary (real DB via a test container/fixture, real HTTP client against the app) for anything that involves a query, a migration, or cross-service wiring.
- A bug that only shows up when a mock diverges from the real dependency's behavior is a sign the test needs to be an integration test, not a more detailed mock.

## Avoid overmocking
- Prefer real behavior: `tmp_path` for files, real local resources. Mock only what can't run locally (third-party APIs, clock) — never your own domain logic.
- Don't mock the database in a test whose entire purpose is verifying a query or a migration works.
- No heavy `@patch` use. If a test needs several mocks to run, that's usually a sign the unit under test is doing too much, not that the test needs more mocking.

## Avoid brittle tests
- Assert on behavior and outputs, not on internal implementation details (private method call counts, internal state) that can change without changing behavior.
- No sleep-based timing assumptions — use explicit waits/polling or dependency injection of a fake clock.
- Tests don't depend on execution order or shared mutable state between tests.

## Output format
For each issue found:
```
[ISSUE] <file>:<line or section> — <description>
[FIX]   <what was changed and why>
```
Then show the corrected or new test file.
</skill>
