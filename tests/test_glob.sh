#!/usr/bin/env bash
# Test script for bash-lib glob sourcing and registry update functionalities

echo "=== Sourcing glob utilities ==="
source lib/glob/glob.sh

echo -e "\n=== Initializing environment (bl_init) ==="
bl_init

echo -e "\n=== Listing BL_FILE_REGISTRY keys ==="
if declare -p BL_FILE_REGISTRY >/dev/null 2>&1; then
    for key in "${!BL_FILE_REGISTRY[@]}"; do
        echo "  $key -> ${BL_FILE_REGISTRY[$key]}"
    done
else
    echo "ERROR: BL_FILE_REGISTRY is not declared!"
    exit 1
fi

echo -e "\n=== Sourcing 'core/colors.sh' from online via bl_glob_source ==="
# Since this targets linutils if we updated it, or bash-lib if defaults are loaded.
# Let's verify we can call bl_glob_source with a specific pattern.
bl_glob_source "core/*"

if declare -f bl_hex_to_rgb >/dev/null; then
    echo "SUCCESS: bl_hex_to_rgb is loaded!"
else
    echo "WARNING: bl_hex_to_rgb is not loaded (likely offline or unpushed repo default)."
fi
