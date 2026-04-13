# ADR-001: Single-user scope

**Date:** 2025-02-18
**Status:** Accepted

## Context

Security review flagged wildcard stow install, wildcard bootstrap execution, and `curl | bash` patterns as risks for multi-account provisioning.

## Decision

This dotfiles repo is single-user only. Multi-account provisioning is out of scope.

## Consequences

- Wildcard `stow` install and bootstrap execution are acceptable
- `curl | bash` for Homebrew/tools is acceptable
- No profile system or per-account package manifests needed
- Security audits evaluate against single-user threat model
