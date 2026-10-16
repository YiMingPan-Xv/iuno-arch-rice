#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_PATH="$DOTFILES_DIR/wallpapers/iuno-moon.png"

echo "Deploying Iuno rice dotfiles..."

# 1. Install core packages
sudo pacman -S --needed --noconfirm git stow kitty ttf-jetbrains-mono-nerd

# 2. Stow configs
cd "$DOTFILES_DIR"
stow --adopt kitty kde-colors cursors

# 3. Apply KDE theming
if command -v plasma-apply-colorscheme &>/dev/null; then
  echo "Applying color scheme..."
  plasma-apply-colorscheme IunoColor
fi

if command -v plasma-apply-cursortheme &>/dev/null; then
  echo "Applying cursor theme..."
  plasma-apply-cursortheme IunoTheme
fi

if command -v kwriteconfig6 &>/dev/null; then
  kwriteconfig6 --file ~/.config/kwinrc --group Windows --key BorderlessMaximizedWindows true
  qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
fi

# 4. Set Wallpaper
if [ -f "$WALLPAPER_PATH" ]; then
  echo "Setting wallpaper from $WALLPAPER_PATH..."
  if command -v plasma-apply-wallpaperimage &>/dev/null; then
    plasma-apply-wallpaperimage "$WALLPAPER_PATH"
  else
    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
            var allDesktops = desktops();
            for (var i = 0; i < allDesktops.length; i++) {
                var d = allDesktops[i];
                d.wallpaperPlugin = 'org.kde.image';
                d.currentConfigGroup = ['Wallpaper', 'org.kde.image', 'General'];
                d.writeConfig('Image', 'file://$WALLPAPER_PATH');
            }
        " || true
  fi
fi

echo "All done!"
