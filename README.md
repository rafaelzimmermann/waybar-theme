# waybar-theme

Waybar configuration with a clean theme layer. Currently ships **Catppuccin Mocha** by default.

## Preview

<!-- Add screenshot here -->

## Structure

```
waybar-theme/
├── assets/                    # screenshots, wallpapers, icons
├── themes/
│   └── catppuccin-mocha.css   # Catppuccin Mocha palette (@define-color vars)
├── styles/
│   ├── base.css               # font stack + window#waybar rules
│   ├── workspaces.css         # workspace button states
│   └── modules.css            # per-module colors (#clock, #network, etc.)
├── modules/                   # one JSONC file per waybar module
│   ├── hyprland-workspaces.jsonc
│   ├── hyprland-window.jsonc
│   ├── clock.jsonc
│   ├── temperature.jsonc
│   ├── custom-gpu-temp.jsonc
│   ├── wireplumber.jsonc
│   ├── network.jsonc
│   ├── bluetooth.jsonc
│   └── tray.jsonc
├── scripts/
│   └── gpu-temp.sh            # NVIDIA GPU temperature (JSON output for waybar)
├── hyprland/                  # placeholder for future hyprland configs
├── config.jsonc               # bar-level settings + include module files
├── style.css                  # @import theme.css + styles/*.css
├── theme.css                  # active theme (copy from themes/ on install)
├── install.sh
└── README.md
```

## Installation

```bash
./install.sh
```

Symlinks this directory to `~/.config/waybar` and copies
`themes/catppuccin-mocha.css` as the active `theme.css`.

## Switching themes

```bash
cp themes/<name>.css theme.css
pkill -SIGUSR2 waybar   # hot-reload styles without restart
```

## Adding a new theme

1. Create `themes/<name>.css` with the same `@define-color` variable names:

```css
@define-color base      #...;
@define-color mantle    #...;
@define-color crust     #...;
@define-color surface0  #...;
@define-color surface1  #...;
@define-color surface2  #...;
@define-color overlay0  #...;
@define-color overlay1  #...;
@define-color overlay2  #...;
@define-color subtext0  #...;
@define-color subtext1  #...;
@define-color text      #...;
@define-color lavender  #...;
@define-color blue      #...;
@define-color sapphire  #...;
@define-color sky       #...;
@define-color teal      #...;
@define-color green     #...;
@define-color yellow    #...;
@define-color peach     #...;
@define-color maroon    #...;
@define-color red       #...;
@define-color mauve     #...;
@define-color pink      #...;
@define-color flamingo  #...;
@define-color rosewater #...;
```

2. Activate: `cp themes/<name>.css theme.css && pkill -SIGUSR2 waybar`
