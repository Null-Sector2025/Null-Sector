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
echo -e "${WHITE}           Advanced Device Detection v3.1${NC}"
echo -e "${CYAN}=================================================${NC}"
echo ""

# 更准确的Root检测函数
check_root() {
    local root_status="NOT ROOTED"
    local root_color="${GREEN}"
    
    # 方法1: 检查su二进制文件
    if [ -f "/system/xbin/su" ] || [ -f "/system/bin/su" ]; then
        root_status="ROOTED (su binary found)"
        root_color="${RED}"
    # 方法2: 检查which su命令
    elif command -v su >/dev/null 2>&1; then
        # 进一步验证是否是真正的root
        if su -c "id" 2>/dev/null | grep -q "uid=0"; then
            root_status="ROOTED (superuser access)"
            root_color="${RED}"
        else
            root_status="NOT ROOTED (su exists but no access)"
            root_color="${YELLOW}"
        fi
    # 方法3: 检查id命令
    elif id | grep -q "uid=0"; then
        root_status="ROOTED (running as root)"
        root_color="${RED}"
    fi
    
    echo -e "${root_color}Root Status: ${WHITE}${root_status}${NC}"
}

# 更好的网络检测
get_network_info() {
    echo -e "${GREEN}Network Interfaces:${NC}"
    
    # 获取所有网络接口
    ip addr show 2>/dev/null | grep -E "inet (10\.|192\.168|172\.)" | while read line; do
        interface=$(echo "$line" | awk '{print $7}')
        ip_addr=$(echo "$line" | awk '{print $2}')
        echo -e "  ${WHITE}${interface}: ${CYAN}${ip_addr}${NC}"
    done
    
    # 检查网络连接
    if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
        echo -e "${GREEN}Internet: ${WHITE}Connected ✓${NC}"
    else
        echo -e "${YELLOW}Internet: ${WHITE}No connection ✗${NC}"
    fi
}

# 电池信息检测
get_battery_info() {
    if [ -f "/sys/class/power_supply/battery/capacity" ]; then
        battery_level=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null)
        echo -e "${GREEN}Battery Level: ${WHITE}${battery_level}%${NC}"
    elif command -v dumpsys >/dev/null 2>&1; then
        battery_level=$(dumpsys battery 2>/dev/null | grep level | awk '{print $2}')
        if [ -n "$battery_level" ]; then
            echo -e "${GREEN}Battery Level: ${WHITE}${battery_level}%${NC}"
        fi
    else
        echo -e "${YELLOW}Battery: ${WHITE}Info not available${NC}"
    fi
}

# 温度信息
get_temperature_info() {
    if [ -d "/sys/class/thermal" ]; then
        thermal_zones=$(find /sys/class/thermal -name "thermal_zone*" -type d 2>/dev/null | wc -l)
        echo -e "${GREEN}Thermal Zones: ${WHITE}${thermal_zones}${NC}"
        
        # 显示前3个温度传感器的温度
        find /sys/class/thermal -name "temp" -type f 2>/dev/null | head -3 | while read temp_file; do
            temp=$(cat "$temp_file" 2>/dev/null)
            if [ -n "$temp" ] && [ "$temp" -gt 0 ]; then
                temp_c=$((temp / 1000))
                echo -e "  ${WHITE}${temp_file##*/}: ${CYAN}${temp_c}°C${NC}"
            fi
        done
    fi
}

# 系统信息
echo -e "${BLUE}[*] SYSTEM INFORMATION${NC}"
echo -e "${GREEN}Device Model: ${WHITE}$(getprop ro.product.model 2>/dev/null || uname -m)${NC}"
echo -e "${GREEN}Manufacturer: ${WHITE}$(getprop ro.product.manufacturer 2>/dev/null || echo "Unknown")${NC}"
echo -e "${GREEN}Android Version: ${WHITE}$(getprop ro.build.version.release 2>/dev/null || echo "N/A")${NC}"
echo -e "${GREEN}Kernel Version: ${WHITE}$(uname -r)${NC}"
echo -e "${GREEN}Build ID: ${WHITE}$(getprop ro.build.display.id 2>/dev/null || echo "N/A")${NC}"

# 硬件信息
echo -e "\n${BLUE}[*] HARDWARE INFORMATION${NC}"
echo -e "${GREEN}CPU Architecture: ${WHITE}$(uname -m)${NC}"
echo -e "${GREEN}CPU Cores: ${WHITE}$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "N/A")${NC}"

if [ -f "/proc/meminfo" ]; then
    TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    TOTAL_MEM_GB=$((TOTAL_MEM / 1024 / 1024))
    AVAILABLE_MEM=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    AVAILABLE_MEM_GB=$((AVAILABLE_MEM / 1024 / 1024))
    echo -e "${GREEN}Total RAM: ${WHITE}${TOTAL_MEM_GB}GB${NC}"
    echo -e "${GREEN}Available RAM: ${WHITE}${AVAILABLE_MEM_GB}GB${NC}"
fi

# 电池信息
echo -e "\n${BLUE}[*] BATTERY INFORMATION${NC}"
get_battery_info

# 存储信息
echo -e "\n${BLUE}[*] STORAGE INFORMATION${NC}"
df -h /data 2>/dev/null | awk 'NR==2{print "Internal Storage: " $2 " Used: " $3 " Free: " $4}' | while read line; do
    echo -e "${GREEN}$line${NC}"
done

# 网络信息
echo -e "\n${BLUE}[*] NETWORK INFORMATION${NC}"
get_network_info

# 安全信息
echo -e "\n${BLUE}[*] SECURITY STATUS${NC}"
check_root

# SELinux状态
selinux_status=$(getenforce 2>/dev/null || echo "Unknown")
echo -e "${GREEN}SELinux Status: ${WHITE}${selinux_status}${NC}"

# 温度信息
echo -e "\n${BLUE}[*] TEMPERATURE INFORMATION${NC}"
get_temperature_info

# 性能测试
echo -e "\n${BLUE}[*] PERFORMANCE TEST${NC}"
echo -e "${GREEN}Testing CPU speed...${NC}"
start_time=$(date +%s%N)
for i in {1..5000}; do
    result=$((i * i))
done
end_time=$(date +%s%N)
duration=$(( (end_time - start_time) / 1000000 ))

# 性能评级
if [ $duration -lt 50 ]; then
    performance_rating="Excellent ⭐⭐⭐⭐⭐"
    color="${GREEN}"
elif [ $duration -lt 100 ]; then
    performance_rating="Very Good ⭐⭐⭐⭐"
    color="${GREEN}"
elif [ $duration -lt 200 ]; then
    performance_rating="Good ⭐⭐⭐"
    color="${YELLOW}"
elif [ $duration -lt 500 ]; then
    performance_rating="Average ⭐⭐"
    color="${YELLOW}"
else
    performance_rating="Slow ⭐"
    color="${RED}"
fi

echo -e "${GREEN}CPU Performance: ${WHITE}${duration}ms${NC}"
echo -e "${color}Performance Rating: ${WHITE}${performance_rating}${NC}"

# 基带信息
echo -e "\n${BLUE}[*] BASEBAND INFORMATION${NC}"
baseband=$(getprop gsm.version.baseband 2>/dev/null)
if [ -n "$baseband" ]; then
    echo -e "${GREEN}Baseband Version: ${WHITE}$baseband${NC}"
else
    echo -e "${YELLOW}Baseband: ${WHITE}Not available${NC}"
fi

echo -e "\n${CYAN}=================================================${NC}"
echo -e "${GREEN}[✓] NULL SECTOR SCAN COMPLETED${NC}"
echo -e "${YELLOW}[*] Scan Time: $(date)${NC}"
echo -e "${BLUE}[!] GitHub: https://github.com/Null-Sector2025/Null-Sector${NC}"