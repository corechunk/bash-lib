#!/usr/bin/env bash
# Interactive test script for bash-lib info menu explorer

# Source files starting from repo root
source lib/core/registry.sh
source lib/core/deps.sh
source lib/core/colors.sh
source lib/ui/progress_bars.sh
source lib/info/diagnostics.sh
source lib/info/tutor.sh

echo "Launching bash-lib Interactive Explorer Menu..."
sleep 0.5
bl_info_menu
