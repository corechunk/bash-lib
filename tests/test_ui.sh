#!/usr/bin/env bash
# Test script for bash-lib UI component loading and execution

# Source files starting from repo root
source lib/core/registry.sh
source lib/core/deps.sh
source lib/core/colors.sh
source lib/ui/progress_bars.sh

echo "=== Testing Linear Progress Bar ==="
for i in {1..100}; do
    echo "$i"
    sleep 0.02
done | bl_progress_bar -l "Download Module" --start "FF0000" --end "00FF00"

echo -e "\n=== Testing Tagged Mode (Mode B) ==="
(
    echo "M:Starting database migration..."
    echo "P:10"
    sleep 0.3
    echo "L:Reading schema definitions..."
    echo "P:30"
    sleep 0.3
    echo "L:Applying migration V1_initial..."
    echo "M:Applying schema changes..."
    echo "P:50"
    sleep 0.3
    echo "L:Inserting default seed data..."
    echo "P:70"
    sleep 0.3
    echo "L:Rebuilding database indexes..."
    echo "M:Finalizing..."
    echo "P:90"
    sleep 0.3
    echo "L:Database migration completed successfully."
    echo "P:100"
) | bl_progress_bar -t -l "Migration" --start "0000FF" --end "00FF00" --log-height 3

echo -e "\n=== Testing Missing Dependency Guard ==="
# Temporarily unset the dependency to trigger the guard
unset -f bl_hex_to_rgb
bl_progress_bar

