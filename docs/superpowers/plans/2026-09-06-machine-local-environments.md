# Machine-Local Development Environments Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move machine-specific development environment hooks into ignored `local.zsh` while keeping the public Zsh repository portable.

**Architecture:** The three public startup files retain only reusable shell behavior. `.zshrc` loads one ignored machine-local file at the end, preserving a clear extension point for the current Mac.

**Tech Stack:** Zsh, Git, Markdown, Astro, Bun.

---

### Task 1: Move machine-specific hooks

**Files:**

- Modify: `.zshenv`
- Modify: `.zprofile`
- Modify: `.zshrc`
- Create: `local.example.zsh`
- Create: `local.zsh`

- [x] Remove Cargo from `.zshenv`.
- [x] Remove JetBrains Toolbox and OrbStack from `.zprofile`.
- [x] Remove Bun, Conda, and Proto from `.zshrc`.
- [x] Add all six guarded integrations to `local.zsh`.
- [x] Add commented examples and initialization instructions to `local.example.zsh`.

### Task 2: Synchronize documentation

**Files:**

- Modify: `README.md`
- Modify: `/Users/Apple/Projects/Blog/chirping-blog/src/content/posts/zh/modern-macos-zsh-workflow.md`
- Modify: `/Users/Apple/Projects/Blog/chirping-blog/docs/superpowers/specs/2026-09-05-zsh-config-repository-tutorial-design.md`
- Modify: `/Users/Apple/Projects/Blog/chirping-blog/docs/superpowers/plans/2026-09-05-zsh-config-repository-tutorial.md`

- [x] Describe public startup files without machine-specific tools.
- [x] Explain `local.zsh` as the ignored extension point.
- [x] Explain how to copy `local.example.zsh` into `local.zsh`.
- [x] Present the six development environments as local examples in the blog.

### Task 3: Verify both repositories

**Files:**

- Test: `tests/terminal-tools.zsh`

- [x] Run Zsh syntax and terminal-tool integration tests.
- [x] Validate a fresh PTY login Shell.
- [x] Confirm `local.zsh` is ignored and public startup files contain no migrated hooks.
- [x] Run blog tests, Astro checks, Prettier, and production build.
- [x] Inspect both Git worktrees without committing or pushing.
