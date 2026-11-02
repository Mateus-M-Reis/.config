# dotfiles

My Hyprland + [Caelestia](https://github.com/caelestia-dots/shell) setup on Arch/Manjaro:
a day/night Material You theme, Lua-based Hyprland config, and a small set of
matching terminal/GTK/Qt configs.

## What's here

| Path | What |
| --- | --- |
| `hypr/` | Hyprland config, written in Lua (`hyprland.lua` + modules, keybinds, rules, scheme) |
| `caelestia/` | User overrides and shell patches for Caelestia (`hypr-vars.lua`, `hypr-user.lua`, `*.patch`) |
| `foot/` | Terminal |
| `nvim/` | Neovim config (NvChad with the Caelestia colourscheme) |
| `fish/` | Shell config and functions |
| `btop/`, `htop/` | System monitors, incl. a `caelestia` btop theme |
| `fuzzel/` | Launcher |
| `gtk-3.0/`, `gtk-4.0/` | GTK overrides (`gtk.css`, Thunar tweaks) |
| `qt5ct/`, `Kvantum/` | Qt styling |
| `Thunar/` | File manager, custom actions |
| `autostart/` | XDG autostart entries |
| `cava/`, `fastfetch/`, `lazygit/`, `micro/`, `terminator/` | Small app configs |
| `starship.toml`, `mimeapps.list` | Prompt and default apps |

`nvim/` is tracked here too; it used to live in the separate
`Mateus-M-Reis/nvim` repo.

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

`foot` includes a file the wallpaper switcher generates at runtime. Create it
once so the terminal works before the first Hyprland start:

```sh
mkdir -p ~/.config/foot
printf '[main]\ninitial-color-theme=dark\n' > ~/.config/foot/theme-default.ini
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
# Keep the scheme "dynamic": only then does `caelestia wallpaper -f` re-derive
# light/dark from the image, which the wallpaper schedule relies on.
caelestia scheme set -n dynamic -m dark
caelestia wallpaper -f ~/Pictures/wallpapers/your-wallpaper.jpg
```

## Wallpaper schedule

`hypr/utils/wallpaper-daynight.sh` starts from `execs.lua` and changes the
wallpaper four times a day, alternating two light and two dark periods:

| Slot | Time | Wallpaper | Scheme |
| --- | --- | --- | --- |
| morning | 06:00-11:59 | first `cv*` in `~/Pictures/wallpapers` | light |
| afternoon | 12:00-17:59 | `tiger_neon_cropped_red2.jpg` | light |
| evening | 18:00-23:59 | `tiger_neon.jpg` | dark |
| night | 00:00-05:59 | `tiger neon yellow.jpg` | dark |

It uses `caelestia wallpaper -f`, so the whole scheme follows — the bar,
terminals via `sequences.txt`, and nvim via its watch on `scheme.json`. A manual
pick stays until the next boundary. Foot follows the slots too: the script
rewrites `foot/theme-default.ini` for new windows and signals running ones
(`SIGUSR1` dark, `SIGUSR2` light). Override the boundaries with
`MORNING_START` / `AFTERNOON_START` / `EVENING_START` (24h clock), or run it once
with `--once` / `--dry-run`.

## Brightness widget

`SUPER + SHIFT + B` toggles a floating brightness card in the top-right corner
of the focused monitor (equivalently
`caelestia shell brightnessWidget toggle`). Drag the card to move it, drag the
slider or scroll over the card to change the panel brightness. The IPC target
also exposes `open`, `close` and `status`.

This is a local addition to the Caelestia shell, not part of the package:
`caelestia/brightness-widget.patch` adds
`modules/widgets/BrightnessWidget.qml` and registers it in `shell.qml`.

## Lock screen on ABNT2

Caelestia's lock screen builds the password from raw key events, so XKB dead
keys (`' " ^ ~`) are dropped before PAM sees them and an accented password can
never unlock. `~/.config/quickshell/caelestia/` is a local copy of the packaged
shell with `modules/lock/center/PasswordInput.qml` patched to type through a
real `TextInput`; `QT_IM_MODULE=compose` in `hypr/hyprland/env.lua` then turns
the dead-key sequence into the composed character (`'` + `a` → `á`).

The local copy shadows `/etc/xdg/quickshell/caelestia` and is 12 MB, so it is
not tracked here. The changes themselves are kept as patches in
`caelestia/`: `lock-compose.patch` (this section) and
`brightness-widget.patch`. After a `caelestia-shell` update, refresh the copy
and re-apply both:

```sh
rm -rf ~/.config/quickshell/caelestia
cp -a /etc/xdg/quickshell/caelestia ~/.config/quickshell/caelestia
for p in ~/.config/caelestia/*.patch; do
    patch -d ~/.config/quickshell/caelestia -p1 < "$p"
done
QT_IM_MODULE=compose caelestia shell -r -d
```

---

Personal configs, borrow whatever is useful.