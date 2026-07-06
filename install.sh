#!/usr/bin/env bash
# Bootstrap dotfiles on macOS: Homebrew, Brewfile packages, Oh My Zsh, and zsh config.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
SOURCE_ZSHRC="$REPO_ROOT/zsh/zshrc"
TARGET_ZSHRC="${HOME}/.zshrc"
SOURCE_ZPROFILE="$REPO_ROOT/zsh/zprofile"
TARGET_ZPROFILE="${HOME}/.zprofile"
BREWFILE="$REPO_ROOT/Brewfile"

die() {
  echo "install.sh: $*" >&2
  exit 1
}

resolve_realpath() {
  python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$1"
}

warn_no_xcode_clt() {
  if ! xcode-select -p &>/dev/null; then
    echo ""
    echo "Warning: Xcode Command Line Tools may be missing."
    echo "If Homebrew or installs fail, run: xcode-select --install"
    echo ""
  fi
}

ensure_brew_on_path() {
  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
    return 0
  fi
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    return 0
  fi
  if [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
    return 0
  fi
  return 1
}

install_homebrew_if_needed() {
  if ensure_brew_on_path; then
    echo "Homebrew is already available ($(command -v brew))."
    return 0
  fi

  echo "Homebrew was not found. The official installer may ask for password or RETURN."
  read -r -p "Continue with Homebrew installation? [y/N] " ans || true
  case "${ans:-}" in
    [yY]|[yY][eE][sS]) ;;
    *)
      echo "Skipping Homebrew install."
      echo "Install manually from https://brew.sh then run this script again."
      exit 2
      ;;
  esac

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if ! ensure_brew_on_path; then
    echo "Homebrew installed but \`brew\` is not on PATH in this shell."
    echo "Follow the Homebrew installer output to add brew to your PATH (for Apple Silicon, often: eval \"\$(/opt/homebrew/bin/brew shellenv)\"), open a new terminal, and re-run:"
    echo "  $REPO_ROOT/install.sh"
    exit 3
  fi
}

run_brew_bundle() {
  [[ -f "$BREWFILE" ]] || die "Missing Brewfile at $BREWFILE"
  echo "Running brew bundle..."
  (cd "$REPO_ROOT" && brew bundle install --file="$BREWFILE")
}

install_oh_my_zsh_if_needed() {
  if [[ -d "${HOME}/.oh-my-zsh" ]]; then
    echo "Oh My Zsh already present at ~/.oh-my-zsh."
    return 0
  fi

  echo "Installing Oh My Zsh (unattended; will not launch zsh or change login shell)."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

prompt_and_link_shell_file() {
  local source_path="$1"
  local target_path="$2"
  local display_name="$3"

  local src_real
  [[ -f "$source_path" ]] || die "Missing source $display_name at $source_path"
  src_real="$(resolve_realpath "$source_path")"

  if [[ -e "$target_path" ]] || [[ -L "$target_path" ]]; then
    local dst_real
    dst_real="$(resolve_realpath "$target_path")"

    if [[ "$src_real" == "$dst_real" ]]; then
      echo "~/.$display_name already points at this repo's zsh/$display_name."
      return 0
    fi

    echo ""
    echo "Existing ~/.$display_name does not match this repo's symlink target."
    if [[ -L "$target_path" ]]; then
      echo "  Current symlink: $(readlink "$target_path")"
    else
      echo "  Current path: $target_path (regular file)"
    fi
    echo "  Desired target: $source_path"
    echo ""
    echo "  [B] Backup existing ~/.$display_name and replace with symlink to repo"
    echo "  [S] Skip - leave ~/.$display_name unchanged"
    echo "  [A] Abort install (default)"
    read -r -p "Choose [B/s/A]: " choice || true

    local c="${choice:-A}"
    case "$(echo "$c" | tr '[:upper:]' '[:lower:]')" in
      b)
        local backup="${target_path}.pre-dotfiles.$(date +%Y%m%d%H%M%S)"
        mv "$target_path" "$backup"
        echo "Backed up to $backup"
        ln -sf "$source_path" "$target_path"
        echo "Symlinked $target_path -> $source_path"
        ;;
      s)
        echo "Skipped linking ~/.$display_name. Use your backup or merge manually, then re-run if needed."
        return 0
        ;;
      *)
        echo "Aborted; ~/.$display_name unchanged."
        exit 4
        ;;
    esac
  else
    ln -sf "$source_path" "$target_path"
    echo "Symlinked $target_path -> $source_path"
  fi
}

main() {
  [[ "$(uname -s)" == "Darwin" ]] || die "This script supports macOS only."

  warn_no_xcode_clt

  echo "Dotfiles repo root: $REPO_ROOT"
  echo ""

  install_homebrew_if_needed
  ensure_brew_on_path || die "brew not available after install step"

  run_brew_bundle
  install_oh_my_zsh_if_needed
  prompt_and_link_shell_file "$SOURCE_ZPROFILE" "$TARGET_ZPROFILE" "zprofile"
  prompt_and_link_shell_file "$SOURCE_ZSHRC" "$TARGET_ZSHRC" "zshrc"

  echo ""
  echo "Done. Open a new terminal or run: exec zsh"
  echo "Validation: see terminal-zsh-replication-guide.md section 4"
}

main "$@"
