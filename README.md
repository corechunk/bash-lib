# 🌟 bash-lib

A premium, lightweight, dependency-free Bash framework for modular scripting. `bash-lib` allows you to load tools, UI elements, and diagnostics dynamically directly in-memory from remote URLs—giving your scripts zero local installation overhead.

---

## 🚀 One-Line Bootstrap Header

To use this library in any script, simply add this bootstrap header at the top of your project file:

```bash
# Bootstrap bash-lib directly in-memory
source <(curl -fsSL https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/glob/glob.sh) && bl_init
```

---

## 🛠️ Usage Examples

### 1. Load Everything
If you want to import all utilities (UI, diagnostics, async helpers, etc.) instantly:
```bash
#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/glob/glob.sh) && bl_init

# Slices and sources all scripts from online
bl_glob_source "*"

# Run a progress bar component immediately
for i in {1..100}; do echo "$i"; sleep 0.01; done | bl_progress_bar -l "Syncing Data"
```

### 2. Load by Category (On-Demand)
Keep your footprint tiny by loading only specific directories (e.g. `ui`, `core`, `info`):
```bash
#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/glob/glob.sh) && bl_init

# Sourced selectively
bl_glob_source "ui/*"

# Your code
```

### 3. Run Environment Diagnostics
Sourcing the info checker helps inspect your current loaded environment variables and functions:
```bash
#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/glob/glob.sh) && bl_init

# Source diagnostics
bl_glob_source "info/*"

# Check loaded modules
bl_info_check
```

---

## ⚙️ Features
* **In-Memory Loading**: Sources remote script components dynamically via process substitution. No local directory contamination or configuration files left behind.
* **Namespace Diagnostics**: Dynamic verification checker `bl_info_check` scans shell memory to identify missing library dependencies.
* **Updater Module**: Rebuilds the remote registry maps by scanning the repository tree dynamically (`bl_file_registry_update`).
