#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   sleep 1
   exit 1
fi


# just press key to continue
press_key(){
 read -p "Press any key to continue..."
}


# Define a function to colorize text
colorize() {
    local color="$1"
    local text="$2"
    local style="${3:-normal}"
    
    # Define ANSI color codes
    local black="\033[30m"
    local red="\033[31m"
    local green="\033[32m"
    local yellow="\033[33m"
    local blue="\033[34m"
    local magenta="\033[35m"
    local cyan="\033[36m"
    local white="\033[37m"
    local reset="\033[0m"
    
    # Define ANSI style codes
    local normal="\033[0m"
    local bold="\033[1m"
    local underline="\033[4m"
    # Select color code
    local color_code
    case $color in
        black) color_code=$black ;;
        red) color_code=$red ;;
        green) color_code=$green ;;
        yellow) color_code=$yellow ;;
        blue) color_code=$blue ;;
        magenta) color_code=$magenta ;;
        cyan) color_code=$cyan ;;
        white) color_code=$white ;;
        *) color_code=$reset ;;  # Default case, no color
    esac
    # Select style code
    local style_code
    case $style in
        bold) style_code=$bold ;;
        underline) style_code=$underline ;;
        normal | *) style_code=$normal ;;  # Default case, normal text
    esac

    # Print the colored and styled text
    echo -e "${style_code}${color_code}${text}${reset}"
}


install_gamingvpn() {
    # Define the directory and files
    DEST_DIR="/root/gamingvpn"
    FILE="/root/gamingvpn/gamingvpn"
    URL_X86="https://github.com/Musixal/GamingVPN/raw/main/core/gamingvpn_amd64"
    URL_ARM="https://github.com/Musixal/GamingVPN/raw/main/core/gamingvpn_arm"              
      
    echo
    if [ -f "$FILE" ]; then
	    colorize green "GamingVPN core installed already." bold
	    return 1
    fi
    
    if ! [ -d "$DEST_DIR" ]; then
    	mkdir "$DEST_DIR" &> /dev/null
    fi
    
    # Detect the system architecture
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        URL=$URL_X86
    elif [ "$ARCH" = "armv7l" ] || [ "$ARCH" = "aarch64" ]; then
        URL=$URL_ARM
    else
        colorize red "Unsupported architecture: $ARCH\n" bold
        sleep 2
        return 1
    fi


    colorize yellow "Installing GamingVPN Core..." bold
    echo
    curl -L $URL -o $FILE &> /dev/null
	chmod +x $FILE 
    if [ -f "$FILE" ]; then
        colorize green "GamingVPN core installed successfully...\n" bold
        sleep 1
        return 0
    else
        colorize red "Failed to install GamingVPN core...\n" bold
        return 1
    fi
}
install_gamingvpn

# Fetch server country
SERVER_COUNTRY=$(curl -sS "http://ipwhois.app/json/$SERVER_IP" | jq -r '.country')

# Fetch server isp 
SERVER_ISP=$(curl -sS "http://ipwhois.app/json/$SERVER_IP" | jq -r '.isp')

# Function to display ASCII logo
display_logo() {   
    echo -e "${CYAN}"
    cat << "EOF"
  _____           _          _   _____  _  __
 / ___/__ ___ _  (_)__  ___ | | / / _ \/ |/ /
/ (_ / _ `/  ' \/ / _ \/ _ `/ |/ / ___/    / 
\___/\_,_/_/_/_/_/_//_/\_, /|___/_/  /_/|_/  
                      /___/                  
EOF
    echo -e "${NC}${CYAN}"
    echo -e "Version: ${YELLOW}0.5${CYAN}"
    echo -e "Github: ${YELLOW}Github.com/Musixal/GamingVPN${CYAN}"
    echo -e "Telegram Channel: ${YELLOW}@Gozar_Xray${NC}"
}

# Function to display server location and IP
display_server_info() {
    echo -e "\e[93m═════════════════════════════════════════════\e[0m"  
 	#	Hidden for security issues   
    #echo -e "${CYAN}IP Address:${NC} $SERVER_IP"
    echo -e "${CYAN}Location:${NC} $SERVER_COUNTRY "
    echo -e "${CYAN}Datacenter:${NC} $SERVER_ISP"
}

CONFIG_DIR='/root/gamingvpn'
SERVICE_FILE='/etc/systemd/system/gamingvpn.service'
# Function to display Rathole Core installation status
display_gamingvpn_status() {
    if [[ -f "${CONFIG_DIR}/gamingvpn" ]]; then
        echo -e "${CYAN}GamingVPN:${NC} ${GREEN}Installed${NC}"
    else
        echo -e "${CYAN}GamingVPN:${NC} ${RED}Not installed${NC}"
    fi
    echo -e "\e[93m═════════════════════════════════════════════\e[0m"  
}

configure_server(){
    # Check if service or config file exisiting and returnes
    echo 
    if [ -f "$SERVICE_FILE" ]; then
    	colorize red "GamingVPN service is running, please remove it first to configure it again." bold
    	sleep 2
    	return 1
    fi
    
    
    #Clear and title
    clear
    colorize cyan "Configure server for GamingVPN" bold
        
    echo
    
    # Tunnel Port
    echo -ne "[-] Tunnel Port (default 4096): "
    read -r PORT
    if [ -z "$PORT" ]; then
        PORT=4096
    fi
    
    echo
    
    # FEC Value
    echo -ne "[-] FEC value (with x:y format, default 2:1, enter 0 to disable): "
    read -r FEC
    if [ -z "$FEC" ]; then
    	colorize yellow "FEC set to 2:1"
        FEC="-f2:1"
    elif [[ "$FEC" == "0" ]];then
   	    colorize yellow "FEC is disabled"
    	FEC="--disable-fec"
	else
		FEC="-f${FEC}"
    fi
  
    echo
    
    # Subnet address 
    echo -ne "[-] Subnet Address (default 10.22.22.0): "
    read -r SUBNET
    if [ -z "$SUBNET" ]; then
        SUBNET="10.22.22.0"
    fi
    
    # Final command
    COMMAND="-s -l[::]:$PORT $FEC --sub-net $SUBNET  --mode 1  --timeout 1 --tun-dev gamingvpn --disable-obscure"
    
        # Create the systemd service unit file
    cat << EOF > "$SERVICE_FILE"
[Unit]
Description=GamingVPN Server
After=network.target

[Service]
Type=simple
ExecStart=$CONFIG_DIR/gamingvpn $COMMAND
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

	systemctl daemon-reload &> /dev/null
	systemctl enable gamingvpn &> /dev/null
	systemctl start gamingvpn &> /dev/null
	
	echo
	colorize green "GamingVPN server started successfully."
	echo
	press_key
}

configure_client(){
    # Check if service or config file exisiting and returnes
    echo 
    if [ -f "$SERVICE_FILE" ]; then
    	colorize red "GamingVPN service is running, please remove it first to configure it again." bold
    	sleep 2
    	return 1
    fi
   
    #Clear and title
    clear
    colorize cyan "Configure client for GamingVPN" bold
        
    echo
    
    # Remote Server Address
    echo -ne "[*] Remote server address (IPv4 and [IPv6] are supported): "
    read -r IP
    if [ -z "$IP" ]; then
        colorize red "Enter a valid IP Address..." bold
        sleep 2
        return 1
    fi
    
    echo
    
    # Tunnel Port
    echo -ne "[-] Tunnel Port (default 4096): "
    read -r PORT
    if [ -z "$PORT" ]; then
        PORT=4096
    fi
    
    echo
    
    # FEC Value
    echo -ne "[-] FEC value (with x:y format, default 2:1, enter 0 to disable): "
    read -r FEC
    if [ -z "$FEC" ]; then
    	colorize yellow "FEC set to 2:1"
        FEC="-f2:1"
    elif [[ "$FEC" == "0" ]];then
   	    colorize yellow "FEC is disabled"
    	FEC="--disable-fec"
	else
		FEC="-f${FEC}"
    fi

    
    echo
    
    # Subnet address 
    echo -ne "[-] Subnet Address (default 10.22.22.0): "
    read -r SUBNET
    if [ -z "$SUBNET" ]; then
        SUBNET="10.22.22.0"
    fi
    
    # Final command
    COMMAND="-c -r${IP}:${PORT} $FEC --sub-net $SUBNET --mode 1  --timeout 1 --tun-dev gamingvpn --keep-reconnect --disable-obscure"

    # Create the systemd service unit file
    cat << EOF > "$SERVICE_FILE"
[Unit]
Description=GamingVPN Client
After=network.target

[Service]
Type=simple
ExecStart=$CONFIG_DIR/gaming $COMMAND
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

	systemctl daemon-reload &> /dev/null
	systemctl enable gamingvpn &> /dev/null
	systemctl start gamingvpn &> /dev/null
	
	echo
	colorize green "GamingVPN client started successfully."
	echo
	press_key
}

check_service_status(){
	echo
    if ! [ -f "$SERVICE_FILE" ]; then
    	colorize red "GamingVPN service is not found" bold
    	sleep 2
    	return 1
    fi
    


}

remove_service(){
	echo
    if ! [ -f "$SERVICE_FILE" ]; then
		colorize red "GamingVPN service not found." bold
		sleep 2
		return 1
    fi
	
	systemctl disable gamingvpn &> /dev/null
	systemctl stop gamingvpn &> /dev/null
	rm -rf "$SERVICE_FILE"
	systemctl daemon-reload &> /dev/null
	
	colorize green "GamingVPN service stopped and deleted successfully." bold
	sleep 2

}

remove_core(){
	echo
	if ! [ -d "$CONFIG_DIR" ]; then
		colorize red "Gaming VPN directory not found"
		sleep 2
		return 1
	fi
	
    if [ -f "$SERVICE_FILE" ]; then
    	colorize red "GamingVPN service is running, please remove it first and then remove then core." bold
    	sleep 2
    	return 1
    fi
	
	rm -rf "$CONFIG_DIR"
	colorize green "GamingVPN directory deleted successfully." bold
	sleep 2
}
# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\e[36m'
MAGENTA="\e[95m"
NC='\033[0m' # No Color


# Function to display menu
display_menu() {
    clear
    display_logo
    display_server_info
    display_gamingvpn_status
    echo
    colorize green " 1. Configure for server" bold
    colorize cyan " 2. Configure for client" bold
    colorize yellow " 3. Check service status" 
    colorize red " 4. Remove all services"
    colorize red " 5. Remove core files"
    colorize reset " 6. View logs"
    echo -e " 0. Exit"
    echo
    echo "-------------------------------"
}

# Function to read user input
read_option() {
    read -p "Enter your choice [0-6]: " choice
    case $choice in
        1) configure_server ;;
        2) configure_client ;;
        3) check_service_status ;;
        4) remove_service ;;
        5) remove_core;;
        6) view_logs;;
        0) exit 0 ;;
        *) echo -e "${RED} Invalid option!${NC}" && sleep 1 ;;
    esac
}

# Main script
while true
do
    display_menu
    read_option
done
