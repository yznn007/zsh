# ZDOTDIR Direct Loading Implementation Plan

> **For agentic workers:** Execute inline in the current task. Do not commit, stage, or push.

**Goal:** Replace Home-directory bridge files with the upstream repository's direct `ZDOTDIR` loading model on macOS.

**Architecture:** A guarded system-wide `/etc/zshenv` sets `XDG_CONFIG_HOME` and points `ZDOTDIR` at `~/.config/zsh` only when that directory exists. Zsh then reads the repository's `.zshenv`, `.zprofile`, and `.zshrc` directly. The repository's `starship.toml` becomes the active Starship configuration through `STARSHIP_CONFIG`.

**Tech Stack:** macOS Zsh, Homebrew, Starship, shell startup files.

---

### Task 1: Preserve the current startup configuration

**Files:**
- Back up: `/Users/Apple/.zshenv`
- Back up: `/Users/Apple/.zprofile`
- Back up: `/Users/Apple/.zshrc`
- Back up: `/Users/Apple/.config/starship.toml`

- [x] Create a timestamped directory under `/Users/Apple/.codex/backups/`.
- [x] Copy the four current files into it before changing startup behavior.

### Task 2: Make the repository self-contained

**Files:**
- Modify: `/Users/Apple/.config/zsh/.zshenv`
- Create: `/Users/Apple/.config/zsh/.zprofile`
- Modify: `/Users/Apple/.config/zsh/.zshrc`
- Modify: `/Users/Apple/.config/zsh/prompt.zsh`

- [x] Set `ZSH_CONFIG_DIR` from `ZDOTDIR` and set `STARSHIP_CONFIG` to `$ZDOTDIR/starship.toml`.
- [x] Move portable Homebrew, JetBrains Toolbox, and OrbStack login initialization into the repository's `.zprofile`.
- [x] Make the repository's `.zshrc` prefer `ZDOTDIR`.
- [x] Store command history under `$XDG_STATE_HOME/zsh/history` so direct loading does not create `.zsh_history` in the repository.
- [x] Make `starship_use` operate on the active `STARSHIP_CONFIG` path.
- [x] Run `zsh -n` against all repository startup files.

### Task 3: Enable direct Zsh loading on macOS

**Files:**
- Create: `/etc/zshenv`

- [x] Install a root-owned `/etc/zshenv` that defaults `XDG_CONFIG_HOME` to `$HOME/.config`.
- [x] Set `ZDOTDIR` only when `$XDG_CONFIG_HOME/zsh` exists.
- [x] Start a clean login-interactive Zsh and verify that `ZDOTDIR`, `ZSH_CONFIG_DIR`, and `STARSHIP_CONFIG` point into the repository.

### Task 4: Retire the old bridge files

**Files:**
- Retire: `/Users/Apple/.zshenv`
- Retire: `/Users/Apple/.zprofile`
- Retire: `/Users/Apple/.zshrc`
- Retire: `/Users/Apple/.config/starship.toml`

- [x] Move the old Home startup files and duplicate Starship file into the backup directory.
- [x] Start another clean login-interactive Zsh to prove the repository loads without the bridges.

### Task 5: Document a new-Mac installation

**Files:**
- Modify: `/Users/Apple/.config/zsh/README.md`

- [x] Replace the bridge-based setup text with dependency installation, clone, `/etc/zshenv`, default-shell check, first launch, and verification steps.
- [x] Explain that repository startup files and `starship.toml` load directly.
- [x] Document safe handling of existing startup files and removal of `/etc/zshenv` during rollback.
- [x] Run `git diff --check`, syntax checks, and the terminal-tools regression test.
