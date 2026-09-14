# ~/.config/shell/aliases.sh — yalnızca İNTERAKTİF shell'lerden source edilir.
#
# Buraya alias koy, env.sh'a koyma: .zshenv her zsh çağrısında okunur ve
# zsh script'lerinde alias'lar genişletilir — sızarlarsa script'leri bozar.

# ─── sistem ───────────────────────────────────────────────────────────────
alias upt='sudo apt update'
alias upg='sudo -- sh -c "apt update && apt upgrade"'
alias aptclean='sudo apt autoremove -y'
alias c='clear'
alias e='exit'
alias q='exit'

# ─── güç ──────────────────────────────────────────────────────────────────
alias rb='sudo /sbin/reboot'
alias po='sudo /sbin/poweroff'
# DİKKAT: eskiden 'sd' idi. sd(1) (sed yerine geçen arama-değiştirme aracı)
# bu sistemde kurulu ve alias onu gölgeliyordu. Yeniden adlandırıldı.
alias shutd='sudo /sbin/shutdown'

# ─── gezinme ──────────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../../../'   # not: 3 seviye — mevcut davranış korundu
alias ~='cd ~'

# ─── listeleme ────────────────────────────────────────────────────────────
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza --icons=auto --group-directories-first --long --git'
  alias la='eza --icons=auto --group-directories-first --long --all --git'
  alias lt='eza --icons=auto --group-directories-first --tree --level=2'
  alias ltree='eza --icons=auto --group-directories-first --tree --level=2 --long --no-user --no-permissions --no-filesize'
else
  alias ls='ls --color=auto --group-directories-first'
  alias ll='ls -lh'
  alias la='ls -lah'
  alias lt='ls -R'
  alias ltree='ls -R'
fi

# ─── standart araçlar ─────────────────────────────────────────────────────
alias grep='grep --color=auto'
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -I --preserve-root'

# 'find' ve 'cat' BİLEREK alias'lanmıyor: fd(1) farklı sözdizimi bekler ve
# kopyalanan komutları bozar. Her ikisi de ~/.local/bin altında kendi
# isimleriyle mevcut (fd → fdfind, bat → batcat).

# ─── editör ───────────────────────────────────────────────────────────────
alias vim='nvim'
alias vi='nvim'

# ─── ağ / bilgi ───────────────────────────────────────────────────────────
alias ports='ss -tulanp'          # netstat (net-tools) kullanımdan kalktı
alias myip='curl -s ifconfig.me; echo'

# ─── shell ────────────────────────────────────────────────────────────────
# env.sh sentinel'i ihraç edildiği için 'exec zsh' tek başına ortamı
# yeniden yüklemez; bu alias sentinel'i sıfırlar.
alias reload='unset KB_ENV_LOADED; exec "$SHELL" -l'
