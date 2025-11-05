#!/bin/bash

# Null Sector Installer
# One-click installation script

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════╗"
echo "║           Null Sector                ║"
echo "║         Installer v3.0              ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"

install_tool() {
    echo -e "${BLUE}[*] Downloading Null Sector...${NC}"
    
    # Download the main script
    if curl -fsSL -o nullsector_temp.sh "https://raw.githubusercontent.com/Null-Sector2025/Null-Sector/main/nullSector.sh"; then
        echo -e "${GREEN}[✓] Download successful${NC}"
    else
        echo -e "${RED}[✗] Download failed${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[*] Installing...${NC}"
    chmod +x nullsector_temp.sh
    mkdir -p $PREFIX/bin
    mv nullsector_temp.sh $PREFIX/bin/nullSector
    
    echo -e "${GREEN}[✓] Installation completed!${NC}"
    echo -e "${YELLOW}[!] Usage: nullSector${NC}"
}

main() {
    install_tool
}

main "$@"