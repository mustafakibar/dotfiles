# ~/.config/shell/env.sh — bash ve zsh ortak ORTAM katmanı.
#
# PATH ve ortam değişkenlerinin TEK SAHİBİ. Başka hiçbir dosya PATH'e girdi eklemez.
# Idempotent: kaç kez source edilirse edilsin PATH büyümez.
# Alias TANIMLAMAZ — onlar aliases.sh'ta (zsh script'lerinde alias genişletilir).
#
# POSIX sh sözdizimi. bash/zsh'a özgü yapı kullanma.

# ─── PATH yardımcıları ────────────────────────────────────────────────────
# Dizin mevcut değilse veya PATH'te zaten varsa hiçbir şey yapmaz.
_kb_path_prepend() {
  [ -d "$1" ] || return 0
  # $1 tırnak içinde olduğu için case deseninde LİTERAL olarak eşleşir;
  # glob metakarakteri içeren dizin adları da doğru karşılaştırılır.
  case ":${PATH}:" in *":$1:"*) return 0 ;; esac
  PATH="$1${PATH:+:$PATH}"
}

_kb_path_append() {
  [ -d "$1" ] || return 0
  # $1 tırnak içinde olduğu için case deseninde LİTERAL olarak eşleşir;
  # glob metakarakteri içeren dizin adları da doğru karşılaştırılır.
  case ":${PATH}:" in *":$1:"*) return 0 ;; esac
  PATH="${PATH:+$PATH:}$1"
}

# ─── PATH: öncelikli ──────────────────────────────────────────────────────
_kb_path_prepend "$HOME/bin"
_kb_path_prepend "$HOME/.local/bin"
# Eskiden ~/.cargo/env'in yaptığı iş. O dosya artık source EDİLMİYOR
# (spec B6: .zshenv ve .profile'da iki kez source ediliyordu).
_kb_path_prepend "$HOME/.cargo/bin"

# ─── PATH: geliştirme araçları ────────────────────────────────────────────
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
# readlink+dirname süreç doğurur; JAVA_HOME zaten varsa atla (idempotentlik).
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

# ─── Editör ve pager ──────────────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export LESS='-R -F -X -i -M'
export MANPAGER='nvim +Man!'

# ─── Gizli değerler ───────────────────────────────────────────────────────
# chezmoi yönetiminde DEĞİL ve öyle kalmalı.
[ -f "$HOME/.profile_secrets" ] && . "$HOME/.profile_secrets"

return 0 2>/dev/null || true
