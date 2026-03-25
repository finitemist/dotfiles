# ~/.config/fish/config.fish

# ── Greeting ──────────────────────────────────────────────────
set -g fish_greeting

# ── Environment ───────────────────────────────────────────────
if test -f $HOME/.config/fish/secrets.fish
    source $HOME/.config/fish/secrets.fish
end

# ── Functions ─────────────────────────────────────────────────
# sw: Set wallpaper, apply pywal colors, and reload all theming
function sw
    if not pgrep swww-daemon >/dev/null
        swww-daemon &
        sleep 0.5
    end
    swww img --transition-type center $argv[1]
    $HOME/.local/bin/wal -i $argv[1]
    ~/dotfiles/rofi/generate-rofi.sh
    killall -SIGUSR2 waybar
    swaync-client --reload-css
end

# ── Prompt ────────────────────────────────────────────────────
starship init fish | source

# ── Fastfetch (interactive sessions only) ─────────────────────
if status is-interactive
    fastfetch
end

# ── Pywal (restore last scheme on login) ──────────────────────
if not set -q WAL_RELOADED
    $HOME/.local/bin/wal -R >/dev/null 2>&1 &
    set -gx WAL_RELOADED 1
end
