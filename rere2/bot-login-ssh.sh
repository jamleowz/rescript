#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================
# Getting
clear
echo " "
echo " "

# Memeriksa apakah file log tersedia
LOG=""
if [ -e "/var/log/auth.log" ]; then
    LOG="/var/log/auth.log"
elif [ -e "/var/log/secure" ]; then
    LOG="/var/log/secure"
else
    echo "Log file not found!"
    exit 1
fi

# Dropbear
echo -e "**━━━━━━━━━━━━━━━━━**"
echo -e "**👨‍💻 DROPBEAR USER LOGIN 👨‍💻**"
echo -e "**━━━━━━━━━━━━━━━━━**"
echo "ID  |  Username  |  IP Address"
grep -i "dropbear" $LOG | grep -i "Password auth succeeded" > /tmp/login-db.txt

while IFS= read -r line; do
    PID=$(echo "$line" | awk '{print $NF}' | cut -d '[' -f2 | cut -d ']' -f1)
    USER=$(echo "$line" | awk '{print $10}')
    IP=$(echo "$line" | awk '{print $12}')
    echo "$PID - $USER - $IP"
done < /tmp/login-db.txt

echo " "
echo -e "**━━━━━━━━━━━━━━━━━**"
echo -e "**👨‍💻 OPENSSH USER LOGIN 👨‍💻**"
echo -e "**━━━━━━━━━━━━━━━━━**"
echo "ID  |  Username  |  IP Address"
grep -i sshd $LOG | grep -i "Accepted password for" > /tmp/login-ssh.txt

while IFS= read -r line; do
    PID=$(echo "$line" | awk '{print $9}' | cut -d '[' -f2 | cut -d ']' -f1)
    USER=$(echo "$line" | awk '{print $9}')
    IP=$(echo "$line" | awk '{print $11}')
    echo "$PID - $USER - $IP"
done < /tmp/login-ssh.txt

# OpenVPN TCP Log
if [ -f "/etc/openvpn/server/openvpn-tcp.log" ]; then
    echo ""
    echo -e "**━━━━━━━━━━━━━━━━━**"
    echo -e "**👨‍💻 OPENVPN TCP USER LOGIN 👨‍💻**"
    echo -e "**━━━━━━━━━━━━━━━━━**"
    echo "Username  |  IP Address  |  Connected"
    grep -w "^CLIENT_LIST" /etc/openvpn/server/openvpn-tcp.log | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-tcp.txt
    cat /tmp/vpn-login-tcp.txt
fi

# OpenVPN UDP Log
if [ -f "/etc/openvpn/server/openvpn-udp.log" ]; then
    echo " "
    echo -e "**━━━━━━━━━━━━━━━━━**"
    echo -e "**👨‍💻 OPENVPN UDP USER LOGIN 👨‍💻**"
    echo -e "**━━━━━━━━━━━━━━━━━**"
    echo "Username  |  IP Address  |  Connected"
    grep -w "^CLIENT_LIST" /etc/openvpn/server/openvpn-udp.log | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-udp.txt
    cat /tmp/vpn-login-udp.txt
fi
echo "**━━━━━━━━━━━━━━━━━**"
echo ""