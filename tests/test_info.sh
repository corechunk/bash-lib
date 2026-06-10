#!/usr/bin/env bash
# Test script for bash-lib diagnostics checking

# Source files starting from repo root
source lib/core/registry.sh
source lib/core/deps.sh
source lib/core/colors.sh
source lib/ui/progress_bars.sh
source lib/info/diagnostics.sh
source lib/info/tutor.sh

echo "Running Diagnostics check..."
bl_info_check
