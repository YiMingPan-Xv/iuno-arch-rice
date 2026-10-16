#!/usr/bin/env bash
set -e

echo "Deploying Iuno rice dotfiles..."

# 1. Install core packages
sudo pacman -S --needed --noconfirm git stow kitty ttf-jetbrains-mono-nerd

# 2. Stow configs
cd "$(dirname "$0")"
stow --adopt kitty kde-colors cursors

# 3. Apply KDE theming
if command -v plasma-apply-colorscheme &>/dev/null; then
  plasma-apply-colorscheme MoonlitGold
fi

if command -v kwriteconfig6 &>/dev/null; then
  kwriteconfig6 --file ~/.config/kwinrc --group Windows --key BorderlessMaximizedWindows true
  qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
fi

echo "All done!"
