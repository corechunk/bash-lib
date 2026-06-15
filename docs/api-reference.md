# 📖 bash-lib API Reference

A detailed overview of all core variables, utilities, and components available in the `bash-lib` library.

## 📂 core/
*   📄 `colors.sh`
    *   📢 `declare -g BL_RED` to `declare -g BL_RESET`: ANSI escape sequences for premium terminal styling and coloring.
        *   *Showcase:* `BL_RED` ➔ `'\e[31m'`
    *   ⚙️ `bl_hex_to_rgb()`: Converts Hex color strings (e.g. `#FF0000`) into space-separated RGB decimal channels.
*   📄 `import.sh`
    *   ⚙️ `bl_check_deps()`: Guards execution by verifying if dependent functions exist in shell memory.
    *   📢 `declare -g -A BL_REGISTRY`: Master map defining dependencies and categories for all library functions.
        *   *Showcase:* `["ui|bl_progress_bar"]` ➔ `"bl_hex_to_rgb|bl_check_deps"`
    *   📢 `declare -g -A BL_FILE_REGISTRY`: Global map linking library modules to their remote raw GitHub URLs.
        *   *Showcase:* `["core|colors.sh"]` ➔ `"https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/core/colors.sh"`
    *   ⚙️ `bl_import()`: Streams and sources remote library files dynamically matching a search pattern.
        *   *Flags:* `-v` verbose · `--strict` fail on error
    *   ⚙️ `bl_import_local()`: Recursively searches and sources local script modules avoiding duplication.
        *   *Flags:* `-v` verbose · `--strict` fail on error
    *   ⚙️ `import()`: A sleek wrapper around `bl_import_local()` to load everything elegantly.
        *   *Flags:* `-v` verbose · `--strict` fail on error
    *   ⚙️ `bl_update_registry()`: Scans the repository and queries GitHub APIs to update the remote URL registry.
    *   ⚙️ `bl_registry_get_types()`: Retrieves all unique category tags registered in the library.
    *   ⚙️ `bl_registry_get_funcs()`: Filters and returns function names registered under a specific category.
    *   ⚙️ `bl_registry_get_deps()`: Queries the dependency list for a specific registered function.
*   📄 `versions.sh`
    *   ⚙️ `bl_version_compare()`: Left-to-right component-wise semantic version comparison utility.

## 📂 dev/
*   📄 `compile.sh`
    *   ⚙️ `bl_compile()`: Bundles a directory of bash-lib modules into a single, compiled script file.
        *   *Flags:* `-d` dir · `-o` out-name · `-m` main · `--out-dir` · `-v` verbose · `-r` recursive · `--no-shebang` · `--shebang value` · `-s` strip [empty\|comments\|all] · `--strict` · `--lib-curl` [start \<urls...\> stop]

## 📂 string/
*   📄 `selection.sh`
    *   ⚙️ `bl_parse_selection()`: Splits menu selection inputs and expands range expressions (e.g. '1-4' into '1 2 3 4').
    *   ⚙️ `bl_expand_selection()`: Keyword-aware expansion utility. Translates 'all' keywords into numerical sequences.
    *   ⚙️ `bl_validate_selection()`: Boundary checks menu options to ensure all selected items are valid.

## 📂 io/
*   📄 `pipes.sh`
    *   ⚙️ `bl_file_count_feeder_()`: Directory polling engine that watches matching marker file creation to feed sync ratios.
    *   ⚙️ `_bl_count_percent_emitter_()`: Math streaming emitter translating raw completed integers into percentage tokens.
    *   ⚙️ `bl_file_log_feeder_()`: Tails a log file and reformats the last line as a progress bar message feed.

## 📂 async/
*   📄 `pid.sh`
    *   ⚙️ `bl_pid_store()`: Stores a background PID in the global registry.
    *   ⚙️ `bl_pid_wait()`: Waits for a specific registered background process to finish and unsets it.
    *   ⚙️ `bl_pid_status()`: Queries process state via `/proc` or `kill -0`.
    *   ⚙️ `bl_pid_reap()`: Non-blocking background scavenger sweep.

## 📂 info/
*   📄 `diagnostics.sh`
    *   ⚙️ `bl_info_check()`: Scans shell memory to diagnose and report loaded library components and health status.
    *   ⚙️ `bl_info_menu()`: Launches an interactive CLI explorer manual for all registered library functions.
*   📄 `tutor.sh`
    *   ⚙️ `bl_bash_tutor()`: Launches an interactive terminal-based tutorial covering advanced Bash scripting mechanics.

## 📂 ui/
*   📄 `progress_bars.sh`
    *   ⚙️ `bl_progress_bar()`: Renders highly responsive, color-transitioning ANSI progress loaders with optional tagged status and scrolling logs.
        *   *Flags:* `-l` label · `-w N` width · `-fw` full-width · `--status` · `--log` · `--log-height N` · `--color-mode global|position` · `--start HEX` · `--end HEX`
    *   ⚙️ `bl_square_progress()`: Renders a configurable block grid progress indicator that fills block by block with positional or global gradients.
        *   *Flags:* `-l` label · `-t` tagged · `-w N` width · `-H N` height · `-fw` full-width · `--brackets` · `--color-mode global|position` · `--start HEX` · `--end HEX`
    *   ⚙️ `bl_spiral_progress()`: Renders a block grid that fills in a configurable inward or outward spiral with gradient support.
        *   *Flags:* `-l` label · `-t` tagged · `-w N` width · `-H N` height · `-fw` full-width · `--direction in|out` · `--brackets` · `--color-mode global|position` · `--start HEX` · `--end HEX`
    *   ⚙️ `bl_terrain_loader()`: Renders an animated 2D terrain chunk-loading grid. Blocks fill one at a time using random, center-out, or authentic Minecraft patterns.
        *   *Flags:* `-l` label · `-w N` width · `-h N` height · `-fw` full-width · `-fh` full-height · `--pattern random|center-out|minecraft` · `--minecraft` (shortcut) · `--color-mode time|position|global` · `--start HEX` · `--end HEX` · `--fg COLOR`
    *   ⚙️ `bl_terrain_loader_opt()`: Experimental optimized terrain loader that delegates to `bl_terrain_loader`.
*   📄 `matrix_filler.sh`
    *   ⚙️ `bl_matrix_filler()`: Fills the terminal with a pure-Bash, fully responsive falling green digital rain (Matrix style). Exits on any key press.

