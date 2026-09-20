# ~/.config/shell/env.sh — ENVIRONMENT layer shared by bash and zsh.
#
# THE SINGLE OWNER of PATH and the environment variables. No other file adds
# entries to PATH. Idempotent: PATH does not grow however often it is sourced.
# Defines NO aliases — those live in aliases.sh, because zsh expands aliases
# inside scripts.
#
# POSIX sh syntax. Do not use bash- or zsh-specific constructs.

# ─── PATH helpers ─────────────────────────────────────────────────────────
# Does nothing when the directory is missing or already on PATH.
_kb_path_prepend() {
  [ -d "$1" ] || return 0
  # $1 is quoted, so it matches LITERALLY inside the case pattern; directory
  # names containing glob metacharacters compare correctly as well.
  case ":${PATH}:" in *":$1:"*) return 0 ;; esac
  PATH="$1${PATH:+:$PATH}"
}

_kb_path_append() {
  [ -d "$1" ] || return 0
  # $1 is quoted, so it matches LITERALLY inside the case pattern; directory
  # names containing glob metacharacters compare correctly as well.
  case ":${PATH}:" in *":$1:"*) return 0 ;; esac
  PATH="${PATH:+$PATH:}$1"
}

# ─── PATH: highest priority ───────────────────────────────────────────────
_kb_path_prepend "$HOME/bin"
_kb_path_prepend "$HOME/.local/bin"
# What ~/.cargo/env used to do. That file is no longer sourced; it was being
# pulled in twice, from both .zshenv and .profile.
_kb_path_prepend "$HOME/.cargo/bin"

# ─── PATH: development tools ──────────────────────────────────────────────
_kb_path_append "$HOME/flutter/bin"
_kb_path_append "$HOME/bin/chezmoi"
_kb_path_append "$HOME/.deno/bin"
_kb_path_append "$HOME/.pub-cache/bin"
_kb_path_append "$HOME/.bun/bin"
_kb_path_append "$HOME/.npm-global/bin"
_kb_path_append "$HOME/.local/share/JetBrains/Toolbox/scripts"
_kb_path_append "$HOME/lua-language-server/bin"
_kb_path_append "$HOME/.pulumi/bin"
_kb_path_append "$HOME/.local/share/fnm"

# ─── Android SDK ──────────────────────────────────────────────────────────
if [ -d /mnt/XPG-Data/Android/sdk ]; then
  ANDROID_HOME=/mnt/XPG-Data/Android/sdk
  export ANDROID_HOME
  _kb_path_append "$ANDROID_HOME/tools"
  _kb_path_append "$ANDROID_HOME/platform-tools"
fi

# ─── Java ─────────────────────────────────────────────────────────────────
# readlink and dirname fork processes; skip when JAVA_HOME is already set,
# which also keeps this block idempotent.
if [ -z "${JAVA_HOME:-}" ] && command -v java >/dev/null 2>&1; then
  _kb_java=$(readlink -f "$(command -v java)")
  JAVA_HOME=$(dirname "$(dirname "$_kb_java")")
  export JAVA_HOME
  _kb_path_append "$JAVA_HOME/bin"
  unset _kb_java
fi

export PATH

# ─── XDG ──────────────────────────────────────────────────────────────────
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# ─── Ollama ───────────────────────────────────────────────────────────────
export OLLAMA_MODELS="/mnt/SEAGATE-Data/ollama"
export OLLAMA_HOST="0.0.0.0"

# ─── Editor and pager ─────────────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export LESS='-R -F -X -i -M'
export MANPAGER='nvim +Man!'

# ─── Secrets ──────────────────────────────────────────────────────────────
# NOT managed by chezmoi, and it should stay that way.
[ -f "$HOME/.profile_secrets" ] && . "$HOME/.profile_secrets"

return 0 2>/dev/null || true
