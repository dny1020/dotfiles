---
name: linux-best-practices
description: "Linux scripts, configs, and system changes. Invoked when: writing a shell script, managing a systemd unit, setting permissions, reviewing sudoers/SSH config, or hardening a host."
---

<skill>
Review the code or configuration provided, or the recent changes on the current branch, against this checklist. Fix every issue you find and explain each change in one line.

## Shell scripting
- Shebang must be `#!/usr/bin/env bash` (or explicit `/bin/bash`), never `/bin/sh` for bash features.
- Always set `set -euo pipefail` on the second line of every script.
- Quote all variable expansions: `"$var"`, `"${array[@]}"`.
- Use `[[ ]]` not `[ ]` for conditionals.
- Never parse `ls` output — use globs or `find`.
- Avoid `eval` and unvalidated `$()` with user input (command injection risk).
- Run `shellcheck` on the script when available; otherwise flag likely SC violations.

## File permissions
- Config files with secrets: `600` (owner read/write only).
- Scripts and binaries: `750` or `755`, never `777`.
- Directories: `700` for private, `755` for shared — never `777`.
- SSH keys: `600` for private, `644` for public.
- Never `chmod -R 777` anything.

## systemd units
- Use `Type=oneshot` with `RemainAfterExit=no` for scripts that run and exit.
- Always set `User=` and `Group=` — avoid running services as root unless strictly necessary.
- Include `Restart=on-failure` and `RestartSec=5s` for long-running services.
- Use `StandardOutput=journal` and `StandardError=journal`.
- Add `After=network-online.target` when network is required.

## SSH hardening (when reviewing sshd_config)
- `PermitRootLogin no`
- `PasswordAuthentication no`
- `AllowUsers <explicit list>`
- `Port` changed from 22 when exposed to internet.

## sudo / privilege escalation
- Use `sudo` for one-off privilege, not persistent root shells.
- In scripts, use `sudo -n` (non-interactive) and verify it's available.
- Prefer dedicated service accounts over `root` for daemons.

## Idempotency
- Guard installs with existence checks: `if ! command -v foo &>/dev/null; then ...`.
- Guard file creation with `[[ -f path ]] || ...`.
- Use `tee -a` over `>>` when appending requires sudo.

## Logging
- Long-running scripts should log to `journald` via `systemd-cat` or to a file under `/var/log/<service>/`.
- Include timestamps: `date '+%Y-%m-%dT%H:%M:%S'`.
</skill>
