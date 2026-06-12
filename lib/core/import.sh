#!/usr/bin/env bash
# --- bash-lib Core Loader & Registries ---

# Global registry of functions, categories, and dependencies.
declare -g -A BL_REGISTRY=(
    # Core utilities (no shell-func deps; system cmds noted where needed)
    ["core|bl_check_deps"]=""
    ["core|bl_hex_to_rgb"]=""
    ["core|bl_compare_versions"]=""
    ["core|bl_parse_selection"]=""
    ["core|bl_expand_selection"]=""
    ["core|bl_validate_selection"]=""

    # UI components
    ["ui|bl_progress_bar"]="bl_hex_to_rgb|bl_check_deps"
    ["ui|bl_square_progress"]="bl_hex_to_rgb|bl_check_deps"
    ["ui|bl_spiral_progress"]="bl_hex_to_rgb|bl_check_deps"
    ["ui|bl_terrain_loader"]="bl_hex_to_rgb|bl_check_deps"
    ["ui|bl_pie"]="bl_check_deps"
    ["ui|bl_matrix_filler"]="tput"
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
    ["info|bl_info_check"]="bl_registry_get_types|bl_registry_get_funcs|bl_registry_get_deps"
    ["info|bl_info_menu"]="bl_registry_get_types|bl_registry_get_funcs|bl_registry_get_deps"
    ["info|bl_bash_tutor"]=""

    # Async operations
    ["async|bl_pid_status"]=""
    ["async|bl_reap"]=""

    # Core Loader
    ["core|bl_import"]="curl"
    ["core|bl_import_local"]=""
    ["core|import"]="bl_import_local"
    ["core|bl_update_registry"]="curl|jq"
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

# Rule: This function has dependencies — bl_check_deps is called as the first statement.
# Update the hardcoded BL_FILE_REGISTRY in lib/core/import.sh using GitHub API
bl_update_registry() {
    bl_check_deps "bl_update_registry" "curl" "jq" || return 1

    local repo="${1:-bash-lib}"
    local org="${2:-corechunk}"
    local branch="${3:-main}"
    local base_dir
    base_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
    local output_file="$base_dir/lib/core/import.sh"

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

# Rule: This function has dependencies — bl_check_deps is called as the first statement.
# Import remote libraries by pattern (e.g., "*", "ui/*", "core/colors.sh")
bl_import() {
    bl_check_deps "bl_import" "curl" || return 1

    local pattern="${1:-*}"

    local search_cat=""
    local search_file=""

    if [[ "$pattern" == "*" ]]; then
        search_cat="*"
        search_file="*"
    elif [[ "$pattern" == */* ]]; then
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

# Import local libraries by glob pattern.
# Pattern is resolved relative to $PWD unless absolute.
# If the pattern matches a directory, all eligible files inside are sourced recursively.
# Accepts multiple patterns at once (useful when shell expands globs before passing).
#
# A file is eligible if:
#   1. It has a .sh or .bash extension, OR
#   2. It has no extension AND its shebang references bash (not sh)
#      e.g. #!/bin/bash  #!/usr/bin/env bash  -- YES
#           #!/bin/sh    #!/usr/bin/env sh    -- NO
#
# Examples:
#   import "lib/*"         -> sources all eligible files under lib/ (recursively)
#   import lib/*           -> shell expands to dirs; each is recursed into
#   import lib/ui lib/core -> multiple dirs
#   import /abs/path/*.sh  -> absolute path supported too

# Returns 0 if the file should be sourced, 1 otherwise
_bl_is_sourceable() {
    local f="$1"
    local base="${f##*/}"
    # Has .sh or .bash extension
    if [[ "$f" == *.sh || "$f" == *.bash ]]; then
        return 0
    fi
    # No extension at all — check shebang
    if [[ "$base" != *.* ]]; then
        local shebang
        shebang=$(head -c 100 "$f" 2>/dev/null | head -1)
        if [[ "$shebang" == *bash* && "$shebang" != *" sh"* && "$shebang" != */sh ]]; then
            return 0
        fi
    fi
    return 1
}

bl_import_local() {
    [[ $# -eq 0 ]] && { echo -e "\033[1;31m[import]\033[0m pattern required (e.g. \"lib/*\")" >&2; return 1; }
    shopt -s globstar nullglob
    local found=0
    local pattern target file
    local -A _seen=()
    for pattern in "$@"; do
        # If not absolute, resolve relative to PWD
        [[ "$pattern" != /* ]] && pattern="${PWD}/${pattern}"
        local -a targets=( $pattern )
        for target in "${targets[@]}"; do
            if [[ -d "$target" ]]; then
                for file in "$target"/**/* "$target"/*; do
                    [[ -f "$file" ]] || continue
                    [[ -n "${_seen[$file]}" ]] && continue
                    _bl_is_sourceable "$file" || continue
                    _seen["$file"]=1
                    echo -e "\033[1;34m[import]\033[0m $file"
                    source "$file"
                    (( found++ ))
                done
            elif [[ -f "$target" ]]; then
                [[ -n "${_seen[$target]}" ]] && continue
                _bl_is_sourceable "$target" || continue
                _seen["$target"]=1
                echo -e "\033[1;34m[import]\033[0m $target"
                source "$target"
                (( found++ ))
            fi
        done
    done
    shopt -u globstar nullglob
    if (( found == 0 )); then
        echo -e "\033[1;33m[import]\033[0m No sourceable files matched: $*" >&2
        return 1
    fi
}

# Simple import keyword backed by bl_import_local
import() {
    bl_import_local "$@"
}
