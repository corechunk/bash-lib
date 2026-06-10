# 📖 bash-lib API Reference

A detailed overview of all core variables, utilities, and components available in the `bash-lib` library.

## 📂 core/
*   📄 `colors.sh`
    *   📢 `declare -g BL_RED` to `declare -g BL_RESET`: ANSI escape sequences for premium terminal styling and coloring.
        *   *Showcase:* `BL_RED` ➔ `'\e[31m'`
    *   ⚙️ `bl_hex_to_rgb()`: Converts Hex color strings (e.g. `#FF0000`) into space-separated RGB decimal channels.
*   📄 `deps.sh`
    *   ⚙️ `bl_check_deps()`: Guards execution by verifying if dependent functions exist in shell memory.
*   📄 `import.sh`
    *   📢 `declare -g -A BL_REGISTRY`: Master map defining dependencies and categories for all library functions.
        *   *Showcase:* `["ui|bl_progress_bar"]` ➔ `"bl_hex_to_rgb|bl_check_deps"`
    *   📢 `declare -g -A BL_FILE_REGISTRY`: Global map linking library modules to their remote raw GitHub URLs.
        *   *Showcase:* `["core|colors.sh"]` ➔ `"https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/core/colors.sh"`
    *   ⚙️ `bl_import()`: Streams and sources remote library files dynamically matching a search pattern.
    *   ⚙️ `bl_update_registry()`: Scans the repository and queries GitHub APIs to update the remote URL registry.
    *   ⚙️ `bl_registry_get_types()`: Retrieves all unique category tags registered in the library.
    *   ⚙️ `bl_registry_get_funcs()`: Filters and returns function names registered under a specific category.
    *   ⚙️ `bl_registry_get_deps()`: Queries the dependency list for a specific registered function.

## 📂 info/
*   📄 `diagnostics.sh`
    *   ⚙️ `bl_info_check()`: Scans shell memory to diagnose and report loaded library components and health status.
    *   ⚙️ `bl_info_menu()`: Launches an interactive CLI explorer manual for all registered library functions.
*   📄 `tutor.sh`
    *   ⚙️ `bl_bash_tutor()`: Launches an interactive terminal-based tutorial covering advanced Bash scripting mechanics.

## 📂 ui/
*   📄 `progress_bars.sh`
    *   ⚙️ `bl_progress_bar()`: Renders highly responsive, color-transitioning ANSI progress loaders with optional tagged status and scrolling logs.
