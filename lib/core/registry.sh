# Global registry of functions, categories, and dependencies.
# Format: ["type|func_name"]="dependency1|dependency2|..."
declare -g -A BL_REGISTRY=(
    # Core utilities
    ["core|bl_check_deps"]=""
    ["core|bl_hex_to_rgb"]=""
    ["core|bl_compare_versions"]=""
    ["core|bl_parse_selection"]=""
    ["core|bl_expand_selection"]=""
    ["core|bl_validate_selection"]=""

    # UI components (category prefix removed from function name)
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

    # Globbing utilities
    ["glob|bl_init"]=""
    ["glob|bl_glob_source"]=""
    ["glob|bl_file_registry_update"]=""
)

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
# Usage: bl_registry_get_funcs <type>
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
# Usage: bl_registry_get_deps <func_name>
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
