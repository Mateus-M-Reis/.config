-- User overrides for the Caelestia Hyprland config.
-- Loaded after all of Caelestia's own modules, so values set here win.

-- Brazilian Portuguese keyboard. The default "br" XKB layout is ABNT2,
-- so no variant is required. US is kept as a second layout because the
-- Caelestia lock screen cannot type ABNT2 dead keys ( ' " ^ ~ ); Alt+Shift
-- switches layouts, including on the lock screen.
hl.config({
    input = {
        kb_layout  = "br,us",
        kb_options = "grp:alt_shift_toggle",
    },
})
