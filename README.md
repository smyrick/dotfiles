# dotfiles

Personal macOS shell setup: **zsh**, **Oh My Zsh**, **Homebrew**, and optional tooling so you can clone this repo on a new machine and get running quickly.

**This repository is public.** Do not commit secrets, credentials, or private keys—see [`AGENTS.md`](AGENTS.md).

## Prerequisites

- **macOS** (this repo targets macOS paths such as Homebrew on Apple Silicon or Intel).
- **Git** (to clone this repository).
- Network access for installs.
- **Xcode Command Line Tools** are usually required before or during Homebrew setup. If installs fail, run:

  ```bash
  xcode-select --install
  ```

## Quick start

1. Clone this repository:

   ```bash
   git clone <this-repo-url> ~/path/to/dotfiles
   cd ~/path/to/dotfiles
   ```

2. Run the installer:

   ```bash
   chmod +x ./install.sh   # once, if needed
   ./install.sh
   ```

   The script will, in order:

   - Warn if Command Line Tools look missing.
   - Install **Homebrew** if it is not on your `PATH` (the official installer may prompt for your password or **Return**—that is normal).
   - Run **`brew bundle install`** using the repo’s [`Brewfile`](Brewfile) (currently **nvm**).
   - Install **Oh My Zsh** if `~/.oh-my-zsh` is missing (unattended; it does not switch your login shell by default).
   - Offer to replace **`~/.zshrc`** with a **symlink** to [`zsh/zshrc`](zsh/zshrc). If you already have a `~/.zshrc`, you can **back it up** (timestamped under `~/.zshrc.pre-dotfiles.*`), **skip**, or **abort**.

3. Open a **new terminal** window or run:

   ```bash
   exec zsh
   ```

## What gets linked

- **`~/.zshrc`** → **`<repo>/zsh/zshrc`** (symlink).

   Pulling updates to this repository updates your shell config on the next new shell without copying files again.

## Brewfile

[`Brewfile`](Brewfile) lists Homebrew formulae to install via `brew bundle`. Keep it in sync when you change your baseline tools. After editing it on an existing machine:

```bash
cd /path/to/dotfiles
brew bundle install --file=Brewfile
```

`Brewfile.lock.json` is ignored by git (see [`.gitignore`](.gitignore)).

## Documentation and validation

- **[terminal-zsh-replication-guide.md](terminal-zsh-replication-guide.md)** — full replication checklist for humans and agents (Oh My Zsh theme/plugins, optional Kiro, atuin, Volta, Grafbase, Rover, Postgres.app, troubleshooting).
- After setup, use **section 4** of that guide to validate `gst`, theme, plugins, and optional components.

## Optional: shell history (atuin)

If you install **[atuin](https://docs.atuin.sh/)** yourself (not via this Brewfile), your [`zsh/zshrc`](zsh/zshrc) will initialize it when the binary is on `PATH`. Run **`atuin register`** / **`atuin login`** as needed for sync.

## Optional: terminal look in Cursor / VS Code

Prompt styling comes from zsh; **font and colors** come from the editor’s integrated terminal settings (for example `terminal.integrated.fontFamily`). Copy those from your old machine’s `settings.json` if you want visual parity—see section 3.5 of [terminal-zsh-replication-guide.md](terminal-zsh-replication-guide.md).

## License

See [LICENSE](LICENSE).
