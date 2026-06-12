# 💻 Local Sourcing Showcase

This guide demonstrates how to source library components locally from the project root using the smart `import` wrapper.

## 1. Sourcing Individual Files via local path

You can source specific files directly using the `source` command:

```bash
# Sourcing the core importer alone
source lib/core/import.sh

# Sourcing diagnostics utility individually (optional)
source lib/info/diagnostics.sh

# Sourcing tutor utility individually (optional)
source lib/info/tutor.sh
```

## 2. Sourcing All Files Dynamically

Initialize the importer and source the entire library matching all files:

```bash
# Source importer and import all modules dynamically
source lib/core/import.sh
bl_import "*"
```

## 3. Sourcing Categories/Folders

Source groups of modules using category glob patterns:

```bash
# Source everything inside the ui/ category
bl_import "ui/*"

# Source everything inside the info/ category
bl_import "info/*"
```

## 4. Sourcing Specific Files under a Category Individually

You can source each specific file under its respective category individually using glob patterns:

```bash
# Sourcing Core components
bl_import "core/colors.sh"
bl_import "core/import.sh"

# Sourcing Info/Diagnostics components
bl_import "info/diagnostics.sh"
bl_import "info/tutor.sh"

# Sourcing UI components
bl_import "ui/progress_bars.sh"   # bl_progress_bar, bl_square_progress, bl_spiral_progress, bl_terrain_loader
bl_import "ui/matrix_filler.sh"   # bl_matrix_filler
```

## 5. Using bl_terrain_loader Locally

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

## 6. All File Includes

```bash
# Core importer
source lib/core/import.sh
# UI components
bl_import "ui/progress_bars.sh"
bl_import "ui/matrix_filler.sh"
# Info components
bl_import "info/diagnostics.sh"
bl_import "info/tutor.sh"
```

