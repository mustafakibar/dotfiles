# dotfiles

zsh, bash, Neovim and vim configuration, managed with [chezmoi](https://www.chezmoi.io).

Source directory: `~/.local/share/chezmoi` · Target: `$HOME`

---

## Install on a fresh machine

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply mustafakibar
~/.local/share/chezmoi/scripts/bootstrap-tools.sh
exec zsh -l
```

chezmoi manages **config files**, not the **binaries** they depend on —
oh-my-zsh, eza, starship and friends. `bootstrap-tools.sh` closes that gap:
it installs what can go in user space and only prints the commands for the
steps that need `sudo`. It is idempotent, so running it twice is safe.

It is deliberately not named `run_once_`: it should not reach out to the
network on its own during `chezmoi apply`.

### External dependencies

| Tool | Why | Install |
|---|---|---|
| `zsh`, `git` | baseline | apt |
| `oh-my-zsh` + 3 plugins | prompt, completion, highlighting | bootstrap |
| `starship` | prompt | bootstrap (`~/.local/bin`) |
| `eza` | the `ls`/`ll`/`la`/`ltree` aliases | apt |
| `fzf` | Ctrl-R / Ctrl-T widgets (outside Warp) | apt |
| `zoxide` | `z` | apt |
| `fnm` | Node version management | bootstrap |
| `ripgrep`, `fd-find`, `bat` | fzf-lua, grep and find work | apt |
| `tree-sitter` CLI **>= 0.26.1** | builds nvim-treesitter `main` parsers | `cargo install tree-sitter-cli --locked` |
| `build-essential` | parser and LSP builds | apt |
| Go toolchain | `gopls` (optional) | manual |

None of these are required to **start** a shell or nvim; a missing tool only
disables the feature that needs it. Rather than failing silently, `.zshrc`
prints a single line when oh-my-zsh is absent.

---

## Verification

```sh
bash ~/.local/share/chezmoi/scripts/verify-dotfiles.sh
```

Nineteen checks: nvim startup time and cleanliness, LSP attachment,
treesitter, zsh startup time inside and outside Warp, PATH staying free of
duplicates, aliases resolving to eza, the fzf widget, `vim.tiny`
compatibility, and a clean `chezmoi verify`/`status`.

---

## Design notes

### PATH has a single owner

`~/.config/shell/env.sh` is **the only place that writes PATH**. `.zshenv`,
`.profile` and `.bashrc` load it once behind the `KB_ENV_LOADED` sentinel, so
PATH does not grow in nested shells.

`_kb_path_prepend` tests membership with a `case` pattern. zsh does **not**
word-split quoted expansions, so a `for`/`IFS` loop breaks here silently.

**One exception:** `mason.nvim` prepends its own `bin` directory to
`vim.env.PATH`. That applies inside the nvim process only and never leaks
into the shell.

### Warp Terminal split

Warp officially documents `zsh-autosuggestions`, `fzf` and `compinit` as
incompatible. `.zshrc` tests:

```zsh
$TERM_PROGRAM == WarpTerminal && -z $NVIM && -z $TMUX && -z $SSH_CONNECTION
```

When true those plugins are skipped (startup ~89 ms); otherwise the full
stack loads (~108 ms). Starship runs either way.

### Alias ordering

`aliases.sh` is sourced **after** `oh-my-zsh.sh`. The other way round, the
oh-my-zsh `git` and `common-aliases` plugins quietly overwrite `ls`, `ll`
and `la`.

### Two-layer vim

Layer one of `.vimrc` holds only plain `set` and `*noremap` commands and runs
cleanly under `vim.tiny` (`-eval -syntax`). Everything else lives inside an
`if 1 ... endif` block.

### Neovim

- Native LSP API from Neovim **0.11+**: `vim.lsp.config()` and
  `vim.lsp.enable()`. `require('lspconfig').X.setup{}` is not used.
- `nvim-treesitter` on the **`main`** branch: no `ensure_installed`, no
  automatic highlight, no lazy-loading. Installation is programmatic and
  highlighting is started from a `FileType` autocmd. `indentexpr` is only
  overridden when a parser starts **and** the language ships an `indents`
  query; otherwise Vim's built-in indent (cindent, `GetVimIndent()`, …) is
  left alone.
- `gopls` is deliberately absent from `ensure_installed`: mason cannot build
  it without a Go toolchain. Once Go is installed, `:MasonInstall gopls`.

### lazy-lock.json

The file is managed by chezmoi, so `:Lazy update` writes the **target** and
dirties `chezmoi status`. After updating:

```sh
chezmoi re-add ~/.config/nvim/lazy-lock.json
```

---

## In the repo but not copied to `$HOME`

`.chezmoiignore` excludes `scripts/` and `README.md`.

## Secrets

`~/.profile_secrets` is **not managed by chezmoi** and is not in this repo.
`env.sh` sources it when present. It should be mode `0600`.
