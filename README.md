# 🌟 bash-lib

A premium, lightweight, dependency-free Bash library for modular scripting. Load UI elements, async processes, and diagnostic utilities instantly, directly in-memory from remote URLs or local clones.

---

## 🚀 Quick Start (Online Sourcing)

To source remote modules dynamically directly in-memory without installing anything locally:

```bash
# 1. Source the importer
source <(curl -fsSL https://raw.githubusercontent.com/corechunk/bash-lib/main/lib/core/import.sh)

# 2. Sourced selectively on-demand (e.g. only UI progress bars)
bl_import "ui/*"

# 3. Use the components
for i in {1..100}; do echo "$i"; sleep 0.01; done | bl_progress_bar -l "Syncing Data"
```

### 💡 Optional Diagnostics & Tutorials (Online)
You can optionally pull down only diagnostics or the interactive tutorial:

```bash
# Sourcing the environment check diagnostics (Optional Include)
bl_import "info/diagnostics.sh" && bl_info_check

# Sourcing the interactive tutor lessons guide (Optional Include)
bl_import "info/tutor.sh" && bl_bash_tutor
```

---

## 📦 Local Sourcing

If you prefer to source files locally from your clone:

```bash
# 1. Clone the repository
git clone https://github.com/corechunk/bash-lib.git
cd bash-lib

# 2. Source the importer and core modules in your script
source lib/core/import.sh
source lib/core/colors.sh
source lib/core/deps.sh

# 3. Optionally source diagnostics, tutors, or UI modules individually
source lib/info/diagnostics.sh   # Run bl_info_check
source lib/info/tutor.sh         # Run bl_bash_tutor
source lib/ui/progress_bars.sh   # Run bl_progress_bar
```

---

## 📚 Documentation & Reference

*   [API Reference & Module Map](docs/api-reference.md) — Comprehensive variables and functions checklist.
*   [Local Sourcing Showcase](docs/local-usage.md) — How to source library files locally.
*   [Online Sourcing Showcase](docs/online-usage.md) — Comprehensive guide to curl and glob sourcing online.
