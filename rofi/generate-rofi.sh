#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
#  Pywal Rofi Theme Generator
#  Produces an enhanced theme.rasi with MacTahoe icons + macOS-style aesthetics
# ─────────────────────────────────────────────────────────────────────────────

COLORS_FILE="$HOME/.cache/wal/colors"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/theme.rasi"

# ── Dependency check ──────────────────────────────────────────────────────────
if [ ! -f "$COLORS_FILE" ]; then
    echo "Error: Pywal colors file not found at $COLORS_FILE"
    echo "Run pywal first: wal -i <wallpaper>"
    exit 1
fi

# ── Helpers ───────────────────────────────────────────────────────────────────

# Convert a hex colour (#RRGGBB) to "R, G, B"
hex_to_rgb() {
    local hex
    hex=$(echo "$1" | sed 's/#//')
    printf "%d, %d, %d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

# Lighten a hex colour by mixing it toward white by <pct>% (0-100)
hex_lighten() {
    local hex pct r g b
    hex=$(echo "$1" | sed 's/#//')
    pct="${2:-20}"
    r=$(( (0x${hex:0:2} * (100 - pct) + 255 * pct) / 100 ))
    g=$(( (0x${hex:2:2} * (100 - pct) + 255 * pct) / 100 ))
    b=$(( (0x${hex:4:2} * (100 - pct) + 255 * pct) / 100 ))
    # Clamp to 0-255
    r=$(( r > 255 ? 255 : (r < 0 ? 0 : r) ))
    g=$(( g > 255 ? 255 : (g < 0 ? 0 : g) ))
    b=$(( b > 255 ? 255 : (b < 0 ? 0 : b) ))
    printf "#%02X%02X%02X" "$r" "$g" "$b"
}

# ── Read pywal palette ─────────────────────────────────────────────────────────
readarray -t colors < "$COLORS_FILE"

bg_hex="${colors[0]}"
fg_hex="${colors[7]}"
accent_hex="${colors[4]}"

bg_rgb=$(hex_to_rgb "$bg_hex")
# accent_hex as rgb for rgba() calls
accent_r=$(printf "%d" "0x${accent_hex:1:2}")
accent_g=$(printf "%d" "0x${accent_hex:3:2}")
accent_b=$(printf "%d" "0x${accent_hex:5:2}")
fg_r=$(printf "%d" "0x${fg_hex:1:2}")
fg_g=$(printf "%d" "0x${fg_hex:3:2}")
fg_b=$(printf "%d" "0x${fg_hex:5:2}")

# ── Write theme ───────────────────────────────────────────────────────────────
cat > "$OUTPUT_FILE" <<EOF
/**
 * Pywal Rofi Theme (Auto-generated)
 * Enhanced with MacTahoe icon theme + macOS-style aesthetics
 *
 * Background : $bg_hex
 * Foreground : $fg_hex
 * Accent     : $accent_hex
 */

configuration {
    show-icons:          true;
    icon-theme:          "MacTahoe";
    display-drun:        " ";
    drun-display-format: "{name}";
    disable-history:     false;
    hide-scrollbar:      true;
    sidebar-mode:        false;
}

* {
    background:          rgba($bg_rgb, 0.88);
    foreground:          $fg_hex;
    accent:              $accent_hex;
    selected-bg:         rgba($accent_r, $accent_g, $accent_b, 0.22);
    selected-border:     rgba($accent_r, $accent_g, $accent_b, 0.55);
    muted:               rgba($fg_r, $fg_g, $fg_b, 0.28);

    font:                "JetBrainsMono Nerd Font 12";
    background-color:    transparent;
    text-color:          @foreground;
}

/* ─────────────────────────────────────────
   Window
───────────────────────────────────────── */
window {
    width:               390px;
    location:            center;
    anchor:              center;
    y-offset:            -60px;

    background-color:    @background;
    border:              1px solid;
    border-color:        rgba($accent_r, $accent_g, $accent_b, 0.35);
    border-radius:       16px;
    padding:             0px;
    transparency:        "real";
}

/* ─────────────────────────────────────────
   Main Layout
───────────────────────────────────────── */
mainbox {
    background-color:    transparent;
    padding:             14px;
    spacing:             10px;
    children:            [ inputbar, listview, message ];
}

/* ─────────────────────────────────────────
   Search Bar
───────────────────────────────────────── */
inputbar {
    background-color:    rgba(255, 255, 255, 0.055);
    border:              1px solid;
    border-color:        rgba($accent_r, $accent_g, $accent_b, 0.22);
    border-radius:       10px;
    padding:             10px 14px;
    spacing:             8px;
    children:            [ entry, case-indicator ];
}

prompt {
    background-color:    transparent;
    text-color:          @accent;
    padding:             0px 4px 0px 0px;
    font:                "JetBrainsMono Nerd Font 14";
    vertical-align:      0.5;
}

entry {
    background-color:    transparent;
    text-color:          @foreground;
    placeholder:         "Search apps…";
    placeholder-color:   @muted;
    vertical-align:      0.5;
    cursor:              text;
}

case-indicator {
    background-color:    transparent;
    text-color:          @muted;
    spacing:             0px;
}

/* ─────────────────────────────────────────
   Results List
───────────────────────────────────────── */
listview {
    background-color:    transparent;
    columns:             1;
    lines:               8;
    spacing:             2px;
    scrollbar:           false;
    fixed-height:        false;
    dynamic:             true;
    cycle:               true;
}

/* ─────────────────────────────────────────
   List Elements
───────────────────────────────────────── */
element {
    background-color:    transparent;
    text-color:          @foreground;
    padding:             7px 10px;
    border-radius:       8px;
    orientation:         horizontal;
    spacing:             0px;
}

/* Normal states */
element normal.normal {
    background-color:    transparent;
    text-color:          @foreground;
}

element normal.urgent {
    background-color:    transparent;
    text-color:          #e06c75;
}

element normal.active {
    background-color:    rgba($accent_r, $accent_g, $accent_b, 0.10);
    text-color:          @accent;
}

/* Selected states */
element selected.normal {
    background-color:    @selected-bg;
    text-color:          #ffffff;
    border:              1px solid;
    border-color:        @selected-border;
}

element selected.urgent {
    background-color:    rgba(224, 108, 117, 0.18);
    text-color:          #e06c75;
    border:              1px solid;
    border-color:        rgba(224, 108, 117, 0.45);
}

element selected.active {
    background-color:    rgba($accent_r, $accent_g, $accent_b, 0.30);
    text-color:          #ffffff;
    border:              1px solid;
    border-color:        @selected-border;
}

/* Alternate (even row) states */
element alternate.normal {
    background-color:    transparent;
    text-color:          @foreground;
}

element alternate.urgent {
    background-color:    transparent;
    text-color:          #e06c75;
}

element alternate.active {
    background-color:    rgba($accent_r, $accent_g, $accent_b, 0.08);
    text-color:          @accent;
}

/* ─────────────────────────────────────────
   Icon & Text
───────────────────────────────────────── */
element-icon {
    size:                28px;
    padding:             0px 12px 0px 2px;
    background-color:    transparent;
    vertical-align:      0.5;
}

element-text {
    background-color:    transparent;
    text-color:          inherit;
    vertical-align:      0.5;
    highlight:           bold;
}

/* ─────────────────────────────────────────
   Message / No-results
───────────────────────────────────────── */
message {
    background-color:    transparent;
    padding:             4px 0px 0px 0px;
}

textbox {
    background-color:    transparent;
    text-color:          @muted;
    font:                "JetBrainsMono Nerd Font 11";
    padding:             0px;
    vertical-align:      0.5;
    horizontal-align:    0.5;
}
EOF

echo "✓ Rofi theme regenerated at: $OUTPUT_FILE"
echo "  Background : $bg_hex  |  Foreground : $fg_hex  |  Accent : $accent_hex"
