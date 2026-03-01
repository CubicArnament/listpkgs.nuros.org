#!/bin/bash
# =============================================================================
# check-apparmor-audit.sh - Check AppArmor Denials
# =============================================================================
# This script checks for AppArmor denials related to the
# container-nuros-strict profile.
#
# Usage:
#   ./check-apparmor-audit.sh [time_range]
#
# Time ranges:
#   today     - Last 24 hours (default)
#   recent    - Last 10 minutes
#   current   - Current session
#   boot      - Since last boot
#   <date>    - Specific date (YYYY-MM-DD)
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROFILE="container-nuros-strict"

# Get time range argument
TIME_RANGE="${1:-today}"

# Header
echo "========================================"
echo "  AppArmor Denials Check"
echo "  Profile: $PROFILE"
echo "  Time range: $TIME_RANGE"
echo "========================================"
echo ""

# Check if auditd is available
if ! command -v ausearch &> /dev/null; then
    echo -e "${RED}ERROR: ausearch not found. Install auditd first.${NC}"
    echo "  sudo apt install auditd"
    exit 1
fi

# Build ausearch command
case $TIME_RANGE in
    today)
        SEARCH_CMD="ausearch -m apparmor_denied -ts today"
        ;;
    recent)
        SEARCH_CMD="ausearch -m apparmor_denied -ts recent"
        ;;
    current)
        SEARCH_CMD="ausearch -m apparmor_denied -ts current"
        ;;
    boot)
        SEARCH_CMD="ausearch -m apparmor_denied -ts boot"
        ;;
    *)
        SEARCH_CMD="ausearch -m apparmor_denied -ts $TIME_RANGE"
        ;;
esac

# Execute search and filter by profile
DENIALS=$($SEARCH_CMD 2>/dev/null | grep "$PROFILE" || echo "")

if [ -z "$DENIALS" ]; then
    echo -e "${GREEN}✓ No denials found${NC}"
    echo ""
    echo "The container-nuros-strict profile is working correctly."
    exit 0
fi

# Display denials
echo -e "${RED}=== AppArmor Denials ===${NC}"
echo ""
echo "$DENIALS"
echo ""

# Count and summarize
COUNT=$(echo "$DENIALS" | grep -c "DENIED" || echo "0")
echo "========================================"
echo -e "${RED}Total denials: $COUNT${NC}"
echo "========================================"
echo ""

# Show summary by operation type
echo "=== Summary by Operation ==="
echo "$DENIALS" | grep -oP 'operation="\K[^"]+' | sort | uniq -c | sort -rn
echo ""

# Show summary by requested capability
echo "=== Summary by Requested Capability ==="
echo "$DENIALS" | grep -oP 'requested="\K[^"]+' | sort | uniq -c | sort -rn
echo ""

# Recommendations
echo "=== Recommendations ==="
if echo "$DENIALS" | grep -q "dac_override"; then
    echo -e "${YELLOW}⚠ dac_override denials detected${NC}"
    echo "  This is expected - the profile blocks this dangerous capability."
    echo "  Review application code if this is causing issues."
    echo ""
fi

if echo "$DENIALS" | grep -q "ptrace"; then
    echo -e "${YELLOW}⚠ ptrace denials detected${NC}"
    echo "  This is expected - debugging is blocked for security."
    echo ""
fi

if echo "$DENIALS" | grep -q "/tmp/.*ix"; then
    echo -e "${YELLOW}⚠ /tmp execution denials detected${NC}"
    echo "  Applications cannot execute from /tmp (security feature)."
    echo "  Move executables to /app or /usr/bin."
    echo ""
fi

echo "For detailed analysis, run:"
echo "  sudo ausearch -m apparmor_denied -ts $TIME_RANGE | grep $PROFILE"
echo ""

# Exit with error if denials found
exit 1
