# --- ANSI Escape Color Codes (Raw and Fast) ---
declare -g BL_RED=$'\e[31m'
declare -g BL_GREEN=$'\e[32m'
declare -g BL_YELLOW=$'\e[33m'
declare -g BL_ORANGE=$'\e[38;5;166m'
declare -g BL_SKY_BLUE=$'\e[36m'
declare -g BL_MAGENTA=$'\e[35m'
declare -g BL_WHITE=$'\e[37m'
declare -g BL_RESET=$'\e[0m'

# --- Additional ANSI Colors ---
declare -g BL_BLUE=$'\e[34m'
declare -g BL_BLACK=$'\e[30m'
declare -g BL_GRAY=$'\e[90m'
declare -g BL_BRIGHT_RED=$'\e[91m'
declare -g BL_BRIGHT_GREEN=$'\e[92m'
declare -g BL_BRIGHT_YELLOW=$'\e[93m'
declare -g BL_BRIGHT_BLUE=$'\e[94m'
declare -g BL_BRIGHT_MAGENTA=$'\e[95m'
declare -g BL_BRIGHT_CYAN=$'\e[96m'
declare -g BL_BRIGHT_WHITE=$'\e[97m'

## --- Terminfo (tput) Equivalents (Active) ---
#declare -g BL_RED_=$(tput setaf 1)
#declare -g BL_GREEN_=$(tput setaf 2)
#declare -g BL_YELLOW_=$(tput setaf 3)
#declare -g BL_ORANGE_=$(tput setaf 166)
#declare -g BL_SKY_BLUE_=$(tput setaf 6)
#declare -g BL_MAGENTA_=$(tput setaf 5)
#declare -g BL_WHITE_=$(tput setaf 7)
#declare -g BL_RESET_=$(tput sgr0)
#
## --- Terminfo (tput) Underscore Equivalents ---
#declare -g BL_BLUE_=$(tput setaf 4)
#declare -g BL_BLACK_=$(tput setaf 0)
#declare -g BL_GRAY_=$(tput setaf 8)
#declare -g BL_BRIGHT_RED_=$(tput setaf 9)
#declare -g BL_BRIGHT_GREEN_=$(tput setaf 10)
#declare -g BL_BRIGHT_YELLOW_=$(tput setaf 11)
#declare -g BL_BRIGHT_BLUE_=$(tput setaf 12)
#declare -g BL_BRIGHT_MAGENTA_=$(tput setaf 13)
#declare -g BL_BRIGHT_CYAN_=$(tput setaf 14)
#declare -g BL_BRIGHT_WHITE_=$(tput setaf 15)

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
