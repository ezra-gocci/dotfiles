# Project Memory

## GitHub Account: ezra-gocci
- `gh` CLI is authenticated
- All repos are PRIVATE as of 2026-02-19
- Account purpose: digital footprint for IT expertise demonstration

## Active Repos (9)
1. `cv` — Git-managed CV/resume with web, markdown, PDF generation
2. `fast-forward` — Full-stack dev tutorial & API gateway (Rust/Go/Python/K8s) — THE main project
3. `beat-em` — Time series ML classification (KG-MTP + Hydra) — contains v1/, docs-mkdocs/, 13 flaw_* branches
4. `lets-dance` — Music download service (Python) — contains v1/ from merged letsdance
5. `investsmart` — LLM-powered financial reporting (TypeScript)
6. `claude-vault` — Knowledge base from Claude chat history + Obsidian integration
7. `perfect-start` — Lyrics storage for recording sessions
8. `leet` — LeetCode solutions / algorithm learning (Python)
9. `dotfiles` — MacOS developer environment provisioning (new, empty)

## FastForward (fast-forward)
- 7 sections, 21 phases, 101 steps comprehensive IT tutorial
- Covers: Rust, Go, Python, gRPC, protobuf, Kubernetes, CQRS, observability, CI/CD, React, Tauri, React Native
- Current progress: Phase 1 steps 1-3 (step 1 complete)
- Has PM system: 21 epics, 101 stories, 404 tasks in plain-text markdown
- deploy-tailscale merged into infra/tailscale/
- See `docs/path/curriculum.md` for full curriculum

## Cleanup (2026-02-19)
- 12 repos archived, 6 deleted (recorded in audit-results/deleted-repos.md)
- Merges: deploy-tailscale->fast-forward, hydra*+ez-alec-doc->beat-em, letsdance*->lets-dance, cv*->cv
- gh visibility flag needs: --accept-visibility-change-consequences
- gh repo rename needs: --yes flag

## Session Archive (2026-02-19)
- 16 Claude Code + Cowork sessions extracted to claude-vault/sessions/
- Claude config backed up to dotfiles/claude/
- Restore guide: dotfiles/RESTORE-CHECKLIST.md

## Repo Cleanup Project
- Working dir: `/Users/Ezra/Code/github-cleanup`
- Temp merge dir: `/tmp/github-cleanup-merges/`
