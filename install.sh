#!/usr/bin/env bash
# RattleNvim installer
#
#   git clone https://github.com/Rattle-Brain/RattleNvim.git
#   cd RattleNvim && ./install.sh
#
# 1. Checks that Neovim 0.12 or newer is installed.
# 2. Backs up an existing ~/.config/nvim to ~/.config/nvim-old-config.tar.gz
#    (never overwrites an older backup: adds a timestamp instead).
# 3. Copies this config into ~/.config/nvim.
# 4. Installs the plugins once, headless, so the first launch is clean.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET="$CONFIG_HOME/nvim"
BACKUP="$CONFIG_HOME/nvim-old-config.tar.gz"
FILES=(init.lua lua after nvim-pack-lock.json)
DID_BACKUP=0

red()    { printf '\033[31m%s\033[0m\n' "$*"; }
green()  { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
die()    { red "✗ $*" >&2; exit 1; }

# --- 1. Neovim version -------------------------------------------------------
command -v nvim >/dev/null 2>&1 || die "Neovim is not installed. Install Neovim 0.12+ first."
version_line="$(nvim --version | head -n1)"            # e.g. "NVIM v0.12.2"
if [[ "$version_line" =~ v([0-9]+)\.([0-9]+) ]]; then
  major="${BASH_REMATCH[1]}"; minor="${BASH_REMATCH[2]}"
else
  die "Could not read the Neovim version from: $version_line"
fi
if (( major == 0 && minor < 12 )); then
  die "Neovim 0.12 or newer is required, found ${version_line#NVIM }. This config uses vim.pack and other 0.12 features."
fi
green "✓ ${version_line}"

# --- Dependencies (git is required, the rest is recommended) -----------------
command -v git >/dev/null 2>&1 || die "git is required (vim.pack uses it to download plugins)."
for dep in tree-sitter:"tree-sitter-cli (compiles treesitter parsers)" \
           rg:"ripgrep (Telescope live grep)" \
           cc:"a C compiler (treesitter parsers)"; do
  bin="${dep%%:*}"; why="${dep#*:}"
  command -v "$bin" >/dev/null 2>&1 || yellow "! Missing $why. Things work without it, but install it for the full experience."
done

# --- 2. Back up the existing config -----------------------------------------
if [[ -e "$TARGET" ]]; then
  if [[ -e "$BACKUP" ]]; then
    BACKUP="$CONFIG_HOME/nvim-old-config-$(date +%Y%m%d-%H%M%S).tar.gz"
    yellow "! A previous backup already exists, keeping it. New backup: $BACKUP"
  fi
  tar -czf "$BACKUP" -C "$CONFIG_HOME" "$(basename "$TARGET")"
  tar -tzf "$BACKUP" >/dev/null || die "Backup at $BACKUP looks broken, nothing was changed."
  green "✓ Backed up $TARGET to $BACKUP"
  DID_BACKUP=1
  rm -rf "$TARGET"
fi

# --- 3. Copy the config -----------------------------------------------------
mkdir -p "$TARGET"
for f in "${FILES[@]}"; do
  [[ -e "$REPO_DIR/$f" ]] || die "Missing $f in $REPO_DIR. Is this the RattleNvim repo?"
  cp -r "$REPO_DIR/$f" "$TARGET/"
done
green "✓ Installed the config into $TARGET"

# --- 4. Install plugins ------------------------------------------------------
echo "Installing plugins (first run only, takes a moment)..."
if nvim --headless "+lua vim.defer_fn(function() vim.cmd('qa') end, 3000)" >/dev/null 2>&1; then
  green "✓ Plugins installed"
else
  yellow "! Plugin pre-install hit a snag. Just open nvim and it will finish on its own."
fi

echo
echo "All done. Open nvim and enjoy."
echo "  • Language servers are enabled automatically if they're installed (see README)."
if (( DID_BACKUP )); then
  echo "  • Your old config: $BACKUP"
  echo "    Restore it with: rm -rf \"$TARGET\" && tar -xzf \"$BACKUP\" -C \"$CONFIG_HOME\""
fi
