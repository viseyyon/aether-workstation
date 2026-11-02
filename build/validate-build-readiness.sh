#!/usr/bin/env bash
set -euo pipefail

# AETHER AI Workstation - Pre-Build Validation
# Validates all requirements before production build

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USB_TARGET="${1:-/Volumes/AETHER USB}"
ERRORS=0
WARNINGS=0

echo "═══════════════════════════════════════════════════════════"
echo "   AETHER AI Workstation - Pre-Build Validation"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Logging functions
log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}  ✓${NC} $1"
}

log_fail() {
    echo -e "${RED}  ✗${NC} $1"
    ((ERRORS++))
}

log_warn() {
    echo -e "${YELLOW}  ⚠${NC} $1"
    ((WARNINGS++))
}

echo "Target USB: $USB_TARGET"
echo ""

#═══════════════════════════════════════════════════════════
# Test 1: Build Script
#═══════════════════════════════════════════════════════════

log_test "Validating build script..."

if [ -f "$SCRIPT_DIR/build-enterprise-workstation.sh" ]; then
    log_pass "Build script exists"
    if [ -x "$SCRIPT_DIR/build-enterprise-workstation.sh" ]; then
        log_pass "Build script is executable"
    else
        log_fail "Build script is not executable"
    fi
else
    log_fail "Build script not found"
fi

#═══════════════════════════════════════════════════════════
# Test 2: Source Files
#═══════════════════════════════════════════════════════════

log_test "Validating source files..."

# Skills directory
if [ -d "$SCRIPT_DIR/skills" ]; then
    SKILL_COUNT=$(find "$SCRIPT_DIR/skills" -name "SKILL.md" | wc -l | tr -d ' ')
    log_pass "Skills directory exists ($SKILL_COUNT skills)"
else
    log_fail "Skills directory not found"
fi

# ClaudeCode-Portable
if [ -d "$SCRIPT_DIR/analysis/ClaudeCode-Portable" ]; then
    log_pass "ClaudeCode-Portable source exists"
    if [ -f "$SCRIPT_DIR/analysis/ClaudeCode-Portable/lib/adapter.mjs" ]; then
        log_pass "ClaudeCode-Portable core files present"
    else
        log_warn "ClaudeCode-Portable may be incomplete"
    fi
else
    log_fail "ClaudeCode-Portable source not found"
fi

# web-design (AETHER Vision)
if [ -d "$SCRIPT_DIR/analysis/web-design" ]; then
    log_pass "AETHER Vision (web-design) source exists"
    DESIGN_COUNT=$(find "$SCRIPT_DIR/analysis/web-design/references/design-systems" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    log_pass "Design systems found: $DESIGN_COUNT"
else
    log_warn "AETHER Vision (web-design) source not found"
fi

#═══════════════════════════════════════════════════════════
# Test 3: Branded Assets
#═══════════════════════════════════════════════════════════

log_test "Validating branded assets..."

if [ -f "$SCRIPT_DIR/brand/AETHER-START.sh" ]; then
    log_pass "AETHER branded launcher exists"
    if [ -x "$SCRIPT_DIR/brand/AETHER-START.sh" ]; then
        log_pass "AETHER launcher is executable"
    else
        log_warn "AETHER launcher not executable (will be fixed during build)"
    fi
else
    log_fail "AETHER branded launcher not found"
fi

if [ -f "$SCRIPT_DIR/brand/AETHER-README.txt" ]; then
    SIZE=$(wc -c < "$SCRIPT_DIR/brand/AETHER-README.txt" | tr -d ' ')
    log_pass "AETHER README exists ($SIZE bytes)"
else
    log_fail "AETHER README not found"
fi

if [ -f "$SCRIPT_DIR/brand/logo-ascii.txt" ]; then
    log_pass "AETHER logo assets exist"
else
    log_warn "AETHER logo assets not found (optional)"
fi

if [ -f "$SCRIPT_DIR/BRAND-IDENTITY.md" ]; then
    log_pass "Brand identity guide exists"
else
    log_warn "Brand identity guide not found (optional)"
fi

#═══════════════════════════════════════════════════════════
# Test 4: Documentation
#═══════════════════════════════════════════════════════════

log_test "Validating documentation..."

DOC_COUNT=0
for doc in \
    ENTERPRISE-AI-WORKSTATION.md \
    WEB-DESIGN-INTEGRATION.md \
    MEMORY-STANDARD.md \
    REA-INDEPENDENT-ARCHITECTURE.md \
    REA-ROUTER-INTEGRATION.md \
    BUILD-WITH-REA-COMPLETE.md \
    BRANDING-COMPLETE.md
do
    if [ -f "$SCRIPT_DIR/$doc" ]; then
        ((DOC_COUNT++))
    fi
done

log_pass "Documentation files: $DOC_COUNT found"

#═══════════════════════════════════════════════════════════
# Test 5: USB Drive
#═══════════════════════════════════════════════════════════

log_test "Validating USB drive..."

if [ -d "$USB_TARGET" ]; then
    log_pass "USB drive mounted at $USB_TARGET"

    # Check if writable
    if touch "$USB_TARGET/.write-test" 2>/dev/null; then
        rm "$USB_TARGET/.write-test"
        log_pass "USB drive is writable"
    else
        log_fail "USB drive is not writable"
    fi

    # Check space
    AVAILABLE=$(df -h "$USB_TARGET" | tail -1 | awk '{print $4}')
    log_pass "Available space: $AVAILABLE"

    # Get size in GB
    AVAILABLE_GB=$(df -g "$USB_TARGET" | tail -1 | awk '{print $4}')
    if [ "$AVAILABLE_GB" -lt 1 ]; then
        log_fail "Insufficient space (need at least 1 GB)"
    else
        log_pass "Sufficient space for build"
    fi
else
    log_fail "USB drive not found at $USB_TARGET"
fi

#═══════════════════════════════════════════════════════════
# Test 6: System Tools
#═══════════════════════════════════════════════════════════

log_test "Validating system tools..."

# Required tools
if command -v cp &> /dev/null; then
    log_pass "cp command available"
else
    log_fail "cp command not found"
fi

if command -v find &> /dev/null; then
    log_pass "find command available"
else
    log_fail "find command not found"
fi

if command -v chmod &> /dev/null; then
    log_pass "chmod command available"
else
    log_fail "chmod command not found"
fi

# Optional tools
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    log_pass "Node.js available: $NODE_VERSION"
else
    log_warn "Node.js not installed (will auto-download on first run)"
fi

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    log_pass "Python available: $PYTHON_VERSION"
else
    log_warn "Python not installed (optional for AETHER Vision tools)"
fi

if command -v ollama &> /dev/null; then
    OLLAMA_VERSION=$(ollama --version 2>&1)
    log_pass "Ollama available: $OLLAMA_VERSION"
else
    log_warn "Ollama not installed (optional for local AI)"
fi

if command -v rea &> /dev/null; then
    REA_VERSION=$(rea --version 2>&1 | head -1)
    log_pass "REA available: $REA_VERSION"
else
    log_warn "REA not installed globally (will install to USB)"
fi

#═══════════════════════════════════════════════════════════
# Test 7: Memory & Configuration
#═══════════════════════════════════════════════════════════

log_test "Validating memory and configuration..."

if [ -d "$HOME/Documents/repo-memory" ]; then
    MEMORY_SIZE=$(du -sh "$HOME/Documents/repo-memory" 2>/dev/null | awk '{print $1}')
    log_pass "AETHER Memory (repo-memory) exists: $MEMORY_SIZE"
else
    log_warn "repo-memory not found (will create empty structure)"
fi

if [ -d "$HOME/mcp-servers/repo-memory" ]; then
    log_pass "repo-memory MCP server exists"
else
    log_warn "repo-memory MCP server not found (optional)"
fi

#═══════════════════════════════════════════════════════════
# Test 8: REA Components
#═══════════════════════════════════════════════════════════

log_test "Validating REA components..."

if [ -f "$SCRIPT_DIR/install-rea-to-usb.sh" ]; then
    log_pass "REA installer script exists"
else
    log_warn "REA installer script not found (will use build script method)"
fi

if [ -d "$HOME/mcp-servers/rea" ]; then
    log_pass "REA MCP server exists globally"
else
    log_warn "REA MCP server not installed globally (will install to USB)"
fi

#═══════════════════════════════════════════════════════════
# Test 9: Disk Space Calculation
#═══════════════════════════════════════════════════════════

log_test "Calculating required space..."

TOTAL_SIZE=0

# Skills
if [ -d "$SCRIPT_DIR/skills" ]; then
    SKILLS_SIZE=$(du -sm "$SCRIPT_DIR/skills" 2>/dev/null | awk '{print $1}')
    TOTAL_SIZE=$((TOTAL_SIZE + SKILLS_SIZE))
    log_pass "Skills size: ${SKILLS_SIZE}MB"
fi

# ClaudeCode-Portable
if [ -d "$SCRIPT_DIR/analysis/ClaudeCode-Portable" ]; then
    PORTABLE_SIZE=$(du -sm "$SCRIPT_DIR/analysis/ClaudeCode-Portable" 2>/dev/null | awk '{print $1}')
    TOTAL_SIZE=$((TOTAL_SIZE + PORTABLE_SIZE))
    log_pass "ClaudeCode-Portable size: ${PORTABLE_SIZE}MB"
fi

# web-design
if [ -d "$SCRIPT_DIR/analysis/web-design" ]; then
    VISION_SIZE=$(du -sm "$SCRIPT_DIR/analysis/web-design" 2>/dev/null | awk '{print $1}')
    TOTAL_SIZE=$((TOTAL_SIZE + VISION_SIZE))
    log_pass "AETHER Vision size: ${VISION_SIZE}MB"
fi

log_pass "Estimated build size: ${TOTAL_SIZE}MB"

#═══════════════════════════════════════════════════════════
# Test 10: Branding Verification
#═══════════════════════════════════════════════════════════

log_test "Validating AETHER branding..."

# Check build script for AETHER branding
if grep -q "AETHER" "$SCRIPT_DIR/build-enterprise-workstation.sh" &>/dev/null; then
    log_pass "Build script contains AETHER branding"
else
    log_fail "Build script missing AETHER branding"
fi

# Check for Claude/Anthropic references (should be zero in branded files)
if grep -q "Claude Code" "$SCRIPT_DIR/brand/AETHER-README.txt" &>/dev/null; then
    log_warn "Found Claude references in AETHER README"
else
    log_pass "No Claude references in AETHER README"
fi

if grep -q "AETHER" "$SCRIPT_DIR/brand/AETHER-START.sh" &>/dev/null; then
    log_pass "Launcher contains AETHER branding"
else
    log_fail "Launcher missing AETHER branding"
fi

#═══════════════════════════════════════════════════════════
# Summary
#═══════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "   Validation Summary"
echo "═══════════════════════════════════════════════════════════"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "Status: READY FOR PRODUCTION BUILD"
    echo ""
    EXIT_CODE=0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Passed with warnings${NC}"
    echo ""
    echo "Errors:   0"
    echo "Warnings: $WARNINGS"
    echo ""
    echo "Status: READY (with optional components missing)"
    echo ""
    EXIT_CODE=0
else
    echo -e "${RED}✗ Validation failed${NC}"
    echo ""
    echo "Errors:   $ERRORS"
    echo "Warnings: $WARNINGS"
    echo ""
    echo "Status: NOT READY - Fix errors before building"
    echo ""
    EXIT_CODE=1
fi

echo "═══════════════════════════════════════════════════════════"
echo ""

if [ $EXIT_CODE -eq 0 ]; then
    echo "Ready to build:"
    echo "  ./build-enterprise-workstation.sh \"$USB_TARGET\" yes yes yes"
    echo ""
fi

exit $EXIT_CODE
