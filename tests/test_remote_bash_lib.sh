#!/usr/bin/env bash
# Verification script: Test sourcing diagnostics first, run checks, load all, and check again.

echo "=== Sourcing glob.sh ==="
source lib/glob/glob.sh

echo "=== Initializing environment ==="
bl_init

echo -e "\n=== 1. Sourcing ONLY the info checker from online ==="
bl_glob_source "info/*"

echo -e "\n=== 2. Running diagnostics (First Run - should show missing modules) ==="
bl_info_check

echo -e "\n=== 3. Sourcing ALL functions from online ==="
bl_glob_source "*"

echo -e "\n=== 4. Running diagnostics (Second Run - should show everything loaded) ==="
bl_info_check
