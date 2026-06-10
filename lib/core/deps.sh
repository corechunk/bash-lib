# Verify if a list of dependency functions exist in the environment
# Usage: bl_check_deps "caller_func" "dep1" "dep2" ...
bl_check_deps() {
    local caller="$1"
    shift
    local missing=0
    for dep in "$@"; do
        if ! declare -f "$dep" >/dev/null; then
            echo -e "\033[1;31m[ERROR]\033[0m $caller: Missing dependency '\033[1;33m$dep\033[0m'" >&2
            missing=1
        fi
    done
    return $missing
}
