#!/usr/bin/env bash
# .harness/run-gates.sh — Run all enabled QA gates for nanoclaw
#
# Delegates to nanoclaw's native TypeScript toolchain (pnpm).
# Gates are named to align with the harness convention but map to
# native TS commands rather than Python equivalents.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

run_gate() {
    local name="$1"
    local label="$2"
    local cmd="$3"
    printf "  %-18s ... " "$label"
    if (cd "$PROJECT_ROOT" && eval "$cmd") 2>&1; then
        printf "${GREEN}PASS${NC}\n"
        PASS=$((PASS + 1))
    else
        printf "${RED}FAIL${NC}\n"
        FAIL=$((FAIL + 1))
    fi
}

echo ""
echo "=== nanoclaw QA Gates ==="
echo ""

run_gate "gate_a" "format (prettier)" "pnpm format:check"
run_gate "gate_b" "typecheck (tsc)"   "pnpm typecheck"
run_gate "gate_c" "tests (vitest)"    "pnpm test"

echo ""
echo "=== Results ==="
echo -e "  ${GREEN}PASS: $PASS${NC}  ${RED}FAIL: $FAIL${NC}"
echo ""

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
