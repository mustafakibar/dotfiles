#!/usr/bin/env bash
# Verification harness for the dotfiles.
#   bash scripts/verify-dotfiles.sh          -> everything
#   bash scripts/verify-dotfiles.sh D3 D7    -> selected checks only
#
# timeout convention: every `timeout` call gets `-k 3` (kill-after), so a child
# that catches or ignores TERM is definitely KILLed three seconds later. Every
# interactive shell (`-i`) call gets `</dev/null`, so the shell does not see a
# terminal, move itself into its own process group and escape timeout's signal —
# that escape is the classic reason nested shell and LSP children are orphaned.
# Exit code 124 means "killed by timeout"; it is handled separately in every
# check whose PASS condition is empty output, so it cannot turn into a false PASS.
set -uo pipefail

PASS=0; FAIL=0; SKIP=0
WANT="${*:-}"

want() { [ -z "$WANT" ] && return 0; case " $WANT " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }
ok()   { printf '\033[32m PASS\033[0m  %-5s %s\n' "$1" "$2"; PASS=$((PASS+1)); }
no()   { printf '\033[31m FAIL\033[0m  %-5s %s\n' "$1" "$2"
         [ -n "${3:-}" ] && printf '              → %s\n' "$3"; FAIL=$((FAIL+1)); }
sk()   { printf '\033[33m SKIP\033[0m  %-5s %s\n' "$1" "$2"; SKIP=$((SKIP+1)); }

# Starts zsh with the given TERM_PROGRAM for 3 warm-up plus 15 measured runs
# and returns "average_ms timeout_count" on a single space-separated line; the
# caller parses it with `read`. zsh_ms runs inside a command substitution, so
# writing to a global would not reach the parent shell.
zsh_ms() {
  local tp="$1" out rc

  # The WHOLE measurement runs under one timeout budget: 90s for 18 runs.
  # Each iteration is deliberately not wrapped on its own: under 'timeout',
  # 'zsh -i' measures about 2x slow (204ms instead of 107ms), because plugins
  # that fork a background worker (zsh-autosuggestions async) keep the pipe
  # timeout waits on open. '--foreground' does not change this; it was tried.
  #
  # The timing brackets sit INSIDE the subshell, so that wait happens after t1
  # and never enters the measurement; a stall in any iteration still exhausts
  # the budget and fails the check.
  out=$(timeout -k 5 90 bash -c '
    tp="$1"; warm=3; n=15
    for ((i=0; i<warm; i++)); do TERM_PROGRAM="$tp" zsh -i -c exit </dev/null >/dev/null 2>&1; done
    t0=$(date +%s%N)
    for ((i=0; i<n; i++)); do TERM_PROGRAM="$tp" zsh -i -c exit </dev/null >/dev/null 2>&1; done
    t1=$(date +%s%N)
    echo $(( (t1 - t0) / (n * 1000000) ))
  ' _ "$tp" 2>/dev/null)
  rc=$?

  if [ "$rc" -eq 124 ] || [ -z "$out" ]; then echo "-1 1"; else echo "$out 0"; fi
}

echo "── Neovim ──────────────────────────────────────────"

if want D1; then
  out=$(timeout -k 3 15 nvim --headless +qa </dev/null 2>&1); rc=$?
  if [ "$rc" -eq 124 ]; then no D1 "nvim starts without errors" "timeout: nvim did not respond within 15s"
  elif [ -z "$out" ]; then ok D1 "nvim starts without errors"
  else no D1 "nvim starts without errors" "$(printf '%s' "$out" | head -2 | tr '\n' ' ')"; fi
fi

if want D2; then
  log=$(mktemp)
  timeout -k 3 15 nvim --headless --startuptime "$log" +qa </dev/null >/dev/null 2>&1
  rc=$?
  ms=$(awk '/NVIM STARTED/{print int($1)}' "$log" | tail -1); rm -f "$log"
  if [ "$rc" -eq 124 ]; then no D2 "nvim startup" "timeout: nvim did not respond within 15s"
  elif [ -n "$ms" ] && [ "$ms" -lt 60 ]; then ok D2 "nvim startup ${ms}ms"
  else no D2 "nvim startup ${ms:-?}ms" "target <60ms"; fi
fi

if want D8; then
  f=$(mktemp --suffix=.ts); printf 'const x: number = 1;\n' > "$f"
  n=$(timeout -k 3 15 nvim --headless "$f" -c 'sleep 4' \
      -c 'lua io.write(tostring(#vim.lsp.get_clients()))' -c 'qa!' </dev/null 2>/dev/null)
  rc=$?
  rm -f "$f"
  if [ "$rc" -eq 124 ]; then no D8 "TypeScript LSP attaches" "timeout: nvim did not respond within 15s"
  elif [ "${n:-0}" -ge 1 ] 2>/dev/null; then ok D8 "TypeScript LSP attaches (${n} client(s))"
  else no D8 "TypeScript LSP attaches" "clients: ${n:-0} — is vtsls installed via mason?"; fi
fi

if want D9; then
  f=$(mktemp --suffix=.lua); printf 'local a = 1\n' > "$f"
  r=$(timeout -k 3 15 nvim --headless "$f" \
      -c 'lua io.write(vim.treesitter.get_parser(0) and "ok" or "missing")' -c 'qa!' </dev/null 2>/dev/null)
  rc=$?
  rm -f "$f"
  if [ "$rc" -eq 124 ]; then no D9 "Treesitter lua parser is active" "timeout: nvim did not respond within 15s"
  elif [ "$r" = ok ]; then ok D9 "Treesitter lua parser is active"
  else no D9 "Treesitter lua parser is active" "result: ${r:-empty}"; fi
fi

if want D10; then
  # nvim-cmp lazy-loads on InsertEnter, so it has to be loaded by hand headless.
  r=$(timeout -k 3 15 nvim --headless -c 'Lazy! load nvim-cmp' -c 'lua
    local ok, cmp = pcall(require, "cmp")
    local found = 0
    if ok then
      for _, s in ipairs(cmp.get_config().sources or {}) do
        if type(s) == "table" then
          if s.name == "luasnip" then found = found + 1 end
          for _, e in ipairs(s) do
            if type(e) == "table" and e.name == "luasnip" then found = found + 1 end
          end
        end
      end
    end
    io.write(tostring(found))' -c 'qa!' </dev/null 2>/dev/null)
  rc=$?
  if [ "$rc" -eq 124 ]; then no D10 "luasnip source registered in nvim-cmp" "timeout: nvim did not respond within 15s"
  elif [ "${r:-0}" -ge 1 ] 2>/dev/null; then ok D10 "luasnip source registered in nvim-cmp"
  else no D10 "luasnip source registered in nvim-cmp" "found: ${r:-0}"; fi
fi

echo "── Shell ───────────────────────────────────────────"

if want D3; then
  # Thresholds are calibrated against measured reality with ~20% headroom:
  # the old config measured 147ms; the new one 109-110ms outside Warp and
  # 89-90ms inside it. A threshold with no headroom flaps on every run and
  # makes the check useless.
  read -r m1 h1 <<< "$(zsh_ms "")"
  read -r m2 h2 <<< "$(zsh_ms "WarpTerminal")"
  if [ "$h1" -gt 0 ]; then no D3a "zsh outside Warp ${m1}ms" "timeout: zsh did not start within 15s"
  elif [ "$m1" -lt 130 ]; then ok D3a "zsh outside Warp ${m1}ms"; else no D3a "zsh outside Warp ${m1}ms" "target <130ms"; fi
  if [ "$h2" -gt 0 ]; then no D3b "zsh inside Warp ${m2}ms" "timeout: zsh did not start within 15s"
  elif [ "$m2" -lt 110 ];  then ok D3b "zsh inside Warp ${m2}ms";  else no D3b "zsh inside Warp ${m2}ms"  "target <110ms"; fi
fi

if want D4; then
  timeout -k 3 10 bash -lc 'exit' </dev/null >/dev/null 2>&1; rc=$?
  if [ "$rc" -eq 124 ]; then no D4a "bash login is clean" "timeout: bash -lc did not finish within 10s"
  elif [ "$rc" -eq 0 ]; then ok D4a "bash login is clean"
  else no D4a "bash login is clean" "bash -lc exit returned non-zero ($rc)"; fi

  d=$(timeout -k 3 10 bash -lc 'printf %s "$PATH"' </dev/null 2>/dev/null); rc=$?
  if [ "$rc" -eq 124 ]; then no D4b "bash PATH has no duplicates" "timeout: bash -lc did not finish within 10s"
  else
    d=$(printf '%s' "$d" | tr ':' '\n' | sort | uniq -d | tr '\n' ' ')
    if [ -z "$d" ]; then ok D4b "bash PATH has no duplicates"; else no D4b "bash PATH has no duplicates" "duplicates: $d"; fi
  fi
fi

if want D5; then
  d=$(timeout -k 3 10 zsh -ic 'printf %s "$PATH"' </dev/null 2>/dev/null); rc=$?
  if [ "$rc" -eq 124 ]; then no D5a "zsh PATH has no duplicates" "timeout: zsh -ic did not finish within 10s"
  else
    d=$(printf '%s' "$d" | tail -1 | tr ':' '\n' | sort | uniq -d | tr '\n' ' ')
    if [ -z "$d" ]; then ok D5a "zsh PATH has no duplicates"; else no D5a "zsh PATH has no duplicates" "duplicates: $d"; fi
  fi

  probe=$(mktemp); printf 'printf %%s "$PATH"' > "$probe"
  l1=$(timeout -k 3 10 zsh -ic ". $probe" </dev/null 2>/dev/null); rc1=$?
  l2=$(timeout -k 3 10 zsh -ic "zsh -ic '. $probe'" </dev/null 2>/dev/null); rc2=$?
  rm -f "$probe"

  if [ "$rc1" -eq 124 ] || [ "$rc2" -eq 124 ]; then
    no D5b "PATH is stable in nested shells" "timeout: level 1 rc=$rc1, level 2 rc=$rc2 (124=timeout)"
  else
    # Filter out fnm multishell paths (*/fnm_multishells/*/bin) from both levels
    l1_filtered=$(printf '%s' "$l1" | tr ':' '\n' | grep -v '/fnm_multishells/' | sort)
    l2_filtered=$(printf '%s' "$l2" | tr ':' '\n' | grep -v '/fnm_multishells/' | sort)

    if [ "$l1_filtered" = "$l2_filtered" ]; then
      ok D5b "PATH is stable in nested shells"
    else
      # Find components in l2 that are not in l1
      extra=$(comm -13 <(printf '%s' "$l1_filtered") <(printf '%s' "$l2_filtered") | tr '\n' ' ')
      no D5b "PATH grows in nested shells" "extra: $extra"
    fi
  fi
fi

if want D6; then
  # It is not enough that the alias "works": plain ls also exits 0. Confirm it
  # resolves to eza using zsh's own alias resolution (which).
  for a in ls ll la ltree; do
    res=$(timeout -k 3 10 zsh -ic "which $a" </dev/null 2>/dev/null); rc=$?
    if [ "$rc" -eq 124 ]; then no D6 "$a → eza" "timeout: zsh -ic did not finish within 10s"
    elif printf '%s' "$res" | grep -qi eza; then ok D6 "$a → eza ($res)"
    else no D6 "$a → eza" "resolves to: ${res:-empty} — does not mention eza"; fi
  done
fi

if want D7; then
  out=$(TERM_PROGRAM= timeout -k 3 10 zsh -ic 'bindkey' </dev/null 2>/dev/null); rc=$?
  if [ "$rc" -eq 124 ]; then no D7 "fzf Ctrl-R widget is bound (outside Warp)" "timeout: zsh -ic did not finish within 10s"
  elif printf '%s' "$out" | grep -q 'fzf-history-widget'; then
    ok D7 "fzf Ctrl-R widget is bound (outside Warp)"
  else no D7 "fzf Ctrl-R widget is bound (outside Warp)" "fzf-history-widget missing from bindkey output"; fi
fi

echo "── vim / chezmoi ───────────────────────────────────"

if want D11; then
  if command -v vim.tiny >/dev/null 2>&1; then
    out=$(timeout -k 3 10 vim.tiny -u "$HOME/.vimrc" -c 'q' </dev/null 2>&1); rc=$?
    if [ "$rc" -eq 124 ]; then no D11 "vim.tiny reads .vimrc without errors" "timeout: vim.tiny did not finish within 10s"
    else
      errs=$(printf '%s' "$out" | grep -oE 'E[0-9]{2,4}:' | sort -u | tr '\n' ' ')
      if [ -z "$errs" ]; then ok D11 "vim.tiny reads .vimrc without errors"
      else no D11 "vim.tiny reads .vimrc without errors" "$errs"; fi
    fi
  else sk D11 "vim.tiny is not installed"; fi
fi

if want D12; then
  out=$(timeout -k 3 15 chezmoi verify </dev/null 2>&1); rc=$?
  if [ "$rc" -eq 124 ]; then no D12a "chezmoi verify is clean" "timeout: chezmoi verify did not finish within 15s"
  elif [ "$rc" -eq 0 ]; then ok D12a "chezmoi verify is clean"
  else no D12a "chezmoi verify is clean" "$(printf '%s' "$out" | head -3 | tr '\n' ' ')"; fi

  st=$(timeout -k 3 15 chezmoi status </dev/null 2>/dev/null); rc=$?
  if [ "$rc" -eq 124 ]; then no D12b "chezmoi status is empty" "timeout: chezmoi status did not finish within 15s"
  elif [ -z "$st" ]; then ok D12b "chezmoi status is empty"
  else no D12b "chezmoi status is empty" "$(printf '%s' "$st" | tr '\n' ' ')"; fi
fi

printf '\n  %d passed, %d failed, %d skipped\n' "$PASS" "$FAIL" "$SKIP"
[ "$FAIL" -eq 0 ]
