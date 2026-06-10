# --- bash-lib Core Loader & Registries ---

# Global registry of functions, categories, and dependencies.
declare -g -A BL_REGISTRY=(
    # Core utilities
    ["core|bl_check_deps"]=""
    ["core|bl_hex_to_rgb"]=""
    ["core|bl_compare_versions"]=""
    ["core|bl_parse_selection"]=""
    ["core|bl_expand_selection"]=""
    ["core|bl_validate_selection"]=""

    # UI components
    ["ui|bl_progress_bar"]="bl_hex_to_rgb|bl_check_deps"
    ["ui|bl_pie"]="bl_check_deps|bl_nonexistent_helper"
    ["ui|bl_matrix_filler"]=""
    ["ui|bl_load_ghost"]=""
    ["ui|bl_load_bounce"]=""
    ["ui|bl_load_marquee"]=""
    ["ui|bl_load_wave"]=""
    ["ui|bl_menu"]=""
    ["ui|bl_toast"]=""
    ["ui|bl_input_secure"]=""
    ["ui|bl_chart_spark"]=""
    ["ui|bl_file_feeder"]=""
    ["ui|bl_percent_emitter"]=""
    ["ui|bl_log_feeder"]=""

    # Info & Diagnostics
    ["info|bl_info_check"]=""
    ["info|bl_info_menu"]=""
    ["info|bl_bash_tutor"]=""

    # Async operations
    ["async|bl_pid_status"]=""
    ["async|bl_reap"]=""

    # Core Loader
    ["core|bl_import"]=""
    ["core|bl_update_registry"]=""
)

# === BL_FILE_REGISTRY_START ===
declare -g -A BL_FILE_REGISTRY=(
    ["core|colors.sh"]="https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/core/colors.sh"
    ["core|deps.sh"]="https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/core/deps.sh"
    ["core|import.sh"]="https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/core/import.sh"
    ["info|diagnostics.sh"]="https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/info/diagnostics.sh"
    ["info|tutor.sh"]="https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/info/tutor.sh"
    ["ui|progress_bars.sh"]="https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/ui/progress_bars.sh"
)
# === BL_FILE_REGISTRY_END ===

# Get all unique types registered
bl_registry_get_types() {
    local -A types_seen
    for key in "${!BL_REGISTRY[@]}"; do
        local type="${key%%|*}"
        types_seen["$type"]=1
    done
    echo "${!types_seen[@]}"
}

# Get functions by type
bl_registry_get_funcs() {
    local target_type="$1"
    local funcs=()
    for key in "${!BL_REGISTRY[@]}"; do
        local type="${key%%|*}"
        local func="${key#*|}"
        if [[ "$type" == "$target_type" ]]; then
            funcs+=("$func")
        fi
    done
    echo "${funcs[@]}"
}

# Get dependencies for a specific function name
bl_registry_get_deps() {
    local target_func="$1"
    for key in "${!BL_REGISTRY[@]}"; do
        local func="${key#*|}"
        if [[ "$func" == "$target_func" ]]; then
            echo "${BL_REGISTRY[$key]}"
            return 0
        fi
    done
    return 1
}

# Update the hardcoded BL_FILE_REGISTRY in lib/core/import.sh using GitHub API
bl_update_registry() {
    local repo="${1:-bash-lib}"
    local org="${2:-corechunk}"
    local branch="${3:-main}"
    local base_dir
    base_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
    local output_file="$base_dir/lib/core/import.sh"

    # Require jq and curl
    if ! command -v jq >/dev/null 2>&1; then
        echo -e "\033[1;31m[ERROR]\033[0m bl_update_registry: 'jq' command is required." >&2
        return 1
    fi
    if ! command -v curl >/dev/null 2>&1; then
        echo -e "\033[1;31m[ERROR]\033[0m bl_update_registry: 'curl' command is required." >&2
        return 1
    fi

    echo -e "\033[1;34m[INFO]\033[0m Fetching file tree for ${org}/${repo} (${branch}) from GitHub API..."
    local tree_json
    tree_json=$(curl -s "https://api.github.com/repos/${org}/${repo}/git/trees/${branch}?recursive=1")
    if [[ $? -ne 0 || -z "$tree_json" || $(echo "$tree_json" | jq -r '.message // empty') == "Not Found" ]]; then
        echo -e "\033[1;31m[ERROR]\033[0m Failed to fetch repository tree. Check repo name and connection." >&2
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    # Generate new registry mapping block
    local new_registry
    new_registry=$(echo "$tree_json" | jq -r --arg org "$org" --arg repo "$repo" --arg branch "$branch" '
        .tree[]
        | select(.type == "blob" and (.path | endswith(".sh")))
        | .path as $p
        | ($p | split("/")) as $parts
        | (if ($p | startswith("lib/")) then $parts[1] elif ($parts | length) > 1 then $parts[0] else "main" end) as $cat
        | $parts[-1] as $file
        | "    [\"\($cat)|\($file)\"]=\"https://raw.githubusercontent.com/\($org)/\($repo)/\($branch)/\($p)\""
    ' | sort)

    # Read import.sh and replace block between markers
    awk -v reg="$new_registry" '
        /# === BL_FILE_REGISTRY_START ===/ {
            print "# === BL_FILE_REGISTRY_START ==="
            print "declare -g -A BL_FILE_REGISTRY=("
            print reg
            print ")"
            skip = 1
            next
        }
        /# === BL_FILE_REGISTRY_END ===/ {
            print "# === BL_FILE_REGISTRY_END ==="
            skip = 0
            next
        }
        !skip { print }
    ' "$output_file" > "$temp_file"

    mv "$temp_file" "$output_file"
    echo -e "\033[1;32m[SUCCESS]\033[0m File registry updated successfully inside: $output_file"
    source "$output_file"
}

# Import remote libraries by pattern (e.g., "*", "ui/*", "core/colors.sh")
bl_import() {
    local pattern="${1:-*}"

    local search_cat=""
    local search_file=""

    if [[ "$pattern" == "*" ]]; then
        search_cat="*"
        search_file="*"
    elif [[ "$pattern" == *"/"* ]]; then
        search_cat="${pattern%%/*}"
        search_file="${pattern#*/}"
        [[ -z "$search_file" ]] && search_file="*"
    else
        search_cat="$pattern"
        search_file="*"
    fi

    for key in "${!BL_FILE_REGISTRY[@]}"; do
        local cat="${key%%|*}"
        local file="${key#*|}"

        if [[ "$search_cat" != "*" && "$cat" != "$search_cat" ]]; then
            continue
        fi
        if [[ "$search_file" != "*" && "$file" != "$search_file" ]]; then
            continue
        fi

        local url="${BL_FILE_REGISTRY[$key]}"
        if [[ -z "$url" ]]; then
            continue
        fi

        echo -e "\033[1;34m[Sourcing Remote]\033[0m $key -> $url"
        if ! source <(curl -fsSL "$url"); then
            echo -e "\033[1;31m[ERROR]\033[0m Failed to source remote library: $key ($url)" >&2
            return 1
        fi
    done
}
