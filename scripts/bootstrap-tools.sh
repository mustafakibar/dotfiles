#!/usr/bin/env bash
# Temiz bir makinede bu dotfiles'ın ihtiyaç duyduğu HARİCİ araçları kurar.
#
# chezmoi yalnızca config DOSYALARINI yönetir; oh-my-zsh, eza, starship gibi
# ikilileri değil. Bu script o boşluğu kapatır.
#
# Tasarım kararları:
#   * `run_once_` ön eki YOK: `chezmoi apply` sırasında kendiliğinden
#     çalışmasını istemiyoruz. Elle çağrılır.
#   * Idempotent: kurulu olanı atlar, iki kez çalıştırmak güvenlidir.
#   * sudo GEREKTİREN adımları KENDİ BAŞINA yapmaz, sadece komutu yazdırır.
#
# Kullanım: ~/.local/share/chezmoi/scripts/bootstrap-tools.sh
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
  ok "oh-my-zsh kurulu"
else
  run "oh-my-zsh klonlanıyor"
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR" \
    || warn "oh-my-zsh klonlanamadı"
fi

echo "── zsh eklentileri ───────────────────────────────────────────────────"
clone_plugin() {
  local name="$1" url="$2" dest="$ZSH_CUSTOM/plugins/$1"
  if [ -d "$dest/.git" ]; then
    ok "$name"
  else
    run "$name klonlanıyor"
    git clone --depth=1 "$url" "$dest" || warn "$name klonlanamadı"
  fi
}
mkdir -p "$ZSH_CUSTOM/plugins"
clone_plugin zsh-autosuggestions      https://github.com/zsh-users/zsh-autosuggestions.git
clone_plugin zsh-completions          https://github.com/zsh-users/zsh-completions.git
clone_plugin zsh-syntax-highlighting  https://github.com/zsh-users/zsh-syntax-highlighting.git

echo "── ~/.local/bin sembolik bağları ─────────────────────────────────────"
mkdir -p "$LOCAL_BIN"
# Debian/Ubuntu bu ikilileri fdfind/batcat adıyla paketler.
for pair in "fd:fdfind" "bat:batcat"; do
  want="${pair%%:*}" have="${pair##*:}"
  if command -v "$want" >/dev/null 2>&1; then
    ok "$want"
  elif command -v "$have" >/dev/null 2>&1; then
    run "$LOCAL_BIN/$want -> $(command -v "$have")"
    ln -sf "$(command -v "$have")" "$LOCAL_BIN/$want"
  else
    warn "$want ve $have yok (aşağıdaki apt listesine bakın)"
  fi
done

echo "── kullanıcı alanı kurulumları ───────────────────────────────────────"
if command -v starship >/dev/null 2>&1; then
  ok "starship"
else
  run "starship kuruluyor ($LOCAL_BIN)"
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$LOCAL_BIN" \
    || warn "starship kurulamadı"
fi

if command -v fnm >/dev/null 2>&1; then
  ok "fnm"
else
  run "fnm kuruluyor"
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell \
    || warn "fnm kurulamadı"
fi

echo "── tree-sitter CLI ───────────────────────────────────────────────────"
# nvim-treesitter 'main' branch parser derlemek için >= 0.26.1 ister.
TS_MIN="0.26.1"
ts_ver="$(tree-sitter --version 2>/dev/null | awk '{print $2}')"
if [ -n "$ts_ver" ] && [ "$(printf '%s\n%s\n' "$TS_MIN" "$ts_ver" | sort -V | head -1)" = "$TS_MIN" ]; then
  ok "tree-sitter $ts_ver (>= $TS_MIN)"
elif command -v cargo >/dev/null 2>&1; then
  run "tree-sitter-cli derleniyor (birkaç dakika sürebilir)"
  cargo install tree-sitter-cli --locked || warn "tree-sitter-cli kurulamadı"
else
  warn "tree-sitter ${ts_ver:-yok} — gereken >= $TS_MIN, ama cargo da yok."
  warn "  rustup kurun: https://rustup.rs  sonra: cargo install tree-sitter-cli --locked"
fi

echo "── sistem paketleri ──────────────────────────────────────────────────"
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
  ok "hepsi kurulu"
else
  warn "eksik: ${APT_MISSING[*]}"
  warn "  sudo apt update && sudo apt install -y ${APT_MISSING[*]}"
fi

echo
echo "Bitti. Yeni bir shell açın:  exec zsh -l"
