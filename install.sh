#!/bin/bash
set -e

WAYBAR_THEME_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "→ Linking waybar config..."
mkdir -p "$HOME/.config"
ln -sfn "$WAYBAR_THEME_DIR" "$HOME/.config/waybar"

echo "→ Setting default theme (catppuccin-mocha)..."
cp "$WAYBAR_THEME_DIR/themes/catppuccin-mocha.css" "$WAYBAR_THEME_DIR/theme.css"

echo "Done. Restart waybar to apply."
echo "  pkill waybar && waybar &"
