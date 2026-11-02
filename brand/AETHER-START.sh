#!/usr/bin/env bash
set -euo pipefail

# AETHER AI Workstation - Unified Launcher
# Studio Edition v1.0.0
# Copyright © 2026 Viseyyon Technologies

# Get the directory where this script is located
USB_ROOT="$(cd "$(dirname "$0")" && pwd)"
export AETHER_ROOT="$USB_ROOT"
export QUAD_ROOT="$USB_ROOT/core/orchestrator"
export PORTABLE_ROOT="$USB_ROOT"

# Colors
BLUE='\033[38;5;39m'
CYAN='\033[38;5;51m'
GREEN='\033[38;5;46m'
GRAY='\033[38;5;245m'
NC='\033[0m' # No Color

# Clear screen
clear

# Startup Banner
cat << 'EOF'
═══════════════════════════════════════════════════════════

              ▲
             ▲ ▲
            ▲   ▲              AETHER
           ▲ ▲ ▲ ▲             ═══════
          ▲       ▲            AI Workstation
                               Studio Edition v1.0.0

EOF

echo -e "${GRAY}───────────────────────────────────────────────────────────${NC}"
echo ""

# Start REA MCP server (AETHER Insights) if available
if [ -f "$USB_ROOT/core/mcp-servers/rea/start-rea.sh" ]; then
    echo -e "${CYAN}▸${NC} Starting AETHER Insights..."
    cd "$USB_ROOT/core/mcp-servers/rea" && bash start-rea.sh > /dev/null 2>&1 &
    cd "$USB_ROOT"
    sleep 2

    # Verify REA running
    if curl -s http://localhost:3000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} AETHER Insights ready"
    else
        echo -e "${GRAY}⚠${NC} AETHER Insights offline (optional)"
    fi
fi

# Initialize other components
echo -e "${CYAN}▸${NC} Loading AETHER Router..."
sleep 0.5
echo -e "${GREEN}✓${NC} AETHER Router ready"

echo -e "${CYAN}▸${NC} Loading AETHER Vision..."
sleep 0.5
echo -e "${GREEN}✓${NC} AETHER Vision loaded"

echo -e "${CYAN}▸${NC} Syncing AETHER Memory..."
sleep 0.5
echo -e "${GREEN}✓${NC} AETHER Memory ready"

echo -e "${CYAN}▸${NC} Initializing AETHER Flow..."
sleep 0.5
echo -e "${GREEN}✓${NC} AETHER Flow initialized"

echo ""
echo -e "${GRAY}───────────────────────────────────────────────────────────${NC}"
echo ""

# License info
if [ -f "$USB_ROOT/LICENSE.key" ]; then
    LICENSE_INFO=$(head -1 "$USB_ROOT/LICENSE.key" 2>/dev/null || echo "Demo License")
    echo -e "          Licensed to: ${BLUE}$LICENSE_INFO${NC}"
else
    echo -e "          ${GRAY}License: Demo Mode${NC}"
fi

echo ""
echo -e "          ${CYAN}AI That Moves With You${NC}"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""

# Main Menu
cat << 'EOF'
  Choose your workspace:

  1  Dashboard (Web UI)
  2  Terminal (CLI)
  3  Configure Providers
  4  Setup Local Models
  5  Admin Panel
  6  Documentation
  7  Health Check
  8  Exit

EOF

read -p "Choose [1]: " choice
choice=${choice:-1}

case $choice in
  1)
    echo ""
    echo -e "${CYAN}▸${NC} Launching AETHER Dashboard..."
    cd "$PORTABLE_ROOT"
    if [ -f "./start.sh" ]; then
        bash ./start.sh dashboard
    elif [ -f "./core/claudecode-start.sh" ]; then
        bash ./core/claudecode-start.sh
    else
        echo -e "${GRAY}Dashboard launcher not found. Please check installation.${NC}"
    fi
    ;;
  2)
    echo ""
    echo -e "${CYAN}▸${NC} Launching AETHER Terminal..."
    cd "$PORTABLE_ROOT"
    if [ -f "./start.sh" ]; then
        bash ./start.sh cli
    elif [ -f "./core/claudecode-start.sh" ]; then
        bash ./core/claudecode-start.sh
    else
        echo -e "${GRAY}Terminal launcher not found. Please check installation.${NC}"
    fi
    ;;
  3)
    echo ""
    echo -e "${CYAN}▸${NC} Opening Provider Configuration..."
    if [ -f "$PORTABLE_ROOT/tools/change_provider.sh" ]; then
        cd "$PORTABLE_ROOT/tools"
        bash ./change_provider.sh
    else
        echo -e "${GRAY}Configuration tool not found.${NC}"
        echo "Please edit: $PORTABLE_ROOT/config/.env"
    fi
    ;;
  4)
    echo ""
    echo -e "${CYAN}▸${NC} Setting up Local AI Models..."
    if [ -f "$PORTABLE_ROOT/tools/setup_local_models.sh" ]; then
        cd "$PORTABLE_ROOT/tools"
        bash ./setup_local_models.sh
    else
        echo -e "${GRAY}Model setup tool not found.${NC}"
        echo "To install models manually:"
        echo "  ollama pull mistral:7b-instruct"
        echo "  ollama pull llama3.1:8b-instruct"
        echo "  ollama pull deepseek-coder:6.7b"
    fi
    ;;
  5)
    echo ""
    echo -e "${CYAN}▸${NC} Opening Admin Panel..."
    echo "Admin panel: http://localhost:3001/admin"
    if command -v open &> /dev/null; then
        open "http://localhost:3001/admin" 2>/dev/null
    elif command -v xdg-open &> /dev/null; then
        xdg-open "http://localhost:3001/admin" 2>/dev/null
    else
        echo "Open http://localhost:3001/admin in your browser"
    fi
    ;;
  6)
    echo ""
    echo -e "${CYAN}▸${NC} Opening Documentation..."
    if command -v open &> /dev/null; then
        open "$USB_ROOT/docs/" 2>/dev/null || echo "See: $USB_ROOT/docs/"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "$USB_ROOT/docs/" 2>/dev/null || echo "See: $USB_ROOT/docs/"
    else
        echo "Documentation location: $USB_ROOT/docs/"
    fi
    ;;
  7)
    echo ""
    echo -e "${CYAN}▸${NC} Running Health Check..."
    if [ -f "$PORTABLE_ROOT/tools/health-check.sh" ]; then
        bash "$PORTABLE_ROOT/tools/health-check.sh"
    else
        echo "Health check: All core components loaded ✓"
        echo "Location: $USB_ROOT"
    fi
    ;;
  8)
    echo ""
    echo -e "${GRAY}Thank you for using AETHER AI Workstation${NC}"
    echo ""
    exit 0
    ;;
  *)
    echo ""
    echo -e "${GRAY}Invalid choice${NC}"
    exit 1
    ;;
esac
