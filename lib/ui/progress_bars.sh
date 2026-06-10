# --- UI Bar V3: The Quantum Console ---
# Mode A (Linear): Input is 0-100.
# Mode B (Tagged): Input uses P: [0-100], M: [Status], L: [Log Entry]
# Args: -l|--label, -t|--tagged, --log-height [n], --start|--end [hex]
bl_progress_bar() {
    # Guard: Require dependency checks before executing
    bl_check_deps "bl_progress_bar" "bl_hex_to_rgb" || return 1

    local label="Progress"
    local tagged=false
    local log_height=3
    local r1=0; local g1=0; local b1=255 # Default Start: Blue
    local r2=0; local g2=255; local b2=0  # Default End: Green

    # Flag Parser
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -l|--label) label="$2"; shift 2 ;;
            -t|--tagged) tagged=true; shift ;;
            --log-height) log_height="$2"; shift 2 ;;
            -h|--hex|--start) read r1 g1 b1 < <(bl_hex_to_rgb "$2"); shift 2 ;;
            --end) read r2 g2 b2 < <(bl_hex_to_rgb "$2"); shift 2 ;;
            *) shift ;;
        esac
    done

    local margin=2
    local bar_source="████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████"
    local empty_source="------------------------------------------------------------------------------------------------------------------------------------------------------"
    
    local percent=0
    local status_msg="Initializing..."
    local -a log_buffer=()
    for ((i=0; i<log_height; i++)); do log_buffer[i]=""; done

    while true; do
        # Non-blocking read (0.01s timeout)
        if read -t 0.01 -r line; then
            if $tagged; then
                case "$line" in
                    P:*) percent="${line#P:}" ;;
                    M:*) status_msg="${line#M:}" ;;
                    L:*) 
                        local raw_msg="${line#L:}"
                        local w=${COLUMNS:-80}
                        local max_w=$((w - margin - 5))
                        ((max_w < 10)) && max_w=10

                        # Wrap by splitting into chunks and pushing each as a new log line
                        while [[ -n "$raw_msg" ]]; do
                            local chunk="${raw_msg:0:$max_w}"
                            raw_msg="${raw_msg:$max_w}"
                            
                            # Shift logs up
                            for ((i=0; i<log_height-1; i++)); do 
                                log_buffer[i]="${log_buffer[i+1]}"
                            done
                            log_buffer[$((log_height-1))]="$chunk"
                        done
                        ;;
                esac
            else
                # Linear Mode: Expect pure numbers
                if [[ "$line" =~ ^[0-9]+$ ]]; then
                    percent="$line"
                fi
            fi
        elif [[ $? -le 128 ]]; then
            # Pipe closed/EOF
            break
        fi

        # --- RENDER FRAME ---
        local width=${COLUMNS:-$(tput cols)}
        local bar_max=$(( width - (margin * 2) - 2 ))
        (( bar_max < 10 )) && bar_max=10

        local r_now=$(( r1 + (r2 - r1) * percent / 100 ))
        local g_now=$(( g1 + (g2 - g1) * percent / 100 ))
        local b_now=$(( b1 + (b2 - b1) * percent / 100 ))
        local color_esc="\033[38;2;${r_now};${g_now};${b_now}m"

        local filled_count=$(( bar_max * percent / 100 ))
        local blocks="${bar_source:0:filled_count}"
        local spaces="${empty_source:0:$((bar_max - filled_count))}"

        # Line 1: Header
        printf "\r\033[K%${margin}s ${color_esc}%3d%% %s\033[0m\n" "" "$percent" "$label"
        # Line 2: The Bar
        printf "\033[K%${margin}s${color_esc}%s\033[38;2;60;60;60m%s\033[0m" "" "$blocks" "$spaces"

        local lines_to_reset=1 # Current line is Line 2, so we need to move up 1 line to get back to Line 1

        if $tagged; then
            # Line 3: Status Message
            printf "\n\033[K%${margin}s \033[1;34m➜\033[0m %s" "" "$status_msg"
            lines_to_reset=$((lines_to_reset + 1))

            # Lines 4+: Scrolling Logs
            for ((i=0; i<log_height; i++)); do
                printf "\n\033[K%${margin}s \033[2m│ %b\033[0m" "" "${log_buffer[i]}"
                lines_to_reset=$((lines_to_reset + 1))
            done
        fi

        [[ $percent -ge 100 ]] && break
        printf "\033[%dA" "$lines_to_reset" # Return to Line 1 start
        sleep 0.016
    done
    
    # Release: Just move to the next line since we are already at the bottom
    printf "\n"
}
