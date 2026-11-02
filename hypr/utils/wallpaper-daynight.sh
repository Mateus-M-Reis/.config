#!/bin/sh
# Day/night wallpaper switcher.
#
# Day   (06:00-17:59): the first wallpaper in ~/Pictures/wallpapers whose name
#                      starts with "cv" (case-sensitive glob cv*).
# Night (18:00-05:59): ~/Pictures/wallpapers/tiger_neon.jpg
#
# Switching goes through `caelestia wallpaper -f`, so the whole scheme is
# regenerated with it: scheme.json, sequences.txt (terminals), the Caelestia
# templates and the Hyprland scheme. Terminals pick the new palette up live via
# OSC sequences; nvim watches scheme.json and re-applies colors/caelestia.lua.
#
# Foot is kept in step too: light colours with a white background by day, dark
# colours with a black background at night. New windows read the generated
# include file; running ones are switched with SIGUSR2/SIGUSR1.
#
# The wallpaper is only changed when the day/night period changes, so a manual
# pick stays put until the next boundary. State lives in
# ~/.local/state/caelestia/wallpaper-daynight.{period,log}.
#
# Started once per Hyprland session from hyprland/execs.lua; the lock keeps a
# config reload from spawning a second copy.
#
# Usage: wallpaper-daynight.sh [--once] [--dry-run]

set -u

DAY_START=${DAY_START:-6}    # 24h clock, inclusive
NIGHT_START=${NIGHT_START:-18} # 24h clock, exclusive
WALL_DIR=${WALL_DIR:-"$HOME/Pictures/wallpapers"}
DAY_GLOB=${DAY_GLOB:-cv*}    # first match wins
NIGHT_WALL=${NIGHT_WALL:-$WALL_DIR/tiger_neon.jpg}

STATE_DIR=${XDG_STATE_HOME:-$HOME/.local/state}/caelestia
PERIOD_FILE=$STATE_DIR/wallpaper-daynight.period
FOOT_STATE=$STATE_DIR/foot-theme
FOOT_INIT=$HOME/.config/foot/theme-default.ini
LOG_FILE=$STATE_DIR/wallpaper-daynight.log
LOCK_DIR=${XDG_RUNTIME_DIR:-/tmp}/wallpaper-daynight.lock

ONCE=0
DRY=0
FORCE_FOOT=1   # always sync foot once when the script (re)starts
for arg in "$@"; do
    case $arg in
        --once) ONCE=1 ;;
        --dry-run) DRY=1 ;;
        *) echo "usage: $0 [--once] [--dry-run]" >&2; exit 2 ;;
    esac
done

log() {
    [ "$DRY" = 1 ] && return 0
    mkdir -p "$STATE_DIR" 2>/dev/null || true
    printf '%s %s\n' "$(date -Is)" "$*" >>"$LOG_FILE" 2>/dev/null || true
}

# Foot has both palettes in one config; SIGUSR2 selects the light one, SIGUSR1
# the dark one. The signals also work on foot --server and footclient.
foot_theme() {
    case $1 in
        day)   ft=light; fsig=USR2 ;;
        night) ft=dark;  fsig=USR1 ;;
        *) return 0 ;;
    esac

    if [ "$DRY" = 1 ]; then
        printf 'foot-theme=%s\n' "$ft"
        return 0
    fi

    # New foot processes read this; running ones get the signal below.
    mkdir -p "${FOOT_INIT%/*}" 2>/dev/null || true
    printf '[main]\ninitial-color-theme=%s\n' "$ft" >"$FOOT_INIT.tmp" 2>/dev/null &&
        mv -f "$FOOT_INIT.tmp" "$FOOT_INIT" 2>/dev/null

    pkill -"$fsig" -x foot 2>/dev/null || true
    pkill -"$fsig" -x footclient 2>/dev/null || true

    mkdir -p "$STATE_DIR" 2>/dev/null || true
    printf '%s\n' "$1" >"$FOOT_STATE" 2>/dev/null || true
    log "foot theme=$ft"
}

day_wall() {
    for f in "$WALL_DIR"/$DAY_GLOB; do
        [ -f "$f" ] && { printf '%s\n' "$f"; return 0; }
    done
    return 1
}

period() {
    h=$(date +%H)
    h=${h#0}                  # avoid octal-ish "08" in tests
    [ -z "$h" ] && h=0
    if [ "$h" -ge "$DAY_START" ] && [ "$h" -lt "$NIGHT_START" ]; then
        echo day
    else
        echo night
    fi
}

wall_for() {
    if [ "$1" = day ]; then
        day_wall
    else
        [ -f "$NIGHT_WALL" ] && printf '%s\n' "$NIGHT_WALL"
    fi
}

check() {
    p=$(period)
    prev=$(cat "$PERIOD_FILE" 2>/dev/null || true)
    changed=0
    [ "$p" != "$prev" ] && changed=1

    # Foot is independent of the wallpaper: sync it on start and on a period
    # change, so a manual theme toggle survives until the next boundary.
    fprev=$(cat "$FOOT_STATE" 2>/dev/null || true)
    if [ "$FORCE_FOOT" = 1 ] || [ "$p" != "$fprev" ]; then
        foot_theme "$p"
        FORCE_FOOT=0
    fi

    if ! w=$(wall_for "$p"); then
        log "no wallpaper found for period $p"
        return 0
    fi

    if [ "$DRY" = 1 ]; then
        printf 'period=%s\nwallpaper=%s\n' "$p" "$w"
        return 0
    fi

    [ "$changed" = 1 ] || return 0

    if caelestia wallpaper -f "$w" >>"$LOG_FILE" 2>&1; then
        mkdir -p "$STATE_DIR" 2>/dev/null || true
        printf '%s\n' "$p" >"$PERIOD_FILE" 2>/dev/null || true
        log "period=$p set $w"
    else
        log "period=$p failed to set $w"
    fi
}

if [ "$ONCE" = 1 ] || [ "$DRY" = 1 ]; then
    check
    exit 0
fi

# One instance per session
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    if [ -f "$LOCK_DIR/pid" ] && kill -0 "$(cat "$LOCK_DIR/pid")" 2>/dev/null; then
        exit 0
    fi
    rm -rf "$LOCK_DIR"
    mkdir "$LOCK_DIR" 2>/dev/null || exit 1
fi
printf '%s\n' $$ >"$LOCK_DIR/pid" 2>/dev/null
trap 'rm -rf "$LOCK_DIR"' EXIT INT TERM HUP

# Keep the log from growing forever
if [ -f "$LOG_FILE" ] && [ "$(wc -c <"$LOG_FILE" 2>/dev/null || echo 0)" -gt 131072 ]; then
    mv -f "$LOG_FILE" "$LOG_FILE.1" 2>/dev/null || true
fi

while :; do
    check
    sleep 60
done
