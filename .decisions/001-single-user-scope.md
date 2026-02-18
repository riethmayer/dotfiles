# ADR-001: Single-user scope

**Date:** 2026-02-18
**Status:** Accepted

## Context

Security review (2026-02-17) flagged wildcard stow install, wildcard bootstrap execution, and `curl | bash` patterns as risks for multi-account provisioning (e.g. `jane-assistant`).

## Decision

This dotfiles repo is single-user (janriethmayer) only. Multi-account provisioning is out of scope. Separate accounts (e.g. jane-assistant) maintain their own dotfiles repos.

## Consequences

- Wildcard `stow` install (`ls -d stow/*`) is acceptable
- Wildcard bootstrap execution (`for file in dir/*`) is acceptable
- `curl | bash` for Homebrew/tools is acceptable (standard personal dotfiles pattern)
- No profile system or per-account package manifests needed
- Security audits should evaluate against single-user threat model, not multi-tenant
