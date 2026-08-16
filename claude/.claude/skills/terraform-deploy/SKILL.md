---
name: terraform-deploy
description: "Terraform for AWS. Invoked when: provisioning AWS infrastructure, writing or reviewing modules, or setting up remote state. Self-hosted RPi/Ansible/Compose goes to the `iac-expert` agent instead."
---

<skill>
Write or review the Terraform code and apply the following checklist. Fix every issue found and explain each change in one line.

## Style
- No AI-looking code: no filler comments, no module indirection for a resource with a single call site.

## Module structure
- Reusable infrastructure is a module under `modules/<name>/` with its own `variables.tf`, `outputs.tf`, `main.tf` — not copy-pasted between environments.
- Environments (`dev`, `staging`, `prod`) are separate root modules that call shared modules with different variables, not separate copies of the same resources.
- No hardcoded account IDs, regions, or ARNs — pass them as variables or look them up via data sources.

## Variables and outputs
- Every variable has a `description` and, where safe, a sensible `default`.
- Variables that take secrets are marked `sensitive = true` and never given a hardcoded default.
- Every module exposes the outputs a caller actually needs (ARNs, IDs, endpoints) — not everything, just what's consumed downstream.

## State management
- Remote state backend (S3 + DynamoDB lock table, or Terraform Cloud) — never local state for anything beyond a throwaway experiment.
- State is separated per environment; one `prod` mistake can't corrupt `dev` state.
- `.tfstate` and `.tfvars` with secrets are gitignored; never committed.

## IAM — least privilege
- No `"Action": "*"` or `"Resource": "*"` unless there's a documented reason a narrower policy doesn't work.
- Roles are scoped to the specific resources and actions the workload needs, not the AWS managed `AdministratorAccess`.
- Cross-account or cross-service access uses assume-role with an explicit trust policy, not shared long-lived credentials.

## Output format
For each issue found:
```
[ISSUE] <file>:<line or section> — <description>
[FIX]   <what was changed and why>
```
Then show the corrected `.tf` file or diff, and the exact `terraform plan`/`terraform apply` command to run, including any `-var-file` needed.
</skill>
