# Terminal / zsh setup — replication guide for agents

**Audience:** A future coding agent (or human) setting up a **new macOS computer** to match the user’s prior shell environment.

**Repository:** This project is **public** — do not add secrets or identifiers that should stay private when editing docs or configs (see `AGENTS.md` in the repo root).

**Source of truth:** This document was produced from `~/.zshrc` as used on the reference machine. If the user’s config drifts, re-read `~/.zshrc` and update this file.

---

## 1. What you are replicating

| Goal | Mechanism |
|------|-----------|
| **Prompt look** (green arrow, blue path segment, `~` for home) | Oh My Zsh theme **`robbyrussell`** |
| **Git shortcuts** (`gst`, `gco`, etc.) | Oh My Zsh **`git`** plugin |
| **Extra Oh My Zsh behavior** | Plugins **`dotenv`**, **`macos`**; **`COMPLETION_WAITING_DOTS`** |
| **Kiro CLI integration** | Sourced **pre** and **post** zsh snippets from Kiro’s Application Support path |
| **History search (atuin)** | `eval "$(atuin init zsh)"` — requires separate **atuin** install/login |
| **Node / JS toolchain** | **Volta** (`~/.volta`), **NVM** (Homebrew path on Apple Silicon) |
| **DB / GraphQL tooling** | **Postgres.app** bin on `PATH`, **Grafbase** `~/.grafbase/bin`, **Apollo Rover** completion file |
| **Custom alias** | `apm` → `cargo run --bin apm --` (only if that project exists) |

Treat **Oh My Zsh + theme + plugins** as the **minimum** for “same prompt + `gst`.” Everything else is **optional** unless the user explicitly wants full parity.

---

## 2. Prerequisites (new machine)

- **macOS** with **zsh** as the login shell (default).
- **Homebrew** (`/opt/homebrew` on Apple Silicon) if you will install **nvm** or other tools via Brew paths referenced in the config.
- **Git** installed (for `gst` to be meaningful).
- Network access to install Oh My Zsh, Homebrew packages, and optional CLIs.

---

## 3. Replication procedure

### 3.1 Core: Oh My Zsh

1. Install Oh My Zsh per [https://ohmyz.sh/](https://ohmyz.sh/) (official installer sets `~/.oh-my-zsh` and may back up an existing `~/.zshrc`).
2. Ensure `~/.zshrc` contains at least:

   - `export ZSH="$HOME/.oh-my-zsh"`
   - `ZSH_THEME="robbyrussell"`
   - `COMPLETION_WAITING_DOTS="true"` (optional but matches reference)
   - `plugins=(git dotenv macos)`
   - `source $ZSH/oh-my-zsh.sh`

3. **Do not** duplicate `source $ZSH/oh-my-zsh.sh`.

### 3.2 Kiro CLI

1. Install **Kiro CLI** using the user’s current official method (installer or package manager).
2. Confirm these files exist (paths are fixed on macOS):

   - `${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh`
   - `${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh`

3. In `~/.zshrc`, keep **Kiro pre at the very top** and **Kiro post at the very bottom** (as in the reference file). Use conditional `[[ -f ... ]] && source ...` so a missing install does not break the shell.

### 3.3 Optional: copy or merge full `~/.zshrc`

- Safest: copy the user’s backed-up `~/.zshrc` from the old machine, then **fix machine-specific paths**:
  - Replace any hardcoded `/Users/oldusername` with `$HOME` or the new account’s path (e.g. `~/.rhai-test/bin`).
  - Adjust **NVM** Homebrew paths if the new Mac is Intel (`/usr/local/opt/nvm`) vs Apple Silicon (`/opt/homebrew/opt/nvm`).
- Remove duplicate lines if merging (reference had `source ~/.rover-completion.zsh` twice and `grafbase` `PATH` twice — dedupe when cleaning).

### 3.4 Optional tools (install only if parity is required)

| Tool | Purpose | Validation hint |
|------|---------|-----------------|
| **atuin** | Sync/search shell history | `atuin --version`; `which atuin` |
| **Volta** | Node version manager | `which volta`; `volta --version` |
| **nvm** (Homebrew) | Node versions | `[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]` then `nvm --version` |
| **Postgres.app** | Local Postgres client tools | Test `which psql` after app install |
| **Grafbase CLI** | `grafbase` on PATH | `which grafbase` |
| **Rover** | Apollo CLI + completions | `rover --version`; completions only if `~/.rover-completion.zsh` exists |

### 3.5 Editor / terminal appearance (Cursor or VS Code)

Prompt comes from zsh; **font and colors** come from the editor’s integrated terminal settings. For visual parity, copy the user’s **Cursor/VS Code** `settings.json` entries such as `terminal.integrated.fontFamily`, theme, and font size — this is **not** in `~/.zshrc`.

---

## 4. Validation checklist

Run these in a **new terminal window** after editing `~/.zshrc` (or run `exec zsh` to reload).

### 4.1 Shell and Oh My Zsh

| Step | Command | Expected |
|------|---------|----------|
| Login shell | `echo $SHELL` | Path ending in `zsh` |
| Oh My Zsh loaded | `echo $ZSH` | `$HOME/.oh-my-zsh` |
| Theme | `echo $ZSH_THEME` | `robbyrussell` |
| Prompt theme file exists | `test -f "$ZSH/themes/robbyrussell.zsh-theme" && echo ok` | `ok` |

### 4.2 Git plugin (`gst` and friends)

| Step | Command | Expected |
|------|---------|----------|
| `gst` exists | `alias gst` | Shows `gst=git status` (or equivalent) |
| Plugin list | `echo $plugins` | Includes `git` (Oh My Zsh may show space-separated list) |
| Sanity | `type gst` | `gst` is an alias |

### 4.3 Other Oh My Zsh plugins

| Step | Command | Expected |
|------|---------|----------|
| Plugins | `echo $plugins` | Includes `dotenv` and `macos` if matching reference |

### 4.4 Kiro CLI

| Step | Command | Expected |
|------|---------|----------|
| Pre file | `test -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" && echo ok` | `ok` after install |
| Post file | `test -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" && echo ok` | `ok` after install |

If Kiro is **not** installed, validation passes if zsh starts without errors and the conditional sources are skipped.

### 4.5 Optional components

| Component | Command | Expected |
|-----------|---------|----------|
| atuin | `which atuin` | Path to binary |
| Volta | `which volta` | Path under `~/.volta` or install location |
| nvm | `command -v nvm` | `nvm` as shell function after sourcing |
| Rover completion | `test -f ~/.rover-completion.zsh && echo ok` | `ok` if file copied |

### 4.6 End-to-end “feels right” test

1. `cd` to a **git repository**.
2. Confirm the prompt shows the **branch** (robbyrussell shows git info in supported layouts).
3. Run **`gst`** — output should match **`git status`**.
4. Run **`gco`** (or another git alias from the plugin) only if git is configured — should not error with “command not found.”

---

## 5. Troubleshooting (for agents)

- **`gst: command not found`:** Oh My Zsh `git` plugin not loaded — check `plugins=(... git ...)` and that `source $ZSH/oh-my-zsh.sh` runs **after** `plugins=`.
- **Plain prompt, no colors:** Theme not set or overridden — verify `ZSH_THEME="robbyrussell"` and no other prompt theme framework runs after Oh My Zsh.
- **Errors on shell start:** Comment out optional blocks (atuin, nvm, Kiro) one by one; fix paths for Intel vs Apple Silicon Homebrew.
- **Kiro errors:** Ensure pre/post blocks stay at top/bottom; use `-f` tests before `source`.

---

## 6. Reference configuration snapshot (minimal excerpt)

Use this as a **template** if not copying the full file; expand with optional sections as needed.

```zsh
# Kiro CLI pre — keep first
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
COMPLETION_WAITING_DOTS="true"

plugins=(
  git
  dotenv
  macos
)

source $ZSH/oh-my-zsh.sh

# … user PATH, atuin, volta, nvm, aliases, completions …

# Kiro CLI post — keep last
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
```

---

## 7. Document maintenance

When the user changes their stack, update **sections 1, 3.4, and 4.5** so the next agent does not install obsolete tools. Optionally attach a dated export of `~/.zshrc` next to this file for byte-level comparison.

**Last aligned with:** `~/.zshrc` on the reference machine when this guide was generated (sync with repo `zsh/zshrc` after edits).
