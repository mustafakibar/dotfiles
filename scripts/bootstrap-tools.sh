#!/usr/bin/env bash
# Installs the EXTERNAL tools these dotfiles depend on, on a fresh machine.
#
# chezmoi manages config FILES, not the binaries behind them — oh-my-zsh, eza,
# starship and friends. This script closes that gap.
#
# Design decisions:
#   * NO `run_once_` prefix: it should not run by itself during
#     `chezmoi apply`. Invoke it by hand.
#   * Idempotent: skips what is installed, safe to run twice.
#   * Never performs the steps that need sudo; it only prints the command.
#
# Usage: ~/.local/share/chezmoi/scripts/bootstrap-tools.sh
set -uo pipefail

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH_DIR/custom}"
LOCAL_BIN="$HOME/.local/bin"

ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
run()  { printf '  \033[34m→\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }

APT_MISSING=()
need_apt() { command -v "$1" >/dev/null 2>&1 || APT_MISSING+=("$2"); }

echo "── oh-my-zsh ─────────────────────────────────────────────────────────"
if [ -r "$ZSH_DIR/oh-my-zsh.sh" ]; then
  ok "oh-my-zsh installed"
else
  run "cloning oh-my-zsh"
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR" \
    || warn "could not clone oh-my-zsh"
fi

echo "── zsh plugins ───────────────────────────────────────────────────────"
clone_plugin() {
  local name="$1" url="$2" dest="$ZSH_CUSTOM/plugins/$1"
  if [ -d "$dest/.git" ]; then
    ok "$name"
  else
    run "cloning $name"
    git clone --depth=1 "$url" "$dest" || warn "could not clone $name"
  fi
}
mkdir -p "$ZSH_CUSTOM/plugins"
clone_plugin zsh-autosuggestions      https://github.com/zsh-users/zsh-autosuggestions.git
clone_plugin zsh-completions          https://github.com/zsh-users/zsh-completions.git
clone_plugin zsh-syntax-highlighting  https://github.com/zsh-users/zsh-syntax-highlighting.git

echo "── ~/.local/bin symlinks ─────────────────────────────────────────────"
mkdir -p "$LOCAL_BIN"
# Debian and Ubuntu ship these binaries as fdfind and batcat.
for pair in "fd:fdfind" "bat:batcat"; do
  want="${pair%%:*}" have="${pair##*:}"
  if command -v "$want" >/dev/null 2>&1; then
    ok "$want"
  elif command -v "$have" >/dev/null 2>&1; then
    run "$LOCAL_BIN/$want -> $(command -v "$have")"
    ln -sf "$(command -v "$have")" "$LOCAL_BIN/$want"
  else
    warn "neither $want nor $have found; see the apt list below"
  fi
done

echo "── user-space installs ───────────────────────────────────────────────"
if command -v starship >/dev/null 2>&1; then
  ok "starship"
else
  run "installing starship into $LOCAL_BIN"
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$LOCAL_BIN" \
    || warn "could not install starship"
fi

if command -v fnm >/dev/null 2>&1; then
  ok "fnm"
else
  run "installing fnm"
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell \
    || warn "could not install fnm"
fi

echo "── tree-sitter CLI ───────────────────────────────────────────────────"
# nvim-treesitter's 'main' branch needs >= 0.26.1 to build parsers.
TS_MIN="0.26.1"
ts_ver="$(tree-sitter --version 2>/dev/null | awk '{print $2}')"
if [ -n "$ts_ver" ] && [ "$(printf '%s\n%s\n' "$TS_MIN" "$ts_ver" | sort -V | head -1)" = "$TS_MIN" ]; then
  ok "tree-sitter $ts_ver (>= $TS_MIN)"
elif command -v cargo >/dev/null 2>&1; then
  run "building tree-sitter-cli (this can take a few minutes)"
  cargo install tree-sitter-cli --locked || warn "could not install tree-sitter-cli"
else
  warn "tree-sitter ${ts_ver:-missing} — need >= $TS_MIN, and cargo is absent too."
  warn "  install rustup from https://rustup.rs, then: cargo install tree-sitter-cli --locked"
fi

echo "── system packages ───────────────────────────────────────────────────"
need_apt zsh      zsh
need_apt git      git
need_apt nvim     neovim
need_apt rg       ripgrep
need_apt fzf      fzf
need_apt eza      eza
need_apt zoxide   zoxide
need_apt fdfind   fd-find
need_apt batcat   bat
need_apt gcc      build-essential
if [ "${#APT_MISSING[@]}" -eq 0 ]; then
  ok "all present"
else
  warn "missing: ${APT_MISSING[*]}"
  warn "  sudo apt update && sudo apt install -y ${APT_MISSING[*]}"
fi

echo
echo "Done. Start a new shell with:  exec zsh -l"
