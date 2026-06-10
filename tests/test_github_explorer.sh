#!/usr/bin/env bash
# Wrapper to test the github.com/corechunk repository list and tree explorer

# Get script folder
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

if [ -f "$SCRIPT_DIR/github_explorer.py" ]; then
    python3 "$SCRIPT_DIR/github_explorer.py" "$@"
else
    echo "Error: github_explorer.py not found in $SCRIPT_DIR"
    exit 1
fi
