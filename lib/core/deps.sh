# Verify that all listed dependencies exist in the environment.
# Handles both shell functions (declare -f) and system commands (command -v).
# Usage: bl_check_deps "caller_func" "dep1" "dep2" ...
# Rule:  Any function with dependencies MUST call bl_check_deps as its first statement.
bl_check_deps() {
    local caller="$1"
    shift
    local missing=0
    for dep in "$@"; do
        if ! declare -f "$dep" >/dev/null 2>&1 && ! command -v "$dep" >/dev/null 2>&1; then
            echo -e "\033[1;31m[ERROR]\033[0m $caller: Missing dependency '\033[1;33m$dep\033[0m'" >&2
            missing=1
        fi
    done
    return $missing
}
