# ~/.config/shell/aliases.sh — sourced from INTERACTIVE shells only.
#
# Put aliases here, not in env.sh: .zshenv is read on every zsh invocation
# and zsh expands aliases inside scripts, so leaking them breaks scripts.

# ─── system ───────────────────────────────────────────────────────────────
alias upt='sudo apt update'
alias upg='sudo -- sh -c "apt update && apt upgrade"'
alias aptclean='sudo apt autoremove -y'
alias c='clear'
alias e='exit'
alias q='exit'

# ─── power ──────────────────────────────────────────────────────────────────
alias rb='sudo /sbin/reboot'
alias po='sudo /sbin/poweroff'
# NOTE: this used to be 'sd'. sd(1), the find-and-replace tool that stands in
# for sed, is installed here and the alias was shadowing it, hence the rename.
alias shutd='sudo /sbin/shutdown'

# ─── navigation ──────────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../../../'   # note: three levels, matching the previous behaviour
alias ~='cd ~'

# ─── listing ────────────────────────────────────────────────────────────
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

# ─── standard tools ─────────────────────────────────────────────────────
alias grep='grep --color=auto'
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -I --preserve-root'

# 'find' and 'cat' are DELIBERATELY not aliased: fd(1) expects a different
# syntax and would break commands pasted from elsewhere. Both are available
# under their own names in ~/.local/bin (fd -> fdfind, bat -> batcat).

# ─── editor ───────────────────────────────────────────────────────────────
alias vim='nvim'
alias vi='nvim'

# ─── network / info ───────────────────────────────────────────────────────────
alias ports='ss -tulanp'          # netstat (net-tools) is deprecated
alias myip='curl -s ifconfig.me; echo'

# ─── shell ────────────────────────────────────────────────────────────────
# The env.sh sentinel is exported, so 'exec zsh' alone does not reload the
# environment; this alias clears the sentinel first.
alias reload='unset KB_ENV_LOADED; exec "$SHELL" -l'
