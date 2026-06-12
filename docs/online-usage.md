# 🌐 Online Sourcing Showcase

This guide demonstrates different patterns for sourcing library components dynamically from remote URLs.

## 1. Sourcing Individual Files via curl
You can fetch and source specific files directly using process substitution without local storage:

```bash
# Sourcing the core importer alone
source <(curl -fsSL https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/core/import.sh)

# Sourcing diagnostics utility individually via curl (optional include)
source <(curl -fsSL https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/info/diagnostics.sh)

# Sourcing tutor utility individually via curl (optional include)
source <(curl -fsSL https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/info/tutor.sh)
```

## 2. Sourcing All Files Dynamically
Initialize the importer and source the entire library matching all files:

```bash
# Source importer and import all modules dynamically
source <(curl -fsSL https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/core/import.sh)
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
bl_import "core/deps.sh"
bl_import "core/import.sh"

# Sourcing Info/Diagnostics components
bl_import "info/diagnostics.sh"
bl_import "info/tutor.sh"

# Sourcing UI components
bl_import "ui/progress_bars.sh"   # bl_progress_bar, bl_square_progress, bl_spiral_progress, bl_terrain_loader
bl_import "ui/matrix_filler.sh"   # bl_matrix_filler
```

## 5. Using bl_terrain_loader
After sourcing `ui/progress_bars.sh`, pipe progress values (0-100) to `bl_terrain_loader`:

```bash
source <(curl -fsSL https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/core/import.sh)
bl_import "ui/progress_bars.sh"

# Random pattern (default)
for i in {1..100}; do echo "$i"; sleep 0.02; done | bl_terrain_loader -l "Loading World..."

# Full-screen Minecraft-style chunk loading
for i in {1..100}; do echo "$i"; sleep 0.02; done | bl_terrain_loader --minecraft -fw -fh --color-mode time
```

