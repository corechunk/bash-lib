# File registry mapping categories and script filenames to their remote raw URLs.
# This map is hardcoded here and can be updated using the updater function.

declare -g -A BL_FILE_REGISTRY=(
    ["core|colors.sh"]="https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/core/colors.sh"
    ["core|deps.sh"]="https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/core/deps.sh"
    ["core|file_registry.sh"]="https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/core/file_registry.sh"
    ["core|registry.sh"]="https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/core/registry.sh"
    ["glob|glob.sh"]="https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/glob/glob.sh"
    ["info|diagnostics.sh"]="https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/info/diagnostics.sh"
    ["info|tutor.sh"]="https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/info/tutor.sh"
    ["ui|progress_bars.sh"]="https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/ui/progress_bars.sh"
)
