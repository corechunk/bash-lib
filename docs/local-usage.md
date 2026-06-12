# 💻 Local Sourcing Showcase

This guide demonstrates how to intelligently source files locally from the project root using our smart `import` wrapper.

## Sourcing Files Dynamically
Instead of manually sourcing files and risking duplicates or missing dependencies, simply source the core loader and use the `import` command to handle everything else!

```bash
#!/usr/bin/env bash

# 1. Source the core importer
source lib/core/import.sh

# 2. Dynamically import the entire library (recursively loads all components)
import lib/*

# Or import specific components or directories seamlessly:
import lib/ui/* lib/info/diagnostics.sh
```

## Using bl_terrain_loader Locally
`bl_terrain_loader` is included in `lib/ui/progress_bars.sh`. Once sourced, pipe numbers 0–100 into it:

```bash
source lib/core/import.sh
import lib/ui/progress_bars.sh

# Default random fill with yellow→cyan gradient
for i in {1..100}; do echo "$i"; sleep 0.02; done | bl_terrain_loader -l "Building..."

# Full-screen Minecraft-style chunk loading
for i in {1..100}; do echo "$i"; sleep 0.02; done | bl_terrain_loader --minecraft -fw -fh

# Custom gradient (blue → red), center-out pattern
for i in {1..100}; do echo "$i"; sleep 0.02; done | \
    bl_terrain_loader --pattern center-out --color-mode time --start "#0000FF" --end "#FF0000"
```

