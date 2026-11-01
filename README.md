# dotfiles

My Hyprland + [Caelestia](https://github.com/caelestia-dots/shell) setup on Arch/Manjaro:
a dark Material You theme, Lua-based Hyprland config, and a small set of matching
terminal/GTK/Qt configs.

## What's here

| Path | What |
| --- | --- |
| `hypr/` | Hyprland config, written in Lua (`hyprland.lua` + modules, keybinds, rules, scheme) |
| `caelestia/` | User overrides for the Caelestia dotfiles (`hypr-vars.lua`, `hypr-user.lua`) |
| `foot/` | Terminal |
| `fish/` | Shell config and functions |
| `btop/`, `htop/` | System monitors, incl. a `caelestia` btop theme |
| `fuzzel/` | Launcher |
| `gtk-3.0/`, `gtk-4.0/` | GTK overrides (`gtk.css`, Thunar tweaks) |
| `qt5ct/`, `Kvantum/` | Qt styling |
| `Thunar/` | File manager, custom actions |
| `autostart/` | XDG autostart entries |
| `cava/`, `fastfetch/`, `lazygit/`, `micro/`, `terminator/` | Small app configs |
| `starship.toml`, `mimeapps.list` | Prompt and default apps |

`nvim` lives in its own repo and is intentionally not included here.

## Requirements

- Hyprland (Lua config support) and `quickshell`
- `caelestia-shell` (provides the `caelestia` CLI and the shell)
- `foot`, `fish`, `starship`, `btop`, `fuzzel`, `thunar`
- `qt5ct` + `qtengine`/Kvantum for Qt apps
- A Nerd Font (e.g. `ttf-jetbrains-mono-nerd`) and `noto-fonts`

## Install

Clone somewhere outside `~/.config`, then copy or symlink what you need:

```sh
git clone https://github.com/Mateus-M-Reis/.config.git ~/dotfiles

# simple copy
rsync -a --exclude .git --exclude README.md --exclude .gitignore ~/dotfiles/ ~/.config/

# or with GNU stow
cd ~/dotfiles && stow -t ~/.config .
```

## Secrets

API keys are kept out of git. Copy the template and fill it in:

```sh
cp ~/.config/hypr/hyprland/env.local.example.lua ~/.config/hypr/hyprland/env.local.lua
$EDITOR ~/.config/hypr/hyprland/env.local.lua
```

`env.local.lua` is gitignored and loaded automatically by `env.lua`.

## Theme

Colours come from Caelestia's Material You scheme generator:

```sh
caelestia scheme set -n caelestia -m dark
caelestia wallpaper -f ~/Pictures/wallpapers/your-wallpaper.jpg
```

---

Personal configs, borrow whatever is useful.
