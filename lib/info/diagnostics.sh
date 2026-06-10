# Loop across internal namespaces to check and confirm exactly which modules
# have loaded without configuration corruption.
bl_info_check() {
    # Ensure registry is loaded
    if ! declare -p BL_REGISTRY >/dev/null 2>&1; then
        echo -e "\033[1;31m[ERROR]\033[0m BL_REGISTRY is not declared. Did you source lib/core/registry.sh?" >&2
        return 1
    fi

    echo -e "\033[1m--- bash-lib Namespace Diagnostics ---\033[0m"
    local all_ok=0

    # Get types and sort them
    local types
    types=$(bl_registry_get_types)
    local sorted_types
    sorted_types=$(echo "$types" | tr ' ' '\n' | sort)

    for type in $sorted_types; do
        echo -e "\n\033[1;35m[$type]\033[0m"
        local funcs
        funcs=$(bl_registry_get_funcs "$type")
        local sorted_funcs
        sorted_funcs=$(echo "$funcs" | tr ' ' '\n' | sort)

        for func in $sorted_funcs; do
            local deps
            deps=$(bl_registry_get_deps "$func")
            local dep_ok=true
            local -a dep_statuses=()

            # Split dependencies by "|" and verify their load status
            local OLD_IFS="$IFS"
            IFS='|'
            for dep in $deps; do
                if [ -n "$dep" ]; then
                    if declare -f "$dep" >/dev/null; then
                        dep_statuses+=("[\033[1;32m$dep (ok)\033[0m]")
                    else
                        dep_statuses+=("[\033[1;31m$dep (MISSING)\033[0m]")
                        dep_ok=false
                    fi
                fi
            done
            IFS="$OLD_IFS"

            if declare -f "$func" >/dev/null; then
                if $dep_ok; then
                    echo -e "  \033[1;32m✓\033[0m $func \033[1;32m(Loaded & OK)\033[0m"
                else
                    echo -e "  \033[1;33m⚠\033[0m $func \033[1;31m(Loaded, but dependency is missing!)\033[0m"
                    all_ok=1
                fi
            else
                echo -e "  \033[1;31m✗\033[0m $func \033[38;5;244m(Not sourced/loaded)\033[0m"
            fi

            # Print detailed dependency lists if they exist (runs for loaded & unloaded alike)
            if [ ${#dep_statuses[@]} -gt 0 ]; then
                echo -e "      deps: ${dep_statuses[*]}"
            fi
        done
    done

    return $all_ok
}

bl_info_menu() {
    # Ensure registry is loaded
    if ! declare -p BL_REGISTRY >/dev/null 2>&1; then
        echo -e "\033[1;31m[ERROR]\033[0m BL_REGISTRY is not declared. Did you source lib/core/registry.sh?" >&2
        return 1
    fi

    # Inner usage/details retriever
    bl_info_get_details() {
        local func="$1"
        case "$func" in
            bl_progress_bar)
                echo -e "\033[1;34mDescription:\033[0m Renders responsive percentage progress bars with standard or tagged logging modes."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_progress_bar [-l label] [-t] [--log-height n] [--start HEX] [--end HEX]\033[0m"
                echo -e "\033[1;36mArguments:\033[0m"
                echo -e "  \033[1;33m-l | --label\033[0m    Set the header label text (defaults to 'Progress')."
                echo -e "  \033[1;33m-t | --tagged\033[0m   Enable tagged Mode B. Parses stdin streams dynamically:"
                echo -e "                    - \033[1;32mP:[0-100]\033[0m updates progress bar percentage."
                echo -e "                    - \033[1;32mM:[message]\033[0m updates the single-line status text."
                echo -e "                    - \033[1;32mL:[log_line]\033[0m appends logs into a scrolling window."
                echo -e "  \033[1;33m--log-height\033[0m   Number of rows allocated for the scrolling log window (default: 3)."
                echo -e "  \033[1;33m--start / --end\033[0m Start/end transition color hex codes (e.g. '0000FF' / '00FF00')."
                echo -e "\033[1;35mStreaming info:\033[0m Feeds from standard input (stdin) via a pipe. Smooths transitions at 60 FPS."
                echo -e "\033[1;36mDependencies:\033[0m  bl_hex_to_rgb, bl_check_deps"
                ;;
            bl_check_deps)
                echo -e "\033[1;34mDescription:\033[0m Verification utility that runs before a function executes to guard against missing dependencies."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_check_deps <caller_name> <dep1> [dep2 ...]\033[0m"
                echo -e "\033[1;36mParameters:\033[0m"
                echo -e "  \033[1;33mcaller_name\033[0m     The name of the function requiring dependencies (for diagnostic logging)."
                echo -e "  \033[1;33mdep1 / dep2\033[0m     Names of functions to verify in environment memory."
                echo -e "\033[1;35mReturn Code:\033[0m  0 if all dependencies exist, 1 if any dependency is missing."
                ;;
            bl_hex_to_rgb)
                echo -e "\033[1;34mDescription:\033[0m Color parser converting hex code colors to terminal-usable RGB decimal channels."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_hex_to_rgb <HEX_STRING>\033[0m"
                echo -e "\033[1;36mParameters:\033[0m"
                echo -e "  \033[1;33mHEX_STRING\033[0m      Hex color string with or without '#'. E.g., '#00FF00' or '00FF00'."
                echo -e "\033[1;35mOutputs:\033[0m      Space-separated red, green, and blue decimal integers on stdout. E.g., '0 255 0'."
                ;;
            bl_compare_versions)
                echo -e "\033[1;34mDescription:\033[0m Left-to-right component-wise semantic version comparison utility."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_compare_versions <ver1> <ver2>\033[0m"
                echo -e "\033[1;36mParameters:\033[0m"
                echo -e "  \033[1;33mver1\033[0m            First version (e.g. '1.2.0.1')."
                echo -e "  \033[1;33mver2\033[0m            Second version to compare against (e.g. '1.3.0')."
                echo -e "\033[1;35mOutputs:\033[0m      Outputs comparison status: 'equal', 'major update', 'minor update', 'patch update', 'hotfix update', or 'downgrade'."
                ;;
            bl_parse_selection)
                echo -e "\033[1;34mDescription:\033[0m Splits menu selection inputs and expands range expressions (e.g. '1-4' into '1 2 3 4')."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_parse_selection <input_string> [delimiter]\033[0m"
                echo -e "\033[1;36mParameters:\033[0m"
                echo -e "  \033[1;33minput_string\033[0m    Input selection string. E.g., '1,3-5'."
                echo -e "  \033[1;33mdelimiter\033[0m       Custom delimiter separating selections (defaults to ',')."
                echo -e "\033[1;35mOutputs:\033[0m      Space-separated expanded token numbers. Returns exit code 1 on parsing syntax errors."
                ;;
            bl_expand_selection)
                echo -e "\033[1;34mDescription:\033[0m Keyword-aware expansion utility. Translates 'all' keywords into numerical sequences."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_expand_selection <max_index> <parsed_inputs...>\033[0m"
                echo -e "\033[1;36mParameters:\033[0m"
                echo -e "  \033[1;33mmax_index\033[0m       The maximum item index available in the current list."
                echo -e "  \033[1;33mparsed_inputs\033[0m   List of raw parsed tokens."
                echo -e "\033[1;35mOutputs:\033[0m      Space-separated numbers containing expanded sequences."
                ;;
            bl_validate_selection)
                echo -e "\033[1;34mDescription:\033[0m Boundary checks menu options to ensure all selected items are valid."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_validate_selection <max_index> <indices...>\033[0m"
                echo -e "\033[1;36mParameters:\033[0m"
                echo -e "  \033[1;33mmax_index\033[0m       The maximum item index allowed."
                echo -e "  \033[1;33mindices\033[0m         One or more expanded numbers to validate."
                echo -e "\033[1;35mReturn Code:\033[0m  0 if all numbers are between 1 and max_index (inclusive); 1 otherwise."
                ;;
            bl_file_feeder)
                echo -e "\033[1;34mDescription:\033[0m Directory polling engine. Watches matching marker file creation to feed sync ratios."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_file_feeder <total> [hz] [dir] [pattern]\033[0m"
                echo -e "\033[1;36mParameters:\033[0m"
                echo -e "  \033[1;33mtotal\033[0m           Total expected file count matching the pattern."
                echo -e "  \033[1;33mhz\033[0m              Polling frequency in Hertz (default: 10)."
                echo -e "  \033[1;33mdir\033[0m             Directory path to scan (defaults to registry path)."
                echo -e "  \033[1;33mpattern\033[0m         File match pattern. E.g., '*.done'."
                echo -e "\033[1;35mOutputs:\033[0m      Standard stream of current file counts."
                ;;
            bl_percent_emitter)
                echo -e "\033[1;34mDescription:\033[0m Math streaming emitter translating raw completed integers into percentage tokens."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_percent_emitter <total> [format]\033[0m"
                echo -e "\033[1;36mParameters:\033[0m"
                echo -e "  \033[1;33mtotal\033[0m           Denominator representing 100% completion."
                echo -e "  \033[1;33mformat\033[0m          Set 'v2' to output tagged progress format (e.g. 'P:50') instead of raw strings."
                echo -e "\033[1;35mOutputs:\033[0m      Percentage flow stream."
                ;;
            bl_log_feeder)
                echo -e "\033[1;34mDescription:\033[0m Tails a log file and reformats the last line as a progress bar message feed."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_log_feeder <logfile> [hz]\033[0m"
                echo -e "\033[1;36mParameters:\033[0m"
                echo -e "  \033[1;33mlogfile\033[0m         Path to log file being monitored."
                echo -e "  \033[1;33mhz\033[0m              Tail polling frequency in Hertz (default: 5)."
                echo -e "\033[1;35mOutputs:\033[0m      Stream of status messages prefixed with 'M:'."
                ;;
            bl_info_check)
                echo -e "\033[1;34mDescription:\033[0m Core environment diagnostic utility. Sweeps loaded memory to verify framework functions and dependencies."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_info_check\033[0m"
                echo -e "\033[1;35mBehaviors:\033[0m    Outputs namespace categories and color-coded status checks grouped dynamically."
                ;;
            bl_info_menu)
                echo -e "\033[1;34mDescription:\033[0m Interactive text browser explorer manual."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_info_menu\033[0m"
                echo -e "\033[1;35mBehaviors:\033[0m    Launches browser framework to inspect loaded libraries, dependencies, and manuals."
                ;;
            bl_bash_tutor)
                echo -e "\033[1;34mDescription:\033[0m Interactive bash interpreter options and scripting lessons manual."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_bash_tutor\033[0m"
                echo -e "\033[1;35mBehaviors:\033[0m    Launches tutor menu covering set modes, string expansions, quoting, and scope declarations."
                ;;
            bl_pid_status)
                echo -e "\033[1;34mDescription:\033[0m [Planned] Queries process directory state via /proc/\$PID or signal kill -0."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_pid_status <pid>\033[0m"
                echo -e "\033[1;35mOutputs:\033[0m      Status string representing process states: 'RUNNING', 'SUCCESS', or 'FAILED'."
                ;;
            bl_reap)
                echo -e "\033[1;34mDescription:\033[0m [Planned] Non-blocking tracking PID scavenger sweep."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_reap\033[0m"
                echo -e "\033[1;35mBehaviors:\033[0m    Iterates over background job registries, reaping dead process vectors and harvesting exit codes."
                ;;
            bl_init)
                echo -e "\033[1;34mDescription:\033[0m Bootstraps and imports the core registry and file registry maps into the shell environment."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_init\033[0m"
                ;;
            bl_glob_source)
                echo -e "\033[1;34mDescription:\033[0m Sourced libraries matcher. Streams and sources files directly from online remote URLs without storing them locally."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_glob_source [pattern]\033[0m"
                echo -e "  \033[1;33mpattern\033[0m          Glob pattern matching file names or categories. E.g. 'ui/*', 'core', or '*'."
                ;;
            bl_file_registry_update)
                echo -e "\033[1;34mDescription:\033[0m Queries GitHub API to rebuild the hardcoded remote file registry mapping."
                echo -e "\033[1;32mUsage:\033[0m       \033[33mbl_file_registry_update [repo] [org] [branch]\033[0m"
                ;;
            *)
                echo -e "\033[1;34mDescription:\033[0m [Planned] Details and usage will be added upon implementation."
                local deps
                deps=$(bl_registry_get_deps "$func")
                if [[ -n "$deps" ]]; then
                    echo -e "\033[1;36mDependencies:\033[0m $deps"
                fi
                ;;
        esac
    }

    local types
    types=$(bl_registry_get_types)
    local -a sorted_types
    read -r -a sorted_types < <(echo "$types" | tr ' ' '\n' | sort | tr '\n' ' ')

    while true; do
        clear
        echo -e "\033[1;35m=========================================\033[0m"
        echo -e "\033[1;36m       BASH-LIB EXPLORER MANUAL          \033[0m"
        echo -e "\033[1;35m=========================================\033[0m"
        echo -e "Select a category to explore:\n"
        
        for i in "${!sorted_types[@]}"; do
            printf "  \033[1;33m%d)\033[0m %s\n" "$((i+1))" "${sorted_types[i]}"
        done
        echo -e "\n  \033[1;31mx)\033[0m Exit Browser"
        echo -e "\033[1;35m-----------------------------------------\033[0m"
        read -rp "Select an option: " cat_opt

        if [[ "$cat_opt" == "x" || "$cat_opt" == "X" ]]; then
            break
        fi

        if [[ "$cat_opt" =~ ^[0-9]+$ ]] && (( cat_opt > 0 && cat_opt <= ${#sorted_types[@]} )); then
            local sel_cat="${sorted_types[$((cat_opt-1))]}"
            
            while true; do
                clear
                echo -e "\033[1;35m=========================================\033[0m"
                echo -e "Category: \033[1;32m[$sel_cat]\033[0m"
                echo -e "\033[1;35m=========================================\033[0m"
                
                local funcs
                funcs=$(bl_registry_get_funcs "$sel_cat")
                local -a sorted_funcs
                read -r -a sorted_funcs < <(echo "$funcs" | tr ' ' '\n' | sort | tr '\n' ' ')

                for i in "${!sorted_funcs[@]}"; do
                    local f="${sorted_funcs[i]}"
                    local load_status="\033[1;31m✗\033[0m"
                    if declare -f "$f" >/dev/null; then
                        load_status="\033[1;32m✓\033[0m"
                    fi
                    printf "  \033[1;33m%d)\033[0m %b %s\n" "$((i+1))" "$load_status" "$f"
                done
                echo -e "\n  \033[1;31mb)\033[0m Back to Categories"
                echo -e "\033[1;35m-----------------------------------------\033[0m"
                read -rp "Select a function to view details: " func_opt

                if [[ "$func_opt" == "b" || "$func_opt" == "B" ]]; then
                    break
                fi

                if [[ "$func_opt" =~ ^[0-9]+$ ]] && (( func_opt > 0 && func_opt <= ${#sorted_funcs[@]} )); then
                    local sel_func="${sorted_funcs[$((func_opt-1))]}"
                    clear
                    echo -e "\033[1;35m=========================================\033[0m"
                    echo -e "Function: \033[1;32m$sel_func\033[0m"
                    echo -e "\033[1;35m=========================================\033[0m"
                    bl_info_get_details "$sel_func"
                    echo -e "\033[1;35m=========================================\033[0m"
                    read -rp "Press Enter to return to function list..."
                fi
            done
        fi
    done
}
