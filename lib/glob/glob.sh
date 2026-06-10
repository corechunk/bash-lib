# --- Globbing and Remote Sourcing Utilities ---

# Initialize the glob environment and ensure registries are loaded
# Usage: bl_init
bl_init() {
    local base_dir
    base_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

    # Source local registries if they exist
    if [[ -f "$base_dir/lib/core/registry.sh" ]]; then
        source "$base_dir/lib/core/registry.sh"
    fi
    if [[ -f "$base_dir/lib/core/file_registry.sh" ]]; then
        source "$base_dir/lib/core/file_registry.sh"
    fi
}

# Update the hardcoded BL_FILE_REGISTRY in lib/core/file_registry.sh using GitHub API
# Usage: bl_file_registry_update [repo] [org] [branch]
bl_file_registry_update() {
    local repo="${1:-bash-lib}"
    local org="${2:-corechunk}"
    local branch="${3:-main}"
    local base_dir
    base_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
    local output_file="$base_dir/lib/core/file_registry.sh"

    # Require jq and curl
    if ! command -v jq >/dev/null 2>&1; then
        echo -e "\033[1;31m[ERROR]\033[0m bl_file_registry_update: 'jq' command is required." >&2
        return 1
    fi
    if ! command -v curl >/dev/null 2>&1; then
        echo -e "\033[1;31m[ERROR]\033[0m bl_file_registry_update: 'curl' command is required." >&2
        return 1
    fi

    echo -e "\033[1;34m[INFO]\033[0m Fetching file tree for ${org}/${repo} (${branch}) from GitHub API..."
    local tree_json
    tree_json=$(curl -s "https://api.github.com/repos/${org}/${repo}/git/trees/${branch}?recursive=1")
    if [[ $? -ne 0 || -z "$tree_json" || $(echo "$tree_json" | jq -r '.message // empty') == "Not Found" ]]; then
        echo -e "\033[1;31m[ERROR]\033[0m Failed to fetch repository tree. Check repo name and connection." >&2
        return 1
    fi

    # Generate the hardcoded file_registry.sh file content
    cat <<EOF > "$output_file"
# File registry mapping categories and script filenames to their remote raw URLs.
# This map is hardcoded here and can be updated using the updater function.

declare -g -A BL_FILE_REGISTRY=(
$(echo "$tree_json" | jq -r --arg org "$org" --arg repo "$repo" --arg branch "$branch" '
    .tree[]
    | select(.type == "blob" and (.path | endswith(".sh")))
    | .path as $p
    | ($p | split("/")) as $parts
    | (if ($p | startswith("lib/")) then $parts[1] elif ($parts | length) > 1 then $parts[0] else "main" end) as $cat
    | $parts[-1] as $file
    | "    [\"\($cat)|\($file)\"]=\"https://raw.githubusercontent.com/\($org)/\($repo)/\($branch)/\($p)\""
' | sort)
)
EOF
    echo -e "\033[1;32m[SUCCESS]\033[0m File registry updated successfully at: $output_file"
    # Source the newly updated registry into the current session
    source "$output_file"
}

# Glob-sources remote libraries by pattern (e.g., "*", "ui/*", "core")
# Downloads and sources matching files directly from online without storing/caching them locally.
# Usage: bl_glob_source [pattern]
bl_glob_source() {
    local pattern="${1:-*}"

    if ! declare -p BL_FILE_REGISTRY >/dev/null 2>&1; then
        bl_init
    fi

    # Standardize input patterns (e.g., ui/ -> ui/*, core/colors.sh -> core|colors.sh)
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

    # Iterate over registry keys to match and source
    for key in "${!BL_FILE_REGISTRY[@]}"; do
        local cat="${key%%|*}"
        local file="${key#*|}"

        # Match category pattern
        if [[ "$search_cat" != "*" && "$cat" != "$search_cat" ]]; then
            continue
        fi
        # Match file pattern
        if [[ "$search_file" != "*" && "$file" != "$search_file" ]]; then
            continue
        fi

        local url="${BL_FILE_REGISTRY[$key]}"
        if [[ -z "$url" ]]; then
            continue
        fi

        echo -e "\033[1;34m[Sourcing Remote]\033[0m $key -> $url"
        # Source the remote file directly using process substitution (no local file is stored)
        if ! source <(curl -fsSL "$url"); then
            echo -e "\033[1;31m[ERROR]\033[0m Failed to source remote library: $key ($url)" >&2
            return 1
        fi
    done
}
