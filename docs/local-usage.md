# 💻 Local Sourcing Showcase

This guide demonstrates how to source files locally from the project root individually.

## Sourcing All Files Individually
To import the library components directly from a local clone, source the core loader (`import.sh`) followed by the other modules:

```bash
#!/usr/bin/env bash

# 1. Source the core importer and core utilities
source lib/core/import.sh
source lib/core/colors.sh
source lib/core/deps.sh

# 2. Source optional utility & info modules
source lib/info/diagnostics.sh
source lib/info/tutor.sh
source lib/ui/progress_bars.sh
```
