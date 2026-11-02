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

### Matte black

The `matte-black` branch pins a fixed neutral scheme instead of following the
wallpaper: `hypr/utils/matte-black.py` feeds `hypr/scheme/matte-black.json`
through Caelestia's templates and saves it as the current scheme, so the bar,
apps and nvim all go black. `caelestia/cli.json` runs it again after every
`caelestia wallpaper` call, which keeps the UI black across wallpaper changes.

```sh
hypr/utils/matte-black.py --reload   # re-apply, including Hyprland borders
```

Back to the wallpaper-derived scheme:

```sh
git switch main
caelestia wallpaper -f "$(caelestia wallpaper)"
```

## Wallpaper schedule

`hypr/utils/wallpaper-daynight.sh` starts from `execs.lua` and changes the
wallpaper when the day/night period changes: the first `cv*` image in
`~/Pictures/wallpapers` from 06:00, `tiger_neon.jpg` from 18:00. It uses
`caelestia wallpaper -f`, so the whole scheme follows — terminals via
`sequences.txt`, and nvim via its watch on `scheme.json`. A manual pick stays
until the next boundary. Override the hours with `DAY_START` / `NIGHT_START`
(24h clock), or run it once with `--once` / `--dry-run`.

## Lock screen on ABNT2

Caelestia's lock screen builds the password from raw key events, so XKB dead
keys (`' " ^ ~`) are dropped before PAM sees them and an accented password can
never unlock. `~/.config/quickshell/caelestia/` is a local copy of the packaged
shell with `modules/lock/center/PasswordInput.qml` patched to type through a
real `TextInput`; `QT_IM_MODULE=compose` in `hypr/hyprland/env.lua` then turns
the dead-key sequence into the composed character (`'` + `a` → `á`).

The local copy shadows `/etc/xdg/quickshell/caelestia` and is 12 MB, so it is
not tracked here. The tracked patch is `caelestia/lock-compose.patch`. After a
`caelestia-shell` update, refresh the copy and re-apply it:

```sh
rm -rf ~/.config/quickshell/caelestia
cp -a /etc/xdg/quickshell/caelestia ~/.config/quickshell/caelestia
patch -d ~/.config/quickshell/caelestia -p1 < ~/.config/caelestia/lock-compose.patch
QT_IM_MODULE=compose caelestia shell -r -d
```

---

Personal configs, borrow whatever is useful.