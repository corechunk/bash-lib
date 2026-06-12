#!/usr/bin/env bash

# Rule: This function has dependencies — bl_check_deps is called as the first statement.
bl_matrix_filler() {
    # System commands don't strictly need bl_check_deps unless we want strict enforcing, 
    # but we'll add tput just in case.
    bl_check_deps "bl_matrix_filler" "tput" || return 1

    local cols
    local lines
    cols=$(tput cols)
    lines=$(tput lines)

    # Handle window resize
    trap 'cols=$(tput cols); lines=$(tput lines)' WINCH
    
    # Cleanup on exit
    trap 'tput sgr0; tput cnorm; clear; trap - WINCH INT TERM RETURN; return' INT TERM RETURN

    tput civis
    tput setaf 2 # Green
    clear

    # Arrays to store drop positions
    local -a drops
    local -a speeds
    local i
    for ((i=0; i<cols; i++)); do
        drops[i]=0
        speeds[i]=$((RANDOM % 3 + 1))
    done

    local chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()_+{}[]"
    local char_len=${#chars}

    while true; do
        for ((i=0; i<cols; i++)); do
            # Randomly start a new drop
            if (( drops[i] == 0 && RANDOM % 50 == 0 )); then
                drops[i]=1
                speeds[i]=$((RANDOM % 3 + 1))
            fi

            if (( drops[i] > 0 )); then
                # Move the drop down according to its speed
                if (( RANDOM % speeds[i] == 0 )); then
                    # Get a random character
                    local rand_char="${chars:RANDOM%char_len:1}"

                    # Print trailing space (erase)
                    local tail=$((drops[i] - 10 - RANDOM%10))
                    if (( tail > 0 && tail <= lines )); then
                        tput cup $tail $i
                        echo -n " "
                    fi

                    # Print leading character (white/bright green)
                    if (( drops[i] <= lines )); then
                        tput cup ${drops[i]} $i
                        tput bold; tput setaf 7 # White
                        echo -n "$rand_char"
                    fi

                    # Print middle character (normal green)
                    local mid=$((drops[i] - 1))
                    if (( mid > 0 && mid <= lines )); then
                        tput cup $mid $i
                        tput sgr0; tput setaf 2 # Green
                        echo -n "$rand_char"
                    fi

                    ((drops[i]++))

                    # Reset drop if it goes off screen
                    if (( drops[i] > lines + 20 )); then
                        drops[i]=0
                    fi
                fi
            fi
        done
        
        # Check for user input to exit
        read -t 0.05 -n 1 && break
    done
    
    tput sgr0
    tput cnorm
    clear
    trap - WINCH INT TERM RETURN
}
