---
name: devops
description: "CI/CD, containers, and release practice. Invoked when: writing a Gitea/GitHub Actions pipeline, building a Docker image, handling secrets in CI, adding health checks, or reviewing a deploy/rollback strategy."
---

<skill>
Review the CI/CD pipeline, Dockerfile, or deployment workflow and apply the following DevOps best practices. Fix every issue found and explain each change in one line.

## Style
- No AI-looking output: no filler comments, no unnecessary layers of scripts/jobs for what a single step can do.

## CI/CD pipelines (Gitea Actions / GitHub Actions)
- Pipelines must have at minimum three stages: **build → test → deploy**.
- Pin action versions to a full SHA or semver tag — never `@main` or `@latest`.
- Secrets must come from the CI secret store (`${{ secrets.NAME }}`), never hardcoded.
- Cache dependencies (pip, npm, go modules) to cut build time.
- Deploy stage must depend explicitly on test passing (`needs: [test]`).
- Test stages run the gates from AGENTS.md verbatim, same order — CI and the developer's machine must never disagree about what passing means.
- CI adds the steps the local React gate skips (`npm run typecheck`, `npm run test`) as separate stages, so a failure names which one broke.
- Add a smoke-test step after deploy that curls a health endpoint and fails the job if it returns non-200.

## Dockerfile hygiene
- Use slim or distroless base images (e.g., `python:3.12-slim`, `gcr.io/distroless/base`).
- Multi-stage builds: separate `builder` stage from the final runtime image.
- Never run the app as `root` inside the container — add `USER appuser`.
- Copy only what is needed: use `.dockerignore` to exclude `.git`, `*.md`, `tests/`, local envs.
- Pin base image digests for reproducible builds: `FROM python:3.12-slim@sha256:...`.
- Label images: `LABEL org.opencontainers.image.source`, `version`, `revision`.

## Health checks
- Every long-running container must have a `HEALTHCHECK` directive.
- Compose stacks must declare `healthcheck.test`, `interval`, `timeout`, `retries`.
- Reverse-proxy upstreams must only receive traffic after health check passes (`depends_on: condition: service_healthy`).

## Secrets management
- `.env` files are for local dev only — never commit them.
- Production secrets go into CI secrets, Ansible Vault, or a secrets manager.
- Rotate secrets after any accidental exposure; treat all history as compromised.

## Zero-downtime deploys
- For Docker Compose: use `docker compose up -d --no-deps --build <service>` to update one service at a time.
- Always pull the new image before stopping the old container.
- Keep the previous image tag until the new deploy is confirmed healthy.

## Rollback procedure (always document this)
- Tag every release image with a version and `git` SHA.
- Rollback = `docker compose up -d` with the previous image tag pinned in `.env`.
- Ansible playbooks must accept a `image_tag` variable to pin deployments.

## Observability
- Containers must log to stdout/stderr (not files) so Docker captures them.
- Add log rotation to the Docker daemon config (`max-size`, `max-file`).
- Expose a `/healthz` or `/metrics` endpoint for each service.
- Alert on container restarts > 3 in 5 minutes.

## Output format
For each issue found:
```
[ISSUE] <file>:<line or section> — <description>
[FIX]   <what was changed and why>
```
Then show the corrected file or diff. End with a one-paragraph summary of the overall pipeline health.
</skill>
