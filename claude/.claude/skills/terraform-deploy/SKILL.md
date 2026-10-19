---
name: terraform-deploy
description: "Terraform for AWS. Invoked when: provisioning AWS infrastructure, writing or reviewing modules, or setting up remote state. Self-hosted RPi/Ansible/Compose goes to the `iac-expert` agent instead."
---

<skill>
Write or review the Terraform code against this checklist. Fix every issue found and explain each change in one line.

## Module structure
- A module under `modules/<name>/` (`variables.tf`, `outputs.tf`, `main.tf`) only when two or more root modules use it — no module indirection for a single call site.
- With more than one environment, each (`dev`, `prod`, ...) is its own root module calling the shared modules, not a copy of the same resources.
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

Show the exact `terraform plan`/`terraform apply` command to run, including any `-var-file` needed.
</skill>
