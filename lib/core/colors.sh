# --- ANSI Escape Color Codes (Raw and Fast) ---
declare -g BL_RED=$'\e[31m'
declare -g BL_GREEN=$'\e[32m'
declare -g BL_YELLOW=$'\e[33m'
declare -g BL_ORANGE=$'\e[38;5;166m'
declare -g BL_SKY_BLUE=$'\e[36m'
declare -g BL_MAGENTA=$'\e[35m'
declare -g BL_WHITE=$'\e[37m'
declare -g BL_RESET=$'\e[0m'

# --- Terminfo (tput) Equivalents (Slower, kept as reference) ---
# declare -g BL_RED=$(tput setaf 1)
# declare -g BL_GREEN=$(tput setaf 2)
# declare -g BL_YELLOW=$(tput setaf 3)
# declare -g BL_ORANGE=$(tput setaf 166)
# declare -g BL_SKY_BLUE=$(tput setaf 6)
# declare -g BL_MAGENTA=$(tput setaf 5)
# declare -g BL_WHITE=$(tput setaf 7)
# declare -g BL_RESET=$(tput sgr0)

# Convert Hex color string (e.g., #00FF00 or 00FF00) to space-separated RGB decimals
# Usage: bl_hex_to_rgb <HEX_STRING>
bl_hex_to_rgb() {
    local hex="${1#\#}"
    local r g b
    if [[ ${#hex} -eq 6 ]]; then
        r=$((16#${hex:0:2}))
        g=$((16#${hex:2:2}))
        b=$((16#${hex:4:2}))
    else
        r=0; g=0; b=0
    fi
    echo "$r $g $b"
}
