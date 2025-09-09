#!/bin/bash

mesinssh() {
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
echo "----------=[ Dropbear User Login ]=-----------"
echo "ID  |  Username  |  IP Address"
echo "----------------------------------------------"
grep -i "dropbear" $LOG | grep -i "Password auth succeeded" > /tmp/login-db.txt

while IFS= read -r line; do
    PID=$(echo "$line" | awk '{print $NF}' | cut -d '[' -f2 | cut -d ']' -f1)
    USER=$(echo "$line" | awk '{print $10}')
    IP=$(echo "$line" | awk '{print $12}')
    echo "$PID - $USER - $IP"
done < /tmp/login-db.txt

echo " "
echo "----------=[ OpenSSH User Login ]=------------"
echo "ID  |  Username  |  IP Address"
echo "----------------------------------------------"
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
    echo "---------=[ OpenVPN TCP User Login ]=---------"
    echo "Username  |  IP Address  |  Connected"
    echo "----------------------------------------------"
    grep -w "^CLIENT_LIST" /etc/openvpn/server/openvpn-tcp.log | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-tcp.txt
    cat /tmp/vpn-login-tcp.txt
fi

# OpenVPN UDP Log
if [ -f "/etc/openvpn/server/openvpn-udp.log" ]; then
    echo " "
    echo "---------=[ OpenVPN UDP User Login ]=---------"
    echo "Username  |  IP Address  |  Connected"
    echo "----------------------------------------------"
    grep -w "^CLIENT_LIST" /etc/openvpn/server/openvpn-udp.log | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-udp.txt
    cat /tmp/vpn-login-udp.txt
fi
echo "----------------------------------------------"
echo ""
}

logs() {
    TEKS="
Log Multi Login SSH
=================
Username: $user
Limit IP: $iplimit
Total Login: $cekcek
=================
       [ IP ]
$ip_list
=================
The account will be locked for 15 minutes and will be unlocked automatically.
"
CHATID=$(cat /etc/funny/.chatid)
KEY=$(cat /etc/funny/.keybot)
TIME="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
curl -s --max-time $TIME --data-urlencode "chat_id=$CHATID" --data-urlencode "text=$TEKS" $URL >/dev/null 2>&1
clear
}

clear
username=$(while IFS=: read -r username _ _ uid _ _ _ _; do
    if [[ $uid -ge 1000 && $username != "nobody" && $username != "root" ]]; then
        echo "$username"
    fi
done < /etc/passwd)
clear

# Membuat direktori jika belum ada
if [ ! -d "/etc/xray/limit/ip/ssh" ]; then
    mkdir -p /etc/xray/limit/ip/ssh
    echo "Direktori /etc/xray/limit/ip/ssh dibuat."
fi

mulog=$(mesinssh)
date=$(date)

for user in ${username[@]}
do
    file_path="/etc/xray/limit/ip/ssh/$user"
    if [ ! -f "$file_path" ]; then
        echo "2" > "$file_path"
        echo "File untuk pengguna $user dibuat dan diisi dengan 2."
    fi

    iplimit=$(cat "$file_path")
    cekcek=$(echo -e "$mulog" | grep "$user" | wc -l)

    # Mendapatkan daftar IP untuk pengguna
    ip_list=$(echo -e "$mulog" | grep "$user" | awk '{print $NF}' | sort | uniq | tr '\n' ', ' | sed 's/, $//')

    # Pastikan user root tidak dikunci
    if [[ $user != "root" && $cekcek -gt $iplimit ]]; then
        passwd -l "$user"
        echo "$user dikunci karena melebihi batas login."
        echo "passwd -u $user" | at now + 15 minutes
        logs >/dev/null 2>&1
        nais=3
    else
        echo > /dev/null
    fi
    sleep 0.1
done

if [[ $nais -gt 1 ]]; then
    clear
else
    echo > /dev/null
fi