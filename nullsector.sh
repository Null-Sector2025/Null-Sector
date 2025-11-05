#!/bin/bash

# Null Sector - Advanced Device Detection Tool
# GitHub: https://github.com/Null-Sector2025/Null-Sector

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

clear
echo -e "${PURPLE}"
cat << "EOL"
 _   _       _      ____            _             
| \ | |_   _| | ___/ ___|  ___ _ __| |_ _   _ ___ 
|  \| | | | | |/ _ \___ \ / _ \ '__| __| | | / __|
| |\  | |_| | |  __/___) |  __/ |  | |_| |_| \__ \
|_| \_|\__,_|_|\___|____/ \___|_|   \__|\__,_|___/
EOL
echo -e "${WHITE}           Advanced Device Detection v3.0${NC}"
echo -e "${CYAN}=================================================${NC}"
echo ""

# System Information
echo -e "${BLUE}[*] SYSTEM INFORMATION${NC}"
echo -e "${GREEN}Device Model: ${WHITE}$(getprop ro.product.model 2>/dev/null || uname -m)${NC}"
echo -e "${GREEN}Manufacturer: ${WHITE}$(getprop ro.product.manufacturer 2>/dev/null || echo "Unknown")${NC}"
echo -e "${GREEN}Android Version: ${WHITE}$(getprop ro.build.version.release 2>/dev/null || echo "N/A")${NC}"
echo -e "${GREEN}Kernel Version: ${WHITE}$(uname -r)${NC}"
echo -e "${GREEN}Build ID: ${WHITE}$(getprop ro.build.display.id 2>/dev/null || echo "N/A")${NC}"

# Hardware Information
echo -e "\n${BLUE}[*] HARDWARE INFORMATION${NC}"
echo -e "${GREEN}CPU Architecture: ${WHITE}$(uname -m)${NC}"
echo -e "${GREEN}CPU Cores: ${WHITE}$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "N/A")${NC}"

if [ -f "/proc/meminfo" ]; then
    TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    TOTAL_MEM_GB=$((TOTAL_MEM / 1024 / 1024))
    echo -e "${GREEN}Total RAM: ${WHITE}${TOTAL_MEM_GB}GB${NC}"
fi

# Storage Information
echo -e "\n${BLUE}[*] STORAGE INFORMATION${NC}"
df -h /data 2>/dev/null | awk 'NR==2{print "Internal Storage: " $2 " Used: " $3 " Free: " $4}' | while read line; do
    echo -e "${GREEN}$line${NC}"
done

# Network Information
echo -e "\n${BLUE}[*] NETWORK INFORMATION${NC}"
IP=$(ip route get 1 2>/dev/null | awk '{print $7}')
echo -e "${GREEN}Local IP: ${WHITE}${IP:-Not Connected}${NC}"

# Security Information
echo -e "\n${BLUE}[*] SECURITY STATUS${NC}"
if [ -f "/system/xbin/su" ] || [ -f "/system/bin/su" ] || command -v su &>/dev/null; then
    echo -e "${RED}Root Status: ROOTED${NC}"
else
    echo -e "${GREEN}Root Status: NOT ROOTED${NC}"
fi

# Performance Test
echo -e "\n${BLUE}[*] PERFORMANCE TEST${NC}"
echo -e "${GREEN}Testing CPU speed...${NC}"
start_time=$(date +%s%N)
for i in {1..5000}; do
    result=$((i * i))
done
end_time=$(date +%s%N)
duration=$(( (end_time - start_time) / 1000000 ))
echo -e "${GREEN}CPU Performance: ${WHITE}${duration}ms${NC}"

# Baseband Information
echo -e "\n${BLUE}[*] BASEBAND INFORMATION${NC}"
baseband=$(getprop gsm.version.baseband 2>/dev/null)
if [ -n "$baseband" ]; then
    echo -e "${GREEN}Baseband Version: ${WHITE}$baseband${NC}"
else
    echo -e "${YELLOW}Baseband: Not available${NC}"
fi

echo -e "\n${CYAN}=================================================${NC}"
echo -e "${GREEN}[✓] NULL SECTOR SCAN COMPLETED${NC}"
echo -e "${YELLOW}[*] Scan Time: $(date)${NC}"
echo -e "${BLUE}[!] GitHub: https://github.com/Null-Sector2025/Null-Sector${NC}"