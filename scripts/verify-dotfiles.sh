#!/usr/bin/env bash
# D1–D12 doğrulama harness'i — spec bölüm 6.
#   bash scripts/verify-dotfiles.sh          → hepsi
#   bash scripts/verify-dotfiles.sh D3 D7    → yalnızca seçilenler
#
# timeout kullanım kuralı: her `timeout` çağrısına `-k 3` (kill-after) eklenir
# ki TERM'i yakalayan/yok sayan bir alt süreç 3s sonra kesin KILL alsın; her
# etkileşimli kabuk (`-i`) çağrısına da `</dev/null` eklenir ki kabuk bir uçbirim
# görüp kendi process group'unu değiştirip timeout'un sinyalinden kaçmasın (bu
# kaçış, iç içe kabuk/LSP alt süreçlerinin öksüz kalmasının klasik nedenidir).
# Çıkış kodu 124 = "timeout tarafından öldürüldü"; boş çıktı PASS koşulu olan
# her check'te bu, sessizce yanlış PASS'a dönüşmesin diye ayrıca ele alınır.
set -uo pipefail

PASS=0; FAIL=0; SKIP=0
WANT="${*:-}"

want() { [ -z "$WANT" ] && return 0; case " $WANT " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }
ok()   { printf '\033[32m PASS\033[0m  %-5s %s\n' "$1" "$2"; PASS=$((PASS+1)); }
no()   { printf '\033[31m FAIL\033[0m  %-5s %s\n' "$1" "$2"
         [ -n "${3:-}" ] && printf '              → %s\n' "$3"; FAIL=$((FAIL+1)); }
sk()   { printf '\033[33m SKIP\033[0m  %-5s %s\n' "$1" "$2"; SKIP=$((SKIP+1)); }

# zsh'i verilen TERM_PROGRAM ile 5 kez açıp "ortalama_ms zaman_aşımı_sayısı"
# döndürür (tek satır, boşlukla ayrılmış — çağıran `read` ile ayrıştırır;
# zsh_ms bir command substitution içinde çalıştığından bir global değişkene
# yazmak ana kabuğa geri yansımaz).
zsh_ms() {
  local tp="$1" n=5 t0 t1 i rc hits=0
  t0=$(date +%s%N)
  for ((i=0; i<n; i++)); do
    TERM_PROGRAM="$tp" timeout -k 3 10 zsh -i -c exit </dev/null >/dev/null 2>&1
    rc=$?
    [ "$rc" -eq 124 ] && hits=$((hits+1))
  done
  t1=$(date +%s%N)
  echo "$(( (t1 - t0) / (n * 1000000) )) $hits"
}

echo "── Neovim ──────────────────────────────────────────"

if want D1; then
  out=$(timeout -k 3 15 nvim --headless +qa </dev/null 2>&1); rc=$?
  if [ "$rc" -eq 124 ]; then no D1 "nvim hatasız açılıyor" "zaman aşımı: nvim 15s içinde yanıt vermedi"
  elif [ -z "$out" ]; then ok D1 "nvim hatasız açılıyor"
  else no D1 "nvim hatasız açılıyor" "$(printf '%s' "$out" | head -2 | tr '\n' ' ')"; fi
fi

if want D2; then
  log=$(mktemp)
  timeout -k 3 15 nvim --headless --startuptime "$log" +qa </dev/null >/dev/null 2>&1
  rc=$?
  ms=$(awk '/NVIM STARTED/{print int($1)}' "$log" | tail -1); rm -f "$log"
  if [ "$rc" -eq 124 ]; then no D2 "nvim açılışı" "zaman aşımı: nvim 15s içinde yanıt vermedi"
  elif [ -n "$ms" ] && [ "$ms" -lt 60 ]; then ok D2 "nvim açılışı ${ms}ms"
  else no D2 "nvim açılışı ${ms:-?}ms" "hedef <60ms"; fi
fi

if want D8; then
  f=$(mktemp --suffix=.ts); printf 'const x: number = 1;\n' > "$f"
  n=$(timeout -k 3 15 nvim --headless "$f" -c 'sleep 4' \
      -c 'lua io.write(tostring(#vim.lsp.get_clients()))' -c 'qa!' </dev/null 2>/dev/null)
  rc=$?
  rm -f "$f"
  if [ "$rc" -eq 124 ]; then no D8 "TypeScript LSP bağlanıyor" "zaman aşımı: nvim 15s içinde yanıt vermedi"
  elif [ "${n:-0}" -ge 1 ] 2>/dev/null; then ok D8 "TypeScript LSP bağlanıyor (${n} istemci)"
  else no D8 "TypeScript LSP bağlanıyor" "istemci: ${n:-0} — vtsls mason ile kurulu mu?"; fi
fi

if want D9; then
  f=$(mktemp --suffix=.lua); printf 'local a = 1\n' > "$f"
  r=$(timeout -k 3 15 nvim --headless "$f" \
      -c 'lua io.write(vim.treesitter.get_parser(0) and "ok" or "yok")' -c 'qa!' </dev/null 2>/dev/null)
  rc=$?
  rm -f "$f"
  if [ "$rc" -eq 124 ]; then no D9 "Treesitter lua parser'ı aktif" "zaman aşımı: nvim 15s içinde yanıt vermedi"
  elif [ "$r" = ok ]; then ok D9 "Treesitter lua parser'ı aktif"
  else no D9 "Treesitter lua parser'ı aktif" "sonuç: ${r:-boş}"; fi
fi

if want D10; then
  # nvim-cmp InsertEnter ile lazy-load olur; headless'ta elle yüklemek gerekir.
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
  if [ "$rc" -eq 124 ]; then no D10 "nvim-cmp'te luasnip kaynağı kayıtlı" "zaman aşımı: nvim 15s içinde yanıt vermedi"
  elif [ "${r:-0}" -ge 1 ] 2>/dev/null; then ok D10 "nvim-cmp'te luasnip kaynağı kayıtlı"
  else no D10 "nvim-cmp'te luasnip kaynağı kayıtlı" "bulunan: ${r:-0} — spec B8"; fi
fi

echo "── Shell ───────────────────────────────────────────"

if want D3; then
  read -r m1 h1 <<< "$(zsh_ms "")"
  read -r m2 h2 <<< "$(zsh_ms "WarpTerminal")"
  if [ "$h1" -gt 0 ]; then no D3a "zsh Warp dışı ${m1}ms" "zaman aşımı: ${h1}/5 çalıştırma 10s'de takıldı"
  elif [ "$m1" -lt 110 ]; then ok D3a "zsh Warp dışı ${m1}ms"; else no D3a "zsh Warp dışı ${m1}ms" "hedef <110ms"; fi
  if [ "$h2" -gt 0 ]; then no D3b "zsh Warp içi ${m2}ms" "zaman aşımı: ${h2}/5 çalıştırma 10s'de takıldı"
  elif [ "$m2" -lt 90 ];  then ok D3b "zsh Warp içi ${m2}ms";  else no D3b "zsh Warp içi ${m2}ms"  "hedef <90ms"; fi
fi

if want D4; then
  timeout -k 3 10 bash -lc 'exit' </dev/null >/dev/null 2>&1; rc=$?
  if [ "$rc" -eq 124 ]; then no D4a "bash login temiz" "zaman aşımı: bash -lc 10s içinde bitmedi"
  elif [ "$rc" -eq 0 ]; then ok D4a "bash login temiz"
  else no D4a "bash login temiz" "bash -lc exit sıfırdan farklı döndü ($rc)"; fi

  d=$(timeout -k 3 10 bash -lc 'printf %s "$PATH"' </dev/null 2>/dev/null); rc=$?
  if [ "$rc" -eq 124 ]; then no D4b "bash PATH yinelemesiz" "zaman aşımı: bash -lc 10s içinde bitmedi"
  else
    d=$(printf '%s' "$d" | tr ':' '\n' | sort | uniq -d | tr '\n' ' ')
    if [ -z "$d" ]; then ok D4b "bash PATH yinelemesiz"; else no D4b "bash PATH yinelemesiz" "yinelenen: $d"; fi
  fi
fi

if want D5; then
  d=$(timeout -k 3 10 zsh -ic 'printf %s "$PATH"' </dev/null 2>/dev/null); rc=$?
  if [ "$rc" -eq 124 ]; then no D5a "zsh PATH yinelemesiz" "zaman aşımı: zsh -ic 10s içinde bitmedi"
  else
    d=$(printf '%s' "$d" | tail -1 | tr ':' '\n' | sort | uniq -d | tr '\n' ' ')
    if [ -z "$d" ]; then ok D5a "zsh PATH yinelemesiz"; else no D5a "zsh PATH yinelemesiz" "yinelenen: $d"; fi
  fi

  probe=$(mktemp); printf 'echo ${#PATH}\n' > "$probe"
  l1=$(timeout -k 3 10 zsh -ic ". $probe" </dev/null 2>/dev/null | tail -1); rc1=$?
  l2=$(timeout -k 3 10 zsh -ic "zsh -ic '. $probe'" </dev/null 2>/dev/null | tail -1); rc2=$?
  rm -f "$probe"
  if [ "$rc1" -eq 124 ] || [ "$rc2" -eq 124 ]; then
    no D5b "PATH iç içe shell'de sabit" "zaman aşımı: 1. seviye rc=$rc1, 2. seviye rc=$rc2 (124=zaman aşımı)"
  elif [ -n "$l1" ] && [ "$l1" = "$l2" ]; then ok D5b "PATH iç içe shell'de sabit ($l1)"
  else no D5b "PATH iç içe shell'de büyüyor" "1. seviye ${l1:-?} → 2. seviye ${l2:-?}"; fi
fi

if want D6; then
  # Alias'ın sadece "çalışması" yetmez (plain ls de 0 döner) — eza'ya
  # çözümlendiğini zsh'in kendi alias çözümlemesiyle (which) doğrula.
  for a in ls ll la ltree; do
    res=$(timeout -k 3 10 zsh -ic "which $a" </dev/null 2>/dev/null); rc=$?
    if [ "$rc" -eq 124 ]; then no D6 "$a → eza" "zaman aşımı: zsh -ic 10s içinde bitmedi"
    elif printf '%s' "$res" | grep -qi eza; then ok D6 "$a → eza ($res)"
    else no D6 "$a → eza" "çözümleme: ${res:-boş} — eza içermiyor"; fi
  done
fi

if want D7; then
  out=$(TERM_PROGRAM= timeout -k 3 10 zsh -ic 'bindkey' </dev/null 2>/dev/null); rc=$?
  if [ "$rc" -eq 124 ]; then no D7 "fzf Ctrl-R widget'ı bağlı (Warp dışı)" "zaman aşımı: zsh -ic 10s içinde bitmedi"
  elif printf '%s' "$out" | grep -q 'fzf-history-widget'; then
    ok D7 "fzf Ctrl-R widget'ı bağlı (Warp dışı)"
  else no D7 "fzf Ctrl-R widget'ı bağlı (Warp dışı)" "bindkey çıktısında fzf-history-widget yok"; fi
fi

echo "── vim / chezmoi ───────────────────────────────────"

if want D11; then
  if command -v vim.tiny >/dev/null 2>&1; then
    out=$(timeout -k 3 10 vim.tiny -u "$HOME/.vimrc" -c 'q' </dev/null 2>&1); rc=$?
    if [ "$rc" -eq 124 ]; then no D11 "vim.tiny .vimrc'yi hatasız okuyor" "zaman aşımı: vim.tiny 10s içinde bitmedi"
    else
      errs=$(printf '%s' "$out" | grep -oE 'E[0-9]{2,4}:' | sort -u | tr '\n' ' ')
      if [ -z "$errs" ]; then ok D11 "vim.tiny .vimrc'yi hatasız okuyor"
      else no D11 "vim.tiny .vimrc'yi hatasız okuyor" "$errs"; fi
    fi
  else sk D11 "vim.tiny kurulu değil"; fi
fi

if want D12; then
  out=$(timeout -k 3 15 chezmoi verify </dev/null 2>&1); rc=$?
  if [ "$rc" -eq 124 ]; then no D12a "chezmoi verify temiz" "zaman aşımı: chezmoi verify 15s içinde bitmedi"
  elif [ "$rc" -eq 0 ]; then ok D12a "chezmoi verify temiz"
  else no D12a "chezmoi verify temiz" "$(printf '%s' "$out" | head -3 | tr '\n' ' ')"; fi

  st=$(timeout -k 3 15 chezmoi status </dev/null 2>/dev/null); rc=$?
  if [ "$rc" -eq 124 ]; then no D12b "chezmoi status boş" "zaman aşımı: chezmoi status 15s içinde bitmedi"
  elif [ -z "$st" ]; then ok D12b "chezmoi status boş"
  else no D12b "chezmoi status boş" "$(printf '%s' "$st" | tr '\n' ' ')"; fi
fi

printf '\n  %d geçti, %d kaldı, %d atlandı\n' "$PASS" "$FAIL" "$SKIP"
[ "$FAIL" -eq 0 ]
