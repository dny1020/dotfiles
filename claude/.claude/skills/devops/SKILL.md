---
name: devops
description: "CI/CD, containers, and release practice. Invoked when: writing a Gitea/GitHub Actions pipeline, building a Docker image, handling secrets in CI, adding health checks, or reviewing a deploy/rollback strategy."
---

<skill>
Write or review the pipeline, Dockerfile, or deploy workflow against this checklist. Fix every issue found and explain each change in one line.

## CI/CD (Gitea Actions / GitHub Actions)
- Stages: build → test → deploy; deploy declares `needs: [test]`.
- The test stage runs `verify` (or the same commands in the same order) — CI and the local machine never disagree about what passing means.
- Pin actions to a semver tag or SHA — never `@main` or `@latest`.
- Secrets come from the CI secret store (`${{ secrets.NAME }}`), never hardcoded.
- Cache dependencies (uv, npm) when the build is slow enough to matter.
- After deploy, a smoke step curls the health endpoint and fails the job on non-200.

## Dockerfile
- Slim base image with a pinned tag (e.g. `python:3.12-slim`); multi-stage only when there is a build step to leave behind.
- Run as a non-root `USER`.
- `.dockerignore` excludes `.git`, tests and local envs.

## Health checks
- Long-running containers have a `HEALTHCHECK` (or Compose `healthcheck`); dependents use `depends_on: condition: service_healthy`.

## Secrets
- `.env` is for local dev only and never committed; production secrets live in CI secrets, Ansible Vault, or a secrets manager.
- After any accidental exposure, rotate the secret — git history counts as compromised.

## Deploy and rollback
- Tag every release image with the git SHA (and a version if there is one).
- Compose update: pull the new image, then `docker compose up -d --no-deps <service>`; keep the previous tag until the new one is healthy.
- Rollback = `docker compose up -d` with the previous tag pinned in `.env`; Ansible playbooks accept an `image_tag` variable.

## Logs
- Containers log to stdout/stderr, and the Docker daemon has log rotation (`max-size`, `max-file`).
</skill>
