#!/bin/bash

menu-ssh() {
#
#  |═════════════════════════════════════════════════════════════════════════════════|
#  • Autoscript AIO Lite Menu By FN Project                                          |
#  • FN Project Developer @Rerechan02 | @PR_Aiman | @farell_aditya_ardian            |
#  • Copyright 2024 18 Marc Indonesia [ Kebumen ] | [ Johor ] | [ 上海，中国 ]       |
#  |═════════════════════════════════════════════════════════════════════════════════|
#
cekssh1() {

LOG=""

if [ -e "/var/log/auth.log" ]; then
    LOG="/var/log/auth.log"
fi
if [ -e "/var/log/secure" ]; then
    LOG="/var/log/secure"
fi

# Initialize JSON output
output="{\"dropbear_users\":[], \"openssh_users\":[], \"openvpn_tcp_users\":[], \"openvpn_udp_users\":[]}"

# Function to add user info to JSON
add_user_info() {
    local service=$1
    local pid=$2
    local user=$3
    local ip=$4
    output=$(echo $output | jq --arg service "$service" --arg pid "$pid" --arg user "$user" --arg ip "$ip" \
        '.[$service + "_users"] += [{"pid": $pid, "user": $user, "ip": $ip}]')
}

# Process Dropbear users
data=( $(ps aux | grep -i dropbear | awk '{print $2}') )
cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" > /tmp/login-db.txt

for PID in "${data[@]}"
do
    cat /tmp/login-db.txt | grep "dropbear\[$PID\]" > /tmp/login-db-pid.txt
    NUM=$(cat /tmp/login-db-pid.txt | wc -l)
    USER=$(cat /tmp/login-db-pid.txt | awk '{print $10}')
    IP=$(cat /tmp/login-db-pid.txt | awk '{print $12}')
    if [ $NUM -eq 1 ]; then
        add_user_info "dropbear" "$PID" "$USER" "$IP"
    fi
done

# Process OpenSSH users
cat $LOG | grep -i sshd | grep -i "Accepted password for" > /tmp/login-db.txt
data=( $(ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}') )

for PID in "${data[@]}"
do
    cat /tmp/login-db.txt | grep "sshd\[$PID\]" > /tmp/login-db-pid.txt
    NUM=$(cat /tmp/login-db-pid.txt | wc -l)
    USER=$(cat /tmp/login-db-pid.txt | awk '{print $9}')
    IP=$(cat /tmp/login-db-pid.txt | awk '{print $11}')
    if [ $NUM -eq 1 ]; then
        add_user_info "openssh" "$PID" "$USER" "$IP"
    fi
done

# Process OpenVPN TCP users
if [ -f "/etc/openvpn/server/openvpn-tcp.log" ]; then
    cat /etc/openvpn/server/openvpn-tcp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/ /g' > /tmp/vpn-login-tcp.txt
    while read -r line
    do
        USER=$(echo $line | awk '{print $1}')
        IP=$(echo $line | awk '{print $2}')
        CONNECTED=$(echo $line | awk '{print $3}')
        output=$(echo $output | jq --arg user "$USER" --arg ip "$IP" --arg connected "$CONNECTED" \
            '.openvpn_tcp_users += [{"user": $user, "ip": $ip, "connected": $connected}]')
    done < /tmp/vpn-login-tcp.txt
fi

# Process OpenVPN UDP users
if [ -f "/etc/openvpn/server/openvpn-udp.log" ]; then
    cat /etc/openvpn/server/openvpn-udp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/ /g' > /tmp/vpn-login-udp.txt
    while read -r line
    do
        USER=$(echo $line | awk '{print $1}')
        IP=$(echo $line | awk '{print $2}')
        CONNECTED=$(echo $line | awk '{print $3}')
        output=$(echo $output | jq --arg user "$USER" --arg ip "$IP" --arg connected "$CONNECTED" \
            '.openvpn_udp_users += [{"user": $user, "ip": $ip, "connected": $connected}]')
    done < /tmp/vpn-login-udp.txt
fi

# Print the JSON output
clear
echo $output | jq .

# Clean up temporary files
rm -f /tmp/login-db.txt /tmp/login-db-pid.txt /tmp/vpn-login-tcp.txt /tmp/vpn-login-udp.txt
}

hapus() {
clear
echo -e "\033[0;34m══════════════════════════════════════════\033[0m"
echo -e "\E[0;41;36m                 AKUN SSH               \E[0m"
echo -e "\033[0;34m══════════════════════════════════════════\033[0m"      
echo "USERNAME          EXP DATE          STATUS"
echo -e "\033[0;34m══════════════════════════════════════════\033[0m"
while read expired
do
AKUN="$(echo $expired | cut -d: -f1)"
ID="$(echo $expired | grep -v nobody | cut -d: -f3)"
exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
status="$(passwd -S $AKUN | awk '{print $2}' )"
if [[ $ID -ge 1000 ]]; then
if [[ "$status" = "L" ]]; then
printf "%-17s %2s %-17s %2s \n" "$AKUN" "$exp     " "${RED}LOCKED${NORMAL}"
else
printf "%-17s %2s %-17s %2s \n" "$AKUN" "$exp     " "${GREEN}UNLOCKED${NORMAL}"
fi
fi
done < /etc/passwd
JUMLAH="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
echo -e "\033[0;34m══════════════════════════════════════════\033[0m"
echo "Account number: $JUMLAH user"
echo -e "\033[0;34m══════════════════════════════════════════\033[0m"
echo ""
read -p "Username SSH to Delete : " Pengguna
if getent passwd $Pengguna > /dev/null 2>&1; then
        userdel $Pengguna > /dev/null 2>&1
        rm -fr /etc/xray/limit/ip/ssh/$Pengguna
        clear
        echo -e "User $Pengguna was removed."
        systemctl restart nginx
systemctl restart dropbear
else
clear
        echo -e "Failure: User $Pengguna Not Exist."
fi
}

renew() {
clear
echo -e "\e[33m══════════════════════════════════════════\033[0m"
echo -e "\E[40;1;37m               RENEW  USER                \E[0m"
echo -e "\e[33m══════════════════════════════════════════\033[0m"  
echo
read -p "Username : " User
egrep "^$User" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
read -p "Day Extend : " Days
Today=`date +%s`
Days_Detailed=$(( $Days * 86400 ))
Expire_On=$(($Today + $Days_Detailed))
Expiration=$(date -u --date="1970-01-01 $Expire_On sec GMT" +%Y/%m/%d)
Expiration_Display=$(date -u --date="1970-01-01 $Expire_On sec GMT" '+%d %b %Y')
passwd -u $User
usermod -e  $Expiration $User
egrep "^$User" /etc/passwd >/dev/null
echo -e "$Pass\n$Pass\n"|passwd $User &> /dev/null
clear
echo -e "\e[33m══════════════════════════════════════════\033[0m"
echo -e "\E[40;1;37m               RENEW  USER                \E[0m"
echo -e "\e[33m══════════════════════════════════════════\033[0m"  
echo -e ""
echo -e " Username : $User"
echo -e " Days Added : $Days Days"
echo -e " Expires on :  $Expiration_Display"
echo -e ""
echo -e "\e[33m══════════════════════════════════════════\033[0m"
else
clear
echo -e "\e[33m══════════════════════════════════════════\033[0m"
echo -e "\E[40;1;37m               RENEW  USER                \E[0m"
echo -e "\e[33m══════════════════════════════════════════\033[0m"  
echo -e ""
echo -e "   Username Doesnt Exist      "
echo -e ""
echo -e "\e[33m══════════════════════════════════════════\033[0m"
fi
}

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

cek() {
clear
touch /root/.system
clear
echo -e "\033[0;34m═══════════════════════════════════\033[0m"
echo -e "     =[ SSH User Login ]=         "
echo -e "\033[0;34m═══════════════════════════════════\033[0m"
mulog=$(mesinssh)
data=( $(cat /etc/passwd | grep home | cut -d ' ' -f 1 | cut -d : -f 1) )
excluded_users=("nobody" "root" "syslog" "ubuntu" "debian" "kvm" "openvz")

for user in "${data[@]}"
do
    # Skip excluded users
    if [[ " ${excluded_users[@]} " =~ " ${user} " ]]; then
        continue
    fi

    lim=$(cat /etc/xray/limit/ip/ssh/${user})
    cekcek=$(echo -e "$mulog" | grep $user | wc -l)
    if [[ $cekcek -gt 0 ]]; then
        echo -e "\e[33;1mUser\e[32;1m  : $user"
        echo -e "\e[33;1mLogin\e[32;1m : $cekcek "
        echo -e "\e[33;1mLimit IP\e[32m;1m : $lim "
        echo -e "\033[0;34m═══════════════════════════════════\033[0m"
        echo "slot" >> /root/.system
    else
        echo > /dev/null
    fi
    sleep 0.1
done
aktif=$(cat /root/.system | wc -l)
echo -e "$aktif User Online"
echo -e "\033[0;34m═══════════════════════════════════\033[0m"
sed -i "d" /root/.system
}

member() {
clear
echo -e "\e[33m══════════════════════════════════════════\033[0m"
echo -e "\E[40;1;37m                 MEMBER SSH               \E[0m"
echo -e "\e[33m══════════════════════════════════════════\033[0m"      
echo "USERNAME          EXP DATE          STATUS"
echo -e "\e[33m══════════════════════════════════════════\033[0m"
while read expired
do
AKUN="$(echo $expired | cut -d: -f1)"
ID="$(echo $expired | grep -v nobody | cut -d: -f3)"
exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
status="$(passwd -S $AKUN | awk '{print $2}' )"
if [[ $ID -ge 1000 ]]; then
if [[ "$status" = "L" ]]; then
printf "%-17s %2s %-17s %2s \n" "$AKUN" "$exp     " "${RED}LOCKED${NORMAL}"
else
printf "%-17s %2s %-17s %2s \n" "$AKUN" "$exp     " "${GREEN}UNLOCKED${NORMAL}"
fi
fi
done < /etc/passwd
JUMLAH="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
echo -e "\e[33m══════════════════════════════════════════\033[0m"
echo "Account number: $JUMLAH user"
echo -e "\e[33m══════════════════════════════════════════\033[0m"
}

trial() {
clear
Login=trial`</dev/urandom tr -dc X-Z0-9 | head -c4`
masaaktif="1"
Pass="1"
clear
systemctl restart dropbear
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
expi="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
hariini=`date -d "0 days" +"%Y-%m-%d"`
expi=`date -d "$masaaktif days" +"%Y-%m-%d"`
echo "$Login:$Pass" | sudo chpasswd
domain=$(cat /etc/xray/domain)
clear
TEKS="
═══════════════════════════
<=      SSH ACCOUNT      =>
═══════════════════════════

Username     : $Login
Password     : $Pass
Host/IP      : $domain
Port ssl/tls : 443
Port non tls : 80, 2082
Port openssh : 22, 3303, 53
Port dropbear: 109, 69, 143
Udp Custom   : 1-65535, 56-7789
BadVpn       : 7300
═══════════════════════════
<=  Slowdns Information  =>
Port         : 5300, 5353
Publik Key   : $(cat /etc/slowdns/server.pub)
Nameserver   : $(cat /etc/slowdns/nsdomain)
═══════════════════════════
<=  Chisel  Information  =>
Port TLS     : 9443
Port HTTP    : 8000
TLS Usage    : chisel client wss://$domain:9443 R:5000:localhost:22 / chisel client https://$Login:$Pass@$domain:9443 R:5000:localhost:22
HTTP Usage   : chisel client ws://$domain:8000 R:5000:localhost:22 / chisel client http://$Login:$Pass@$domain:8000 R:5000:localhost:22
═══════════════════════════
Port OVPN    : 1194 TCP / 2200 UDP
OVPN TCP     : http://$domain:8081/tcp.ovpn
OVPN UDP     : http://$domain:8081/udp.ovpn
═══════════════════════════
Payload Ws   => GET / HTTP/1.1[crlf]Host: $domain[crlf]Upgrade: websocket[crlf][crlf]
═══════════════════════════
Payload Ovpn => GET /ovpn HTTP/1.1[crlf]Host: $domain[crlf]Upgrade: websocket[crlf][crlf]
═══════════════════════════
     Expired => $expi
═══════════════════════════
"
clear
CHATID=$(cat /etc/funny/.chatid)
KEY=$(cat /etc/funny/.keybot)
TIME="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
curl -s --max-time $TIME --data-urlencode "chat_id=$CHATID" --data-urlencode "text=$TEKS" $URL
clear
echo -e "$TEKS"
}

clear

menu-ssh() {
clear
edussh_service=$(systemctl status proxy | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $edussh_service == "running" ]]; then
ws="\e[1;32m[ ON ]\033[0m"
else
ws="\e[1;31m[ OFF ]\033[0m"
fi
eduss_service=$(systemctl status sslh | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $eduss_service == "running" ]]; then
slh="\e[1;32m[ ON ]\033[0m"
else
slh="\e[1;31m[ OFF ]\033[0m"
fi
edust_service=$(systemctl status edu | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $edust_service == "running" ]]; then
proxy1="\e[1;32m[ ON ]\033[0m"
else
proxy1="\e[1;31m[ OFF ]\033[0m"
fi
clear
echo -e "
══════════════════════════════════════════
        [ 菜单 SSH VPN 高级版  ]
══════════════════════════════════════════
WebSocket: $ws
SSLH Proxy: $slh
Goproxy Rerechan: $proxy1

1. Add Account SSH
2. Trial Account SSH
3. List SSH Account Member
4. Delete SSH Account Active
5. Renew SSH Account Active
6. Cek User Login SSH Account
7. Cek User Login SSH Account With API
══════════════════════════════════════════
       Press CTRL + C to Exit
"
read -p "Input Number: " opt
case $opt in
1) clear ; addssh ;;
2) clear ; trial-ssh ;;
3) clear ; member ;;
4) clear ; hapus ;;
5) clear ; renew ;;
6) clear ; cek ;;
7) clear ; cekssh1 ;;
*) clear ; menu-ssh :;
esac
}

menu-ssh
}

menu-xray() {
#
#  |=================================================================================|
#  • Autoscript AIO Lite Menu By FN Project                                          |
#  • FN Project Developer @Rerechan02 | @PR_Aiman | @farell_aditya_ardian            |
#  • Copyright 2024 18 Marc Indonesia [ Kebumen ] | [ Johor ] | [ 上海，中国 ]       |
#  |=================================================================================|
#
clear

cek() {
con() {
    local -i bytes=$1;
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$(( (bytes + 1023)/1024 ))KB"
    elif [[ $bytes -lt 1073741824 ]]; then
        echo "$(( (bytes + 1048575)/1048576 ))MB"
    else
        echo "$(( (bytes + 1073741823)/1073741824 ))GB"
    fi
}
clear
RED='\e[31m'
GREEN='\e[32m'
NC='\033[0;37m'
white='\033[0;97m'
data=( `cat /etc/xray/config.json | grep '###' | cut -d ' ' -f 2 | sort | uniq`);
    limit_file="/etc/xray/quota/$data"
    usage_file="/etc/xray/quota/$data_usage"

    if [[ -f "$limit_file" ]]; then
        tot=$(cat "$limit_file")
        limit=$(con $tot)
    else
        limit="Unlimited"
    fi

    if [[ -f "$usage_file" ]]; then
        pakai=$(cat "$usage_file")
        usage=$(con ${pakai})
    else
        usage="0 B"
    fi
clear
echo -n > /tmp/other.txt
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "     =[ ALL-XRAY User Login ]=         "
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
for akun in "${data[@]}"
do
if [[ -z "$akun" ]]; then
akun="tidakada"
fi
echo -n > /tmp/ipxray.txt
data2=( `cat /var/log/xray/access.log | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | sort | uniq`);
for ip in "${data2[@]}"
do
jum=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | grep -w "$ip" | sort | uniq)
if [[ "$jum" = "$ip" ]]; then
echo "$jum" >> /tmp/ipxray.txt
else
echo "$ip" >> /tmp/other.txt
fi
jum2=$(cat /tmp/ipxray.txt)
sed -i "/$jum2/d" /tmp/other.txt > /dev/null 2>&1
done
jum=$(cat /tmp/ipxray.txt)
if [[ -z "$jum" ]]; then
echo > /dev/null
else
jum2=$(cat /tmp/ipxray.txt | nl)
lastlogin=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 2 | tail -1)
echo -e "
user :${GREEN} ${akun} ${NC}
${RED}Online Jam ${NC}:${white} ${lastlogin} wib
${RED}Limit Quota${NC}:${GREEN} ${limit}
${RED}Usage Quota${NC}:${GREEN} ${usage}
";
echo -e "$jum2";
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
fi
rm -rf /tmp/ipxray.txt
done
rm -rf /tmp/other.txt

echo ""
}

dell() {
NC='\e[0m'
GB='\e[32;1m'
YB='\e[33;1m'
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "                ${GB}Delete V2ray Account${NC}                "
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "  ${YB}You have no existing clients!${NC}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -n 1 -s -r -p "Press any key to back on menu"
menu-xray
fi
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "                ${GB}Delete V2ray Account${NC}                "
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " ${YB}User  Expired${NC}  "
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
grep -E "^### " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq
echo ""
echo -e "${YB}tap enter to go back${NC}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -rp "Input Username : " user
if [ -z $user ]; then
menu-xray
else
exp=$(grep -wE "^### $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
sed -i "/^### $user $exp/,/^},{/d" /etc/xray/config.json
rm -rf /etc/xray/quota/$user
rm -rf /etc/xray/quota/${user}_usage
systemctl restart xray
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "           ${GB}V2ray Account Success Deleted${NC}            "
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " ${YB}Client Name :${NC} $user"
echo -e " ${YB}Expired On  :${NC} $exp"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
fi
}

ren() {
NC='\e[0m'
GB='\e[32;1m'
YB='\e[33;1m'
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "                ${GB}Extend V2ray Account${NC}               "
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "  ${YB}You have no existing clients!${NC}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-xray
fi
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "                ${GB}Extend V2ray Account${NC}               "
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " ${YB}User  Expired${NC}  "
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
grep -E "^### " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq
echo ""
echo -e "${YB}tap enter to go back${NC}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -rp "Input Username : " user
if [ -z $user ]; then
menu-xray
else
read -p "Expired (days): " masaaktif
exp=$(grep -wE "^### $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "/### $user/c\### $user $exp4" /etc/xray/config.json
systemctl restart xray
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "           ${GB}V2ray Account Success Extended${NC}            "
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " ${YB}Client Name :${NC} $user"
echo -e " ${YB}Expired On  :${NC} $exp4"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
fi
}

mx() {
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "     =[ Member V2ray Account ]=         "
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -n > /var/log/xray/accsess.log
data=( `cat /etc/xray/config.json | grep '###' | cut -d ' ' -f 2 | sort | uniq`);
for user in "${data[@]}"
do
echo > /dev/null
jum=$(cat /etc/xray/config.json | grep -c '###' | awk '{print $1}')
if [[ $jum -gt 0 ]]; then
exp=$(grep -wE "^### $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
echo -e "\e[33;1mUser\e[32;1m  : $user / $exp "
#echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "slot" >> /root/.system
else
echo > /dev/null
fi
sleep 0.1
done
aktif=$(cat /root/.system | wc -l)
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"        
echo -e "$aktif Member Active"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
sed -i "d" /root/.system
}

mlbb() {
RED='\e[31m'
GREEN='\e[32m'
NC='\033[0;37m'
clear

# Prepare temporary files
echo -n > /tmp/other.txt
echo -n > /tmp/ipxray.txt

# Get unique users from the config
data=( $(cat /etc/xray/config.json | grep '###' | cut -d ' ' -f 2 | sort | uniq) )

# Begin JSON output
echo '{' > /tmp/output.json
echo '"users": [' >> /tmp/output.json

first_user=true

for akun in "${data[@]}"
do
    if [[ -z "$akun" ]]; then
        akun="tidakada"
    fi

    echo -n > /tmp/ipxray.txt
    data2=( $(cat /var/log/xray/access.log | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | sort | uniq) )

    for ip in "${data2[@]}"
    do
        jum=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | grep -w "$ip" | sort | uniq)
        if [[ "$jum" = "$ip" ]]; then
            echo "$jum" >> /tmp/ipxray.txt
        else
            echo "$ip" >> /tmp/other.txt
        fi
        jum2=$(cat /tmp/ipxray.txt)
        sed -i "/$jum2/d" /tmp/other.txt > /dev/null 2>&1
    done

    jum=$(cat /tmp/ipxray.txt)
    if [[ -z "$jum" ]]; then
        continue
    else
        if ! $first_user; then
            echo ',' >> /tmp/output.json
        fi
        first_user=false

        lastlogin=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 2 | tail -1)
        ip_list=$(cat /tmp/ipxray.txt | nl | awk '{print "\"" $2 "\""}' | paste -sd, -)

        echo "{" >> /tmp/output.json
        echo "\"user\": \"$akun\"," >> /tmp/output.json
        echo "\"last_login\": \"$lastlogin\"," >> /tmp/output.json
        echo "\"ips\": [$ip_list]" >> /tmp/output.json
        echo "}" >> /tmp/output.json
    fi

    rm -rf /tmp/ipxray.txt
done

# End JSON output
echo ']' >> /tmp/output.json
echo '}' >> /tmp/output.json

# Format the JSON output using jq
clear
jq . /tmp/output.json

# Clean up temporary files
rm -rf /tmp/other.txt
rm -rf /tmp/output.json
}

uix() {
clear
echo -e "══════════════════════════" | lolcat
echo -e " <= UUID V2RAY ACCOUNT =>"
echo -e "══════════════════════════" | lolcat
grep -oP '(?<=id": ")[^"]+' /etc/xray/*.json | sort -u
echo -e "══════════════════════════" | lolcat
read -p "Input Old UUID Account: " user
read -p "Input New UUID Account: " uuid
sed -i "s|\"id\": \"$user\"|\"id\": \"$uuid\"|" /etc/xray/*.json
systemctl daemon-reload ; systemctl restart xray
clear
echo -e "══════════════════════════" | lolcat
echo -e " <= SUCCES CHANGE UUID =>"
echo -e "══════════════════════════" | lolcat
echo -e "OLD UUID ACCOUNT: $user "
echo -e "NEW UUID ACCOUNT: $uuid "
echo -e "══════════════════════════" | lolcat
}

uit() {
clear
echo -e "═════════════════════════════" | lolcat
echo -e "<= PASSWORD TROJAN ACCOUNT =>"
echo -e "═════════════════════════════" | lolcat
grep -oP '(?<=password": ")[^"]+' /etc/xray/*.json | sort -u
echo -e "══════════════════════════" | lolcat
read -p "Input Old Password Account: " user
read -p "Input New Password Account: " uuid
sed -i "s|\"id\": \"$user\"|\"id\": \"$uuid\"|" /etc/xray/*.json
systemctl daemon-reload ; systemctl restart xray
clear
echo -e "═════════════════════════════" | lolcat
echo -e "<= SUCCES CHANGE PASSWORD  => "
echo -e "═════════════════════════════" | lolcat
echo -e "OLD Password ACCOUNT: $user "
echo -e "NEW Password ACCOUNT: $uuid "
echo -e "═════════════════════════════" | lolcat
}

menu-xray() {
red='\e[1;31m'
green='\e[1;32m'
#pink='\e[1;35m'
NC='\e[0m'
#18. Show X-Ray Active Account on Database Server
clear
echo -e "
==============================
  [ 菜单数据 V2ray 管理器 ]
=============================="
status="$(systemctl show xray.service --no-page)"
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
if [ "${status_text}" == "active" ]
then
echo -e "${white}V2射线 状态 ${NC}: "${green}"running"$NC" ✓"
else
echo -e "${white}V2射线 状态 ${NC}: "$red"not running (Error)"$NC" "
fi
status="$(systemctl show nginx.service --no-page)"
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
if [ "${status_text}" == "active" ]
then
echo -e "${white}负载均衡${NC}: "${green}"running"$NC" ✓"
else
echo -e "${white}负载均衡${NC}: "$red"not running (Error)"$NC" "
fi
#V2ray 状态： $xtr
#负载均衡器： $ng
echo "
01. Create Account Vmess
02. Create Account Vless
03. Create Account Trojan
04. Create Account Shadowsocks
05. Create Account X-Ray Socks5
==============================

06. Trial Account Vmess
07. Trial Account Vless
08. Trial Account Trojan
09. Trial Account Socks5
10. Trial Account Shadowsocks
==============================

11. Cek User IP Login V2ray
12. Cek User Login Usage V2ray
13. Renew Account V2ray With Name
14. Delete Account V2ray With Username
15. Change UUID V2ray Account With UUID
16. Change Password Trojan Account With Password
17. Cek Total List Member Active in server with Database
==============================
   Press CTRL + C to exit
"
read -p "Input Option: " opw
case $opw in
01|1) clear ; add-vmess ;;
02|2) clear ; add-vless ;;
03|3) clear ; add-trojan ;;
04|4) clear ; add-ssws ;;
05|5) clear ; add-socks ;;
06|6) clear ; trial-vmess ;;
07|7) clear ; trial-vless ;;
08|8) clear ; trial-trojan ;;
09|9) clear ; trial-socks ;;
10) clear ; trial-ssws ;;
11) clear ; mlbb ;;
12) clear ; log-xray ;;
13) clear ; ren ;;
14) clear ; dell ;;
15) clear ; uix ;;
16) clear ; uit ;;
17) clear ; mx ;;
#18) clear ; log-xray ;;
*) clear ; menu-xray ;;
esac
}

menu-xray
}

nmenu() {
[[ -e $(which curl) ]] && if [[ -z $(cat /etc/resolv.conf | grep "1.1.1.1") ]]; then cat <(echo "nameserver 1.1.1.1") /etc/resolv.conf > /etc/resolv.conf.tmp && mv /etc/resolv.conf.tmp /etc/resolv.conf; fi
#
#  |=================================================================================|
#  • Autoscript AIO Lite Menu By FN Project                                          |
#  • FN Project Developer @Rerechan02 | @PR_Aiman | @farell_aditya_ardian            |
#  • Copyright 2024 18 Marc Indonesia [ Kebumen ] | [ Johor ] | [ 上海，中国 ]       |
#  |=================================================================================|
#

addn() {
domain=$(cat /etc/xray/domain)
clear
echo -e "
════════════════════════════
Add Account NoobzVPN
════════════════════════════"
read -p "Username  : " user
read -p "Password  : " pass
read -p "Masa Aktif: " masaaktif
clear
noobzvpns --add-user "$user" "$pass"
noobzvpns --expired-user "$user" "$masaaktif"
expi=`date -d "$masaaktif days" +"%Y-%m-%d"`
clear
TEKS="
════════════════════════════
NoobzVPN Account
════════════════════════════
Hostname  : $domain
Username  : $user
Password  : $pass
════════════════════════════
TCP_STD/HTTP  : 8080
TCP_SSL/HTTPS : 8443
════════════════════════════
PAYLOAD   : GET / HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf][crlf]
════════════════════════════
Expired   : $expi
════════════════════════════"
CHATID=$(cat /etc/funny/.chatid)
KEY=$(cat /etc/funny/.keybot)
TIME="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
curl -s --max-time $TIME -d "chat_id=$CHATID&text=$TEKS" $URL
clear
echo "$TEKS"
}

deln() {
mna=$(noobzvpns --info-all-user)
clear
echo -e "
════════════════════════════
Delete Account
════════════════════════════
$mna
════════════════════════════
"
read -p "Input Name: " name
if [ -z $name ]; then
menu
else
noobzvpns --remove-user "$user"
clear
TEKS="
════════════════════════════
Username Delete
════════════════════════════

User: $name
════════════════════════════
"
CHATID=$(cat /etc/funny/.chatid)
KEY=$(cat /etc/funny/.keybot)
TIME="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
curl -s --max-time $TIME -d "chat_id=$CHATID&text=$TEKS" $URL
clear
echo "$TEKS"
fi
}

list() {
clear
noobzvpns --info-all-user
}

tampilan() {
white='\e[037;1m'
RED='\e[31m'
GREEN='\e[32m'
NC='\033[0;37m'
domain=$(cat /etc/xray/domain)
clear
if [[ $(systemctl status noobzvpns | grep -w Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == 'active' ]]; then
    status="${GREEN}ON${NC}";
else
    status="${RED}OFF${NC}";
fi
clear
echo -e "════════════════════════════════" | lolcat
echo -e " ${white}      <== NOOBZVPNS ==>"
echo -e "════════════════════════════════" | lolcat
echo -e "Noobz: $status
${white}
Domain: $domain
${white}
1. Add Account
2. Trial Account
3. Delete Account
4. List Active Account${white}"
echo "════════════════════════════════" | lolcat
echo "Preess CTRL or X to exit"
echo "════════════════════════════════" | lolcat
read -p "Input Option: " inrere
case $inrere in
1|01) clear ; addn ;;
2|02) clear ; trial-noobz ;;
3|03) clear ; deln ;;
4|04) clear ; list ;;
x|X) exit ;;
*) echo "Wrong Number " ; tampilan ;;
esac
}
tampilan
}

menu-warp() {
#
#  |=================================================================================|
#  • Autoscript AIO By FN Project                                                    |
#  • FN Project Developer @Rerechan02 | @PR_Aiman | @farell_aditya_ardian            |
#  • Copyright 2024 18 Marc Indonesia [ Kebumen ] | [ Johor ] | [ 上海，中国 ]        |
#  |=================================================================================|
#

# Color
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Red_font_prefix}[information]${Font_color_suffix}"

clear

install() {
clear
# Check OS version
if [[ -e /etc/debian_version ]]; then
        source /etc/os-release
        OS=$ID # debian or ubuntu
elif [[ -e /etc/centos-release ]]; then
        source /etc/os-release
        OS=centos
fi
# Check OS version
if [[ -e /etc/debian_version ]]; then
        source /etc/os-release
        OS=$ID # debian or ubuntu
elif [[ -e /etc/centos-release ]]; then
        source /etc/os-release
        OS=centos
fi

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[information]${Font_color_suffix}"

if [[ -e /etc/wireguard/params ]]; then
        echo -e "${Info} WireGuard sudah diinstal."
        exit 1
fi

# Install WireGuard tools and module
        if [[ $OS == 'ubuntu' ]]; then
        apt install -y wireguard
elif [[ $OS == 'debian' ]]; then
        echo "deb http://deb.debian.org/debian/ unstable main" >/etc/apt/sources.list.d/unstable.list
        printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' >/etc/apt/preferences.d/limit-unstable
        apt update
        apt install -y wireguard-tools iptables iptables-persistent
        apt install -y linux-headers-$(uname -r)
elif [[ ${OS} == 'centos' ]]; then
        curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
        yum -y update
        yum -y install wireguard-dkms wireguard-tools
        fi
apt install iptables iptables-persistent -y
# Make sure the directory exists (this does not seem the be the case on fedora)
mkdir -p /etc/wireguard >/dev/null 2>&1

# Install Warp
if [[ -e /usr/bin/warp.sh ]]; then
 echo -e "${Info} Warp already Install,."
else
cd /usr/bin
wget git.io/warp.sh
bash warp.sh install
bash warp.sh wgd
fi
chmod /usr/bin/warp.sh
chmod +x /usr/bin/*
clear
}

status() {
    clear
    warp.sh status
    curl -s https://www.cloudflare.com/cdn-cgi/trace
}

enable() {
    warp-cli connect
    clear
    echo -e "Done Enable Warp"
}

disable() {
    warp-cli disconnect
    clear
    echo -e "success disable warp"
}

restart() {
    warp.sh restart
    systemctl daemon-reload
    systemctl restart wg-quick@wgcf
    clear
    echo -e "Done Restart Service Warp Wireguard"
}

akun4() {
    warp -4 > /root/wgcf.conf
    clear
    echo -e "
    <= Your WARP IPv4 Wireguard Account =>
    ======================================
         Wireguard Configuration

    $(cat /root/wgcf.conf)
    ======================================
    "
    rm -fr /root/wgcf.conf
}

akun6() {
        warp -6 > /root/wgcf.conf
    clear
    echo -e "
    <= Your WARP IPv6 Wireguard Account =>
    ======================================
         Wireguard Configuration

    $(cat /root/wgcf.conf)
    ======================================
    "
    rm -fr /root/wgcf.conf
}

token() {
    clear
    read -p "Input Your Token Teams WARP+: " token
    clear
    warp -T $token
}

add() {
    clear
    echo -e "
    Create Account Warp Wireguard
    =============================

    1. Create Account with IPv4
    2. Create Account with IPv6
    =============================
    Press CTRL + C To exit menu"
    read -p "Input Option: " aws
    case $aws in
    1) akun4 ;;
    2) akun6 ;;
    *) add ;;
    esac
}

menuwg() {
    clear
    echo -e "
      Menu Warp Wireguard FN
    ==========================

    1. Install Warp Wireguard
    2. Status Warp Wireguard
    3. Restart Warp Wireguard
    4. Enable Warp Wireguard
    5. Disable Warp Wireguard
    6. Input Token Warp Teams
    ==========================
    
    7. Create Account Wireguard
    8. Enter to default menu
    9. Exit this menu
    ==========================
    Press CTRL + C To Exit Menu"
    read -p "Input Option: " opt
    case $opt in
    1) install ;;
    2) status ;;
    3) restart ;;
    4) enable ;;
    5) disable ;;
    6) token ;;
    7) add ;;
    8) menu ;;
    9) exit ;;
    *) menuwg ;;
    esac
}
menuwg
}

menu-trojan() {
###
clear
###
red='\e[1;31m'
green='\e[1;32m'
NC='\e[0m'
add() {
clear
domain=$(cat /etc/xray/domain)
clear
echo -e "
===================================
<= [ Create Igniter-Go Account ] =>
===================================
"
read -p "Username: " username
read -p "Expired : " masaaktif
clear
uuid=$(cat /etc/trojan-go/uuid.txt)
until [[ $username =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
		user_EXISTS=$(grep -w $username /etc/trojan-go/akun.conf | wc -l)

		if [[ ${user_EXISTS} == '1' ]]; then
			echo ""
			echo -e "Username ${RED}${user}${NC} Already On VPS Please Choose Another"
			exit 1
		fi
	done
clear
sed -i '/"'""$uuid""'"$/a\,"'""$username""'"' /etc/trojan-go/config.json
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
echo -e "### $username $exp" >> /etc/trojan-go/akun.conf
systemctl restart trojan-go.service
link="trojan-go://${username}@${domain}:2087/?sni=${domain}&type=ws&host=${domain}&path=/trojango&encryption=none#$username"
clear
TEKS="
================
<= Igniter Go =>
================

Hostname: $domain
Username: $username
Password: $username
Expired : $exp
Port    : 2087
Path    : /trojango
================
WS TLS  : $link
================
"
CHATID=$(cat /etc/funny/.chatid)
KEY=$(cat /etc/funny/.keybot)
TIME="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
curl -s --max-time $TIME --data-urlencode "chat_id=$CHATID" --data-urlencode "text=$TEKS" $URL
clear
echo -e "$TEKS"
}

delete() {
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/trojan-go/akun.conf")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		echo ""
		echo "You have no existing clients!"
		exit 1
	fi

	echo ""
	echo " Select the existing client you want to remove"
	echo " Press CTRL+C to return"
	echo " ==============================="
	echo "     No  Expired   User"
	grep -E "^### " "/etc/trojan-go/akun.conf" | cut -d ' ' -f 2-3 | nl -s ') '
	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
		if [[ ${CLIENT_NUMBER} == '1' ]]; then
			read -rp "Select one client [1]: " CLIENT_NUMBER
		else
			read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
		fi
	done
CLIENT_NAME=$(grep -E "^### " "/etc/trojan-go/akun.conf" | cut -d ' ' -f 2-3 | sed -n "${CLIENT_NUMBER}"p)
user=$(grep -E "^### " "/etc/trojan-go/akun.conf" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/trojan-go/akun.conf" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
sed -i "/^### $user $exp/d" /etc/trojan-go/akun.conf
sed -i '/^,"'"$user"'"$/d' /etc/trojan-go/config.json
systemctl restart trojan-go.service
clear
TEKS="
================
<= Igniter Go =>
================

Success Delete

Username: $user
Expired : $exp
================
"
clear
CHATID=$(cat /etc/funny/.chatid)
KEY=$(cat /etc/funny/.keybot)
TIME="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
curl -s --max-time $TIME --data-urlencode "chat_id=$CHATID" --data-urlencode "text=$TEKS" $URL
clear
echo -e "$TEKS"
}

renew() {
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/trojan-go/akun.conf")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		clear
		echo ""
		echo "You have no existing clients!"
		exit 1
	fi

	clear
	echo ""
	echo "Select the existing client you want to renew"
	echo " Press CTRL+C to return"
	echo -e "==============================="
	grep -E "^### " "/etc/trojan-go/akun.conf" | cut -d ' ' -f 2-3 | nl -s ') '
	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
		if [[ ${CLIENT_NUMBER} == '1' ]]; then
			read -rp "Select one client [1]: " CLIENT_NUMBER
		else
			read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
		fi
	done
read -p "Expired (Days) : " masaaktif
user=$(grep -E "^### " "/etc/trojan-go/akun.conf" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/trojan-go/akun.conf" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "s/### $user $exp/### $user $exp4/g" /etc/trojan-go/akun.conf
clear
TEKS="
================
<= Igniter Go =>
================

Success Renewed

Username: $user
Old Exp : $exp
New Exp : $exp4
===============
"
clear
CHATID=$(cat /etc/funny/.chatid)
KEY=$(cat /etc/funny/.keybot)
TIME="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
curl -s --max-time $TIME --data-urlencode "chat_id=$CHATID" --data-urlencode "text=$TEKS" $URL
clear
echo -e "$TEKS"
}

total() {
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "  =[ Member Trojan-Go Account ]=         "
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -n > /var/log/xray/accsess.log
data=( `cat /etc/trojan-go/akun.conf | grep '###' | cut -d ' ' -f 2 | sort | uniq`);
for user in "${data[@]}"
do
echo > /dev/null
jum=$(cat /etc/trojan-go/akun.conf | grep -c '###' | awk '{print $1}')
if [[ $jum -gt 0 ]]; then
exp=$(grep -wE "^### $user" "/etc/trojan-go/akun.conf" | cut -d ' ' -f 3 | sort | uniq)
echo -e "\e[33;1mUser\e[32;1m  : $user / $exp "
#echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "slot" >> /root/.system
else
echo > /dev/null
fi
sleep 0.1
done
aktif=$(cat /root/.system | wc -l)
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "$aktif Member Active"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
sed -i "d" /root/.system
}

menu-trgo() {
status="$(systemctl show trojan-go.service --no-page)"
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
clear
echo -e "
============================
<= Igniter Go / Trojan Go =>
============================"
if [ "${status_text}" == "active" ]
then
echo -e "${white}木马GO${NC}: "${green}"running"$NC" ✓"
else
echo -e "${white}木马GO${NC}: "$red"not running (Error)"$NC" "
fi

echo -e "
1. Create Account
2. Delete Account
3. Renew Account
4. List Total Account
============================
Press CTRL + C To Exit Menu
"
read -p "Input Option: " opws
case $opws in
1) clear ; add ;;
2) clear ; delete ;;
3) clear ; renew ;;
4) clear ; total ;;
*) clear ; menu-trgo ;;
esac
}

menu-trgo
}

botmenu() {
#
#  |=================================================================================|
#  • Autoscript AIO Lite Menu By FN Project                                          |
#  • FN Project Developer @Rerechan02 | @PR_Aiman | @farell_aditya_ardian            |
#  • Copyright 2024 18 Marc Indonesia [ Kebumen ] | [ Johor ] | [ 上海，中国 ]       |
#  |=================================================================================|
#

termbot() {
install() {
# [ Repository Bot Telegram ]
link="https://raw.githubusercontent.com/DindaPutriFN/FN-API/main/bot.zip"

# [ Membersihkan layar ]
clear

# [ File lokasi API Key dan Chat ID ]
api_file="/etc/funny/.keybot"
id_file="/etc/funny/.chatid"

# [ Memeriksa apakah file API Key dan Chat ID ada ]
if [[ -f "$api_file" && -f "$id_file" ]]; then
    api=$(cat "$api_file")
    itd=$(cat "$id_file")
else
    echo -e "
===================
[ 设置机器人通知 ]
===================
"
    read -p "API Key Bot: " api
    read -p "Your Chat ID: " itd
    
    # [ Menyimpan API Key dan Chat ID ke file ]
    echo "$api" > "$api_file"
    echo "$itd" > "$id_file"
fi

clear

# [ Menginstall Bot ]
cd /usr/bin
wget -O bot.zip "${link}"
yes A | unzip bot.zip
rm -fr bot.zip
cd /usr/bin/bot
npm install

# [ Membuat Konfigurasi API Bot ]
cat > /usr/bin/bot/config.json << EOF
{
    "authToken": "$api",
    "owner": $itd
}
EOF

# [ Menginstall Service ]
cat > /etc/systemd/system/bot.service << END
[Unit]
Description=Service for bot terminal
After=network.target

[Service]
ExecStart=/usr/bin/node /usr/bin/bot/server.js
WorkingDirectory=/usr/bin/bot
Restart=always
User=root

[Install]
WantedBy=multi-user.target
END

# [ Menjalankan Service ]
systemctl daemon-reload
systemctl enable bot
systemctl start bot
systemctl restart bot

# [ Membersihkan Layar ]
clear

# [ Menampilkan Output ]
echo -e "
Success Install Bot Terminal
============================

Your Database
Chat ID : $itd
Api Bot : $api

Just Check Your Bot Terminal
============================
"
}

hapus() {
systemctl stop bot
systemctl disable bot
rm -fr /etc/systemd/system/bot.service
rm -fr /usr/bin/bot
clear
echo "
Success Deleted Bot Terminal"
}

restart() {
systemctl daemon-reload
systemctl restart bot
clear
echo "
Success Reboot Bot Terminal"
}

menubot() {
clear
edussh_service=$(systemctl status bot | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $edussh_service == "running" ]]; then
ws="\e[1;32m[ ON ]\033[0m"
else
ws="\e[1;31m[ OFF ]\033[0m"
fi
clear
echo -e "
<= Menu Bot Terminal =>
=======================
Bot: $ws

1. Install Bot Terminal
2. Uninstall Bot Terminal
3. Restart Service Bot Terminal
0. Back To Default Menu Panel
=======================
Press CTRL + C to Exit
"
read -p "Input Option: " opw
case $opw in
1) clear ; install ;;
2) clear ; hapus ;;
3) restart ;;
0) menu ;;
*) menubot ;;
esac
}

menubot
}

clear

lanjut() {
rm -fr /etc/funny/.chatid
rm -fr /etc/funny/.keybot
echo "$api" > /etc/funny/.keybot
echo "$itd" > /etc/funny/.chatid
clear
echo -e "
Your Data Bot Notirication
===========================
API Bot: $api
Chatid Own: $itd
===========================
"
}

add() {
clear
echo -e "
===================
[ 设置机7器人通知 ]
===================
"
read -p "API Key Bot: " api
read -p "Your Chat ID: " itd
clear
echo -e "
Information
==============================
API Bot: $api
Chatid : $itd
==============================
"
read -p "Is the data above correct? (y/n): " opw
case $opw in
y) clear ; lanjut ;;
n) clear ; add ;;
*) clear ; add ;;
esac
}

rpot() {
echo "
Report Bug To
=====================
Telegram:

- @Rerechan02
- @farell_aditya_ardian
- @PR_Aiman
=====================
Email:

- widyabakti02@gmail.com
=====================

Thanks For Use My Script
"
}

mna() {
echo -e "
======================
[   菜单设置机器人   ]
======================

1. Setup Bot Notification
2. Setup Bot Panel All Menu
3. Setup Bot Terminal Server
4. Report Bug On Script
======================
Press CTRL + C to exit
"
read -p "Input Option: " apws
case $apws in
1) clear ; add ;;
2) clear ; bot-panel ;;
3) clear ; termbot ;;
4) clear ; rpot ;;
*) clear ; mna ;;
esac
}

mna
}

bmenu() {
#
#  |==========================================================|
#  • Autoscript AIO Lite Menu By Rerechan02
#  • FN Project Developer @Rerechan02 | @PR_Aiman | @xlordeuyy
#  • Copyright 2024 18 Marc Indonesia [ Kebumen ]
#  |==========================================================|
#

# [ New Copyright ]
#
#  |=================================================================================|
#  • Autoscript AIO Lite Menu By FN Project                                          |
#  • FN Project Developer @Rerechan02 | @PR_Aiman | @farell_aditya_ardian            |
#  • Copyright 2024 10 Mei Indonesia [ Kebumen ] | [ Johor ] | [ 上海，中国 ]       |
#  |=================================================================================|
#
rest() {
clear
echo "This Feature Can Only Be Used According To Vps Data With This Autoscript"
echo "Please input link to your vps data backup file."
read -rp "Link File: " -e url
cd /root
wget -O backup.zip "$url"
unzip backup.zip
rm -f backup.zip
sleep 1
echo "Tengah Melakukan Backup Data"
cd /root/backup
cp passwd /etc/
cp group /etc/
cp shadow /etc/
cp gshadow /etc/
cp -r trojan-go /etc/
cp -r xray /etc/
cp -r funny /etc/
cp -r noobzvpns /etc/
cp -r .cloudflared /root/
cp -r cloudflared /etc/

clear
cd
rm -rf /root/backup
rm -f backup.zip
clear
if systemctl is-active --quiet cloudflared; then
    sudo systemctl restart cloudflared
elif systemctl is-enabled --quiet cloudflared; then
    sudo systemctl restart cloudflared
else
    sudo cloudflared service install
    sudo systemctl start cloudflared
    sudo systemctl enable cloudflared
fi
clear
systemctl daemon-reload
systemctl restart trojan-go
systemctl restart ssh
systemctl restart sshd
systemctl restart xray
systemctl restart noobzvpns
systemctl restart server
systemctl restart quota
clear
echo "Telah Berjaya Melakukan Backup"
}

resid() {
resp() {
cd /root
wget -O backup.zip "$url"
unzip backup.zip
rm -f backup.zip
sleep 1
echo "Tengah Melakukan Backup Data"
cd /root/backup
cp passwd /etc/
cp group /etc/
cp shadow /etc/
cp gshadow /etc/
cp -r trojan-go /etc/
cp -r xray /etc/
cp -r funny /etc/
cp -r noobzvpns /etc/
cp -r .cloudflared /root/
cp -r cloudflared /etc/
clear
cd
rm -rf /root/backup
rm -f backup.zip
clear
if systemctl is-active --quiet cloudflared; then
    sudo systemctl restart cloudflared
elif systemctl is-enabled --quiet cloudflared; then
    sudo systemctl restart cloudflared
else
    sudo cloudflared service install
    sudo systemctl start cloudflared
    sudo systemctl enable cloudflared
fi
clear
systemctl daemon-reload
systemctl restart trojan-go
systemctl restart ssh
systemctl restart sshd
systemctl restart xray
systemctl restart noobzvpns
systemctl restart server
systemctl restart quota
clear
echo "Telah Berjaya Melakukan Backup"
}
clear
echo "Select Database Source"
echo "======================"
echo "1. file.io"
echo "2. Google Drive"
echo "======================"
read -rp "Input Option: " choice
read -rp "ID Database: " -e id
case $choice in
    1)
        url="https://file.io/${id}"
	resp
        ;;
    2)
        url="https://drive.google.com/u/4/uc?id=${id}&export=download"
	resp
        ;;
    *)
        echo "Pilihan tidak valid. Harap masukkan 1 atau 2."
        exit 1
        ;;
esac
}

resid2() {
clear
echo "This Feature Can Only Be Used According To Vps Data With This Autoscript"
echo "Please input ID to your vps data backup file."
read -rp "ID Database: " -e id
url="https://file.io/${id}"
cd /root
wget -O backup.zip "$url"
unzip backup.zip
rm -f backup.zip
sleep 1
echo "Tengah Melakukan Backup Data"
cd /root/backup
cp passwd /etc/
cp group /etc/
cp shadow /etc/
cp gshadow /etc/
cp -r trojan-go /etc/
cp -r xray /etc/
cp -r funny /etc/
cp -r noobzvpns /etc/
cp -r .cloudflared /root/
cp -r cloudflared /etc/
clear
cd
rm -rf /root/backup
rm -f backup.zip
clear
if systemctl is-active --quiet cloudflared; then
    sudo systemctl restart cloudflared
elif systemctl is-enabled --quiet cloudflared; then
    sudo systemctl restart cloudflared
else
    sudo cloudflared service install
    sudo systemctl start cloudflared
    sudo systemctl enable cloudflared
fi
clear
systemctl daemon-reload
systemctl restart ssh
systemctl restart sshd
systemctl restart xray
systemctl restart noobzvpns
systemctl restart server
systemctl restart quota
systemctl restart trojan-go
clear
echo "Telah Berjaya Melakukan Backup"
}

restf() {
cd /root
mv /root/*.zip /root/backup.zip
file="backup.zip"
if [ -f "$file" ]; then
echo "$file ditemukan, melanjutkan proses..."
sleep 2
clear
unzip backup.zip
rm -f backup.zip
sleep 1
echo "Tengah Melakukan Backup Data"
cd /root/backup
cp passwd /etc/
cp group /etc/
cp shadow /etc/
cp gshadow /etc/
cp -r trojan-go /etc/
cp -r xray /etc/
cp -r funny /etc/
cp -r noobzvpns /etc/
cp -r .cloudflared /root/
cp -r cloudflared /etc/
clear
cd
rm -rf /root/backup
rm -f backup.zip
clear
if systemctl is-active --quiet cloudflared; then
    sudo systemctl restart cloudflared
elif systemctl is-enabled --quiet cloudflared; then
    sudo systemctl restart cloudflared
else
    sudo cloudflared service install
    sudo systemctl start cloudflared
    sudo systemctl enable cloudflared
fi
clear
systemctl daemon-reload
systemctl restart ssh
systemctl restart sshd
systemctl restart xray
systemctl restart noobzvpns
systemctl restart server
systemctl restart quota
systemctl restart trojan-go
clear
echo "Telah Berjaya Melakukan Backup"
else
    echo "Error: File $file Not Found"
fi
}

clear

bmenu() {
clear
echo "
============================
Menu Backup Data VPN in VpS
============================

1. Backup Your Data VPN
2. Backup Via Google Drive
3. Restore With Link Backup
4. Restore With ID Database
5. Restore With SFTP / Termius
6. Bot Notification Setup on Server
==============================
Press CTRL + C / X to Exit Menu
"
read -p "Input Valid Number Option: " mla
case $mla in
1) clear ; backup ;;
2) clear ; backup-gd ;;
3) clear ; rest ;;
4) clear ; resid ;;
5) clear ; restf ;;
6) botmenu ;;
x) exit ;;
*) echo " Please Input Valid Number " ; bmenu ;;
esac
}

bmenu
}

menu-api() {
clear
generate() {
clear
echo -e "Generating New Key"
sleep 5
clear
xray uuid >> /etc/xray/.key
clear
systemctl daemon-reload
systemctl restart server
mds=$(cat /etc/xray/.key)
clear
echo -e "
Success Generate New Key
========================
Your API Token:
$mds
========================
"
}

manual() {
clear
echo -e "
Add New Token API
=================
"
read -p "Input Token: " token
sleep 5
echo $token >> /etc/xray/.key
systemctl daemon-reload
systemctl restart server
clear
mds=$(cat /etc/xray/.key)
clear
echo -e "
Success Add New Key API
========================
Your API Token:
$mds
========================
"
}

manual31() {
nano /etc/xray/.key
}

cert() {
clear
echo start
clear
domain=$(cat /etc/xray/domain)
clear
echo "
L FN 项目更新证书
=================================
Your Domain: $domain
=================================
4 For IPv4 &  For IPv6
"
echo -e "Generate new Ceritificate Please Input Type Your VPS"
read -p "Input Your Type Pointing ( 4 / 6 ): " ip_version
if [[ $ip_version == "4" ]]; then
    systemctl stop nginx
    systemctl stop haproxy
    mkdir /root/.acme.sh
    curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
    chmod +x /root/.acme.sh/acme.sh
    /root/.acme.sh/acme.sh --upgrade --auto-upgrade
    /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    /root/.acme.sh/acme.sh --issue -d $domain --force --standalone -k ec-256
    ~/.acme.sh/acme.sh --installcert -d $domain --force --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
    cd /etc/xray
    cat xray.crt xray.key >> /etc/xray/funny.pem
    chmod 644 /etc/xray/xray* /etc/xray/*.pem
    cd
    systemctl start haproxy
    systemctl start nginx
    echo "Cert installed for IPv4."
elif [[ $ip_version == "6" ]]; then
    systemctl stop nginx
    systemctl stop haproxy
    mkdir /root/.acme.sh
    curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
    chmod +x /root/.acme.sh/acme.sh
    /root/.acme.sh/acme.sh --upgrade --auto-upgrade
    /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    /root/.acme.sh/acme.sh --issue -d $domain --force --standalone -k ec-256 --listen-v6
    ~/.acme.sh/acme.sh --installcert -d $domain --force --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
    cd /etc/xray
    cat xray.crt xray.key >> /etc/xray/funny.pem
    chmod 644 /etc/xray/xray* /etc/xray/*.pem
    cd
    systemctl start haproxy
    systemctl start nginx
    echo "Cert installed for IPv6."
else
    echo "Invalid IP version. Please choose '4' for IPv4 or '6' for IPv6."
    sleep 3
    cert
fi
}

enable() {
clear
echo -e "Enable API"
sleep 5
clear
systemctl daemon-reload
systemctl enable server
systemctl start server
clear
echo -e "Done Enable API"
}

restart() {
echo -e "Restarting API"
systemctl daemon-reload
systemctl enable server
systemctl start server
systemctl restart server
clear
echo -e "Done Restarting API"
}

disable() {
echo -e "Disable API"
sleep 5
clear
systemctl stop server
systemctl disable server
clear
echo -e "Success Disable API"
}

detail() {
domain=$(cat /etc/xray/domain)
edust_service=$(systemctl status server | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $edust_service == "running" ]]; then
proxy1="\e[1;32m[ ON ]\033[0m"
else
proxy1="\e[1;31m[ OFF ]\033[0m"
fi
clear
echo -e "
<= Menu Web API =>
==================
With Port:
- http://${domain}:9000/path
==================
Default Port:
- http://${domain}/api/path
- https://${domain}/api/path
==================
Status: $proxy1

1. Generate New Key Token
2. Change Manual Key Token
3. Add Key Token API
4. Fix default https Certificate
5. Enable API
6. Restart API
7. Disable API
0. Back To Default Menu
==================
"
read -p "Input Option: " opw
case $opw in
1) clear ; generate ; exit ;;
2) clear ; manual31 ; exit ;;
3) clear ; manual ; exit ;;
4) clear ; cert ; exit ;;
5) clear ; enable ; exit ;;
6) clear ; restart ; exit ;;
7) clear ; disable ; exit ;;
0) clear ; menu ; exit ;;
*) clear ; detail ; exit ;;
esac
}

detail

}

menu-set() {
clear
####

dm-menu() {
acme() {
clear
echo start
clear
domain=$(cat /etc/xray/domain)
clear
echo "
L FN 项目更新证书
=================================
Your Domain: $domain
=================================
4 For IPv4 &  For IPv6
"
echo -e "Generate new Ceritificate Please Input Type Your VPS"
read -p "Input Your Type Pointing ( 4 / 6 ): " ip_version
if [[ $ip_version == "4" ]]; then
    systemctl stop nginx
    systemctl stop haproxy
    mkdir /root/.acme.sh
    curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
    chmod +x /root/.acme.sh/acme.sh
    /root/.acme.sh/acme.sh --upgrade --auto-upgrade
    /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    /root/.acme.sh/acme.sh --issue -d $domain --force --standalone -k ec-256
    ~/.acme.sh/acme.sh --installcert -d $domain --force --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
    cd /etc/xray
    cat xray.crt xray.key >> /etc/xray/funny.pem
    chmod 644 /etc/xray/xray* /etc/xray/*.pem
    cd
    systemctl start haproxy
    systemctl start nginx
    echo "Cert installed for IPv4."
elif [[ $ip_version == "6" ]]; then
    systemctl stop nginx
    systemctl stop haproxy
    mkdir /root/.acme.sh
    curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
    chmod +x /root/.acme.sh/acme.sh
    /root/.acme.sh/acme.sh --upgrade --auto-upgrade
    /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    /root/.acme.sh/acme.sh --issue -d $domain --force --standalone -k ec-256 --listen-v6
    ~/.acme.sh/acme.sh --installcert -d $domain --force --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
    cd /etc/xray
    cat xray.crt xray.key >> /etc/xray/funny.pem
    chmod 644 /etc/xray/xray* /etc/xray/*.pem
    cd
    systemctl start haproxy
    systemctl start nginx
    echo "Cert installed for IPv6."
else
    echo "Invalid IP version. Please choose '4' for IPv4 or '6' for IPv6."
    sleep 3
    cert
fi
}

cert2() {
email="faraskun02@gmail.com"
domain=$(cat /etc/xray/domain)

clear
echo "
L FN 项目更新证书
=================================
Your Domain: $domain
=================================
4 For IPv4 & 6 For IPv6
"
echo -e "Generate new Certificate. Please input your VPS type:"
read -p "Input Your Type Pointing (4 for IPv4 / 6 for IPv6): " ip_version

stop_services() {
    systemctl stop haproxy
    systemctl stop nginx
}

start_services() {
    systemctl start haproxy
    systemctl start nginx
}

copy_certificates() {
    cat /etc/letsencrypt/live/$domain/fullchain.pem >> /etc/xray/xray.crt
    cat /etc/letsencrypt/live/$domain/privkey.pem >> /etc/xray/xray.key
    cd /etc/xray
    cat xray.crt xray.key >> /etc/xray/funny.pem
    chmod 644 /etc/xray/xray* /etc/xray/*.pem
    cd
}

if [[ $ip_version == "4" || $ip_version == "6" ]]; then
    stop_services
    if [[ $ip_version == "4" ]]; then
        certbot certonly --standalone --preferred-challenges http -d $domain --non-interactive --agree-tos --email $email
    elif [[ $ip_version == "6" ]]; then
        certbot certonly --standalone --preferred-challenges http -d $domain --non-interactive --agree-tos --email $email --preferred-challenges http --standalone-supported-challenges http
    fi

    copy_certificates
    start_services
    echo "Cert installed for IPv$ip_version."
else
    echo "Invalid IP version. Please choose '4' for IPv4 or '6' for IPv6."
    sleep 3
    cert2
fi
}

dm() {
clear
echo -e "\e[33m===================================\033[0m"
echo -e "Domain anda saat ini:"
echo -e "$(cat /etc/xray/domain)"
echo ""
read -rp "Domain/Host: " -e host
echo ""
if [ -z $host ]; then
echo "DONE CHANGE DOMAIN"
echo -e "\e[33m===================================\033[0m"
read -n 1 -s -r -p "Press any key to back on menu"
menu
else
echo "$host" > /etc/xray/domain
echo -e "\e[33m===================================\033[0m"
echo -e ""
read -n 1 -s -r -p "Press any key to renew cert"
cert
fi
}

fn() {
clear
echo start
domain=$(cat /etc/xray/domain)
systemctl stop nginx
systemctl stop haproxy
cd /root/
clear
echo "starting...., Port 80 Akan di Hentikan Saat Proses install Cert"
certbot certonly --standalone --preferred-challenges http --agree-tos --email melon334456@gmail.com -d $domain 
cp /etc/letsencrypt/live/$domain/fullchain.pem /etc/xray/xray.crt
cp /etc/letsencrypt/live/$domain/privkey.pem /etc/xray/xray.key
cd /etc/xray
cat xray.crt xray.key >> /etc/xray/funny.pem
chmod 644 /etc/xray/xray.key
chmod 644 /etc/xray/xray.crt
chmod 644 /etc/xray/funny.pem
systemctl start haproxy
systemctl start nginx
}

cert() {
clear
echo -e "
========================
[ Generate Certificate ]
========================

1. Use Acme
2. Use Certbot
========================
"
read -p "Input Option: " akz
case $akz in
1) acme ;;
2) cert2 ;;
*) cert ;;
esac
}

dmsl() {
systemctl stop haproxy nginx
clear
#detail nama perusahaan
country="ID"
state="Central Kalimantan"
locality="Kab. Kota Waringin Timur"
organization="FN Project"
organizationalunit="99999"
commonname="FN"
email="rerechan0202@gmail.com"

# delete
rm -fr /etc/xray/xray.*
rm -fr /etc/xray/funny.pem

# make a certificate
openssl genrsa -out /etc/xray/xray.key 2048
openssl req -new -x509 -key /etc/xray/xray.key -out /etc/xray/xray.crt -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat /etc/xray/xray.key /etc/xray/xray.crt >> /etc/xray/funny.pem
chmod 644 /etc/xray/*

systemctl daemon-reload
service nginx restart
service haproxy restart
echo -e "Done Generate New Certificate"
}

dm1() {
clear
echo -e "
=================================
[ 菜单子域指向服务器 Cloudflare ]
=================================

1. Use Your Domain
2. Renew Certificate ( VPS IPv6 & IPv4 ) Acme
3. Renew Certificate ( VPS IPv4 Only ) Let's encrypt
4. Generare Direct Certificate ( VPS IPv4 Only ) Direct FN Project
=================================
     Press CTRL + C to Exit
"
read -p "Input Option: " apw
case $apw in
1) clear ; dm ;;
2) clear ; cert ;;
3) clear ; fn ;;
4) clear ; dmsl ;;
*) dm1 ;;
esac
}

dm1
}

    tz() {

    clear
echo -e "\e[32m════════════════════════════════════════" | lolcat
echo -e "\033[0;36m ═══[ \033[0m\e[1mCHANGE TIMEZONE\033[0;34m ]═══"
echo -e "\e[32m════════════════════════════════════════" | lolcat
echo -e " 1)  Malaysia (GMT +8:00)"
echo -e " 2)  Indonesia (GMT +7:00)"
echo -e " 3)  Singapore (GMT +8:00)"
echo -e " 4)  Brunei (GMT +8:00)"
echo -e " 5)  Thailand (GMT +7:00)"
echo -e " 6)  Philippines (GMT +8:00)"
echo -e " 7)  India (GMT +5:30)"
echo -e " 8)  Japan (GMT +9:00)"
echo -e " 9)  View Current Time Zone"
echo -e ""
echo -e "\e[1;32m══════════════════════════════════════════\e[m" | lolcat
echo -e " x)   MENU UTAMA"
echo -e "\e[1;32m══════════════════════════════════════════\e[m" | lolcat
echo -e ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in
		1)
		clear
		timedatectl set-timezone Asia/Kuala_Lumpur
		echo -e "\e[0m                                                   "
		echo -e "\e[1;32m══════════════════════════════════════════\e[m"
		echo -e "\e[0m                                                   "
	    echo -e "\e[0m            Time Zone Set Asia Malaysia  "
		echo -e "\e[0m                                                   "
	    echo -e "\e[1;32m══════════════════════════════════════════\e[m"
        read -sp " Press ENTER to go back"
        echo ""
        change_timezone
		;;
		2)
		clear
		timedatectl set-timezone Asia/Jakarta
		echo -e "\e[0m                                                   "
		echo -e "\e[1;32m══════════════════════════════════════════\e[m"
		echo -e "\e[0m                                                   "
	    echo -e "\e[0m           Time Zone Set Asia Indonesia "
		echo -e "\e[0m                                                   "
		echo -e "\e[1;32m══════════════════════════════════════════\e[m"
		echo ""
        read -sp " Press ENTER to go back"
        echo ""
        change_timezone
		;;
		3)
		clear
		timedatectl set-timezone Asia/Singapore
		echo -e "\e[0m                                                   "
		echo -e "\e[1;32m══════════════════════════════════════════\e[m"
		echo -e "\e[0m                                                   "
	    echo -e "\e[0m           Time Zone Set Asia Singapore "
		echo -e "\e[0m                                                   "
		echo -e "\e[1;32m══════════════════════════════════════════\e[m"
		echo ""
        read -sp " Press ENTER to go back"
        echo ""
        change_timezone
		;;
		4)
		clear
		timedatectl set-timezone Asia/Brunei
		echo -e "\e[0m                                                   "
		echo -e "\e[1;32m══════════════════════════════════════════\e[m"
		echo -e "\e[0m                                                   "
	    echo -e "\e[0m            Time Zone Set Asia Brunei   "
		echo -e "\e[0m                                                   "
		echo -e "\e[1;32m══════════════════════════════════════════\e[m"
		echo ""
        read -sp " Press ENTER to go back"
        echo ""
        change_timezone
		;;
		5)
		clear
		timedatectl set-timezone Asia/Bangkok
		echo -e "\e[0m                                                   "
		echo -e "\e[1;32m══════════════════════════════════════════\e[m"
		echo -e "\e[0m                                                   "
	    echo -e "\e[0m            Time Zone Set Asia Thailand  "
		echo -e "\e[0m                                                   "
		echo -e "\e[1;32m══════════════════════════════════════════\e[m"
		echo ""
        read -sp " Press ENTER to go back"
        echo ""
        change_timezone
		;;
		6)
		clear
		timedatectl set-timezone Asia/Manila
		echo -e "\e[0m                                                   "
		echo -e "\e[1;32m══════════════════════════════════════════\e[m"
		echo -e "\e[0m                                                   "
		echo -e "\e[0;37m        Time Zone Set Asia Philippines"
		echo -e "\e[0m                                                   "
		echo -e "\e[1;32m══════════════════════════════════════════\e[m"
		echo ""
        read -sp " Press ENTER to go back"
        echo ""
        change_timezone
		;;
		7)
		clear
		timedatectl set-timezone Asia/Kolkata
		echo -e "\e[0m                                                   "
		echo -e "\e[1;32m══════════════════════════════════════════\e[m"
		echo -e "\e[0m                                                   "
	    echo -e "\e[0m            Time Zone Set Asia India"
		echo -e "\e[0m                                                   "
		echo -e "\e[1;32m══════════════════════════════════════════\e[m"
		echo ""
        read -sp " Press ENTER to go back"
        echo ""
        change_timezone
		;;
        8)
		clear
		timedatectl set-timezone Asia/Tokyo
		echo -e "\e[0m                                                   "
		echo -e "\e[1;32m══════════════════════════════════════════\e[m"
		echo -e "\e[0m                                                   "
	    echo -e "\e[0m            Time Zone Set Asia Japan"
		echo -e "\e[0m                                                   "
		echo -e "\e[1;32m══════════════════════════════════════════\e[m"
		echo ""
        read -sp " Press ENTER to go back"
        echo ""
        change_timezone
		;;
		9)
		clear
        echo ""
		timedatectl
	    echo ""
        read -sp " Press ENTER to go back"
        echo ""
        change_timezone
		;;
        x)
		clear
		menu
		;;
		*)
		change_timezone
		;;
	esac
	
	}

report() {
clear
api="6187251915:AAH_6YqHWpElw-S7_n5208ibAEvHWshk6jg"
id="5979008084"
clear
echo -e "
====================
[  Report your Bug ]
====================

Note:
The bug will be read by the admin, if your bug is a problem in the new script your report will be answered by the admin, If the bug in the script is your own fault, you are not allowed to report it and the admin will not take care of your problem.
~ Farell Aditya Ardian Pratama Putra Utama
"
read -p "Describe the bug you are experiencing: " apws
read -p "Input Your WhatsApp Number or Telegram Username: " user

teks="
Report Bug📣📣
By $user
=======================

Complaint: $apws
======================="
TIME="10"
URL="https://api.telegram.org/bot${api}/sendMessage"
curl -s --max-time $TIME --data-urlencode "chat_id=${id}" --data-urlencode "text=${teks}" $URL
clear
echo -e "


Thank you for providing feedback, your feedback will be immediately read and replied to by the Admin. If no reply means this is not a problem with the script.
~ Farell Aditya Ardian Pratama Putra Utama
"
}

menu-detail() {
clear

gen() {
	echo -e "Updates"
	sleep 2
        for i in {1..5}; do
    	echo -ne ".\r"
    	sleep 0.5
    	echo -ne "..\r"
    	sleep 0.5
    	echo -ne "...\r"
    	sleep 0.5
    	echo -ne "....\r"
    	sleep 0.5
    	echo -ne ".....\r"
    	sleep 0.5
    	echo -ne "     \r"
    	sleep 0.5
	done
	echo -e "Done!"
	curl https://ifconfig.me/all
	sleep 1
	clear
	curl ipinfo.io/org > /root/.isp
	curl ipinfo.io/city > /root/.city
	curl ipinfo.io/region > /root/.region
	clear
	echo -e "\nSuccess Updates Information"
}

cek() {
response=$(curl -s https://1.1.1.1/cdn-cgi/trace)
warp_status=$(echo "$response" | grep -oP '(?<=warp=)[^ ]+')
if [ "$warp_status" = "on" ]; then
    service="on"
else
    service="off"
fi
clear
echo -e "

<= Detail your Server =>
========================
Autoscript by FN Project

#Port
- OpenSSH        : 22, 3303, 443, 53
- Dropbear       : 111, 109, 69, 143
- Stunnel        : 443, 777
- Slowdns        : 5300
- WS HTTPS       : 443
- WS HTTP        : 80, 2082, 8880
- OpenVPN        : 1194, 2200, 443, 80, 2095
- Noobz STD      : 8080
- Noobz SSL      : 8443
- SSLH           : 443
- TINC           : 655, 443
- XMPP           : 5222, 443
- ADB            : 5037, 443
- CHISEL         : 8000, 9443
- API            : 443, 80, 9000, 1278

#Protokol
- SSH, CHISEL, OVPN, SLOWDNS, STUNNEL, DROPBEAR
- NOOBZVPNS TCP STD, TCP SSL
- V2RAY/XRAY VMESS, VLESS, TROJAN, SOCKS5, SHADOWSOCKS
- SSLH, TINC, ZMPP, ADB, API, NGINX, HAPROXY

#Detail
- Domain = $(cat /etc/xray/domain)
- Warp   = ${service}
- ISP    = $(cat /root/.isp)
- Region = $(cat /root/.region)
- City   = $(cat /root/.city)
========================
"
}

status() {
clear
echo -e "


Coming Soon on Versi 1.12?
==========================
"
}

tamp() {
echo -e "
<=  Menu Detail  =>
===================

1. Update Information
2. Cek Detail Information
3. Cek Status Service Server
===================
"
read -p "Input Option: " opws
case $opws in
1) clear ; gen ;;
2) clear ; cek ;;
3) clear ; status ;;
*) clear ; tamp ;;
esac
}

tamp
}

menu-argo() {
# Fix Nameserver
[[ -e $(which curl) ]] && grep -q "1.1.1.1" /etc/resolv.conf || {
    echo "nameserver 1.1.1.1" | cat - /etc/resolv.conf > /etc/resolv.conf.tmp && mv /etc/resolv.conf.tmp /etc/resolv.conf
}

setup() {
# Clear Screen
clear

# Copy File Core
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
rm -fr cloudflared-linux-amd64.deb

# Membuat Konfigurasi
rm -fr /etc/cloudflared/*
mkdir -p /etc/cloudflared

clear
echo -e "Login to your cloudflare Account"
cloudflared tunnel login

clear
random=$(openssl rand -base64 15 | tr -dc 'a-z' | head -c 8)
echo " Create Node For Server Data "
echo "$random" > /root/.rcs
rcs=$(cat /root/.rcs)
cloudflared tunnel create $rcs
clear
id=$(basename ~/.cloudflared/*.json | sed 's/\.json$//')
echo -e "Save Your ID"
echo -e "ID: $id"
sleep 10
clear
echo -e "
Setup Your Domain Argo Tunnel
=============================

Example: mysubdom.myvpn.com

replace mysubdomain with your desired subdomain and replace myvpn.com with the domain you chose in cloudflare for argo tunnel after login
=============================
"
read -p "Input Xray Domain: " opws
read -p "Input SSH Domain: " sws
cloudflared tunnel route dns $rcs $opws
cloudflared tunnel route dns $rcs $sws
echo "$opws" > /etc/xray/domargo
echo "$sws" > /etc/xray/domssh
domargo="$opws"
domssh="$sws"
clear
# Membuar Konfigurasi
cat > /etc/cloudflared/config.yml << END
tunnel: $rcs
credentials-file: /root/.cloudflared/$id.json

ingress:
  - hostname: $domargo
    service: http://localhost:80
  - hostname: $domssh
    service: http://localhost:700
    headers:
      Upgrade: websocket
      Connection: Upgrade
  - service: http_status:404
END
# Menyimpan Domain
#echo "$domargo" > /etc/xray/domargo

# Menjalankan Servixe
sudo cloudflared service install
}

detail() {
clear
edussh_service=$(systemctl status cloudflared | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $edussh_service == "running" ]]; then
ssws="\e[1;32m[ ON ]\033[0m"
else
ssws="\e[1;31m[ OFF ]\033[0m"
fi
domargo=$(cat /etc/xray/domargo)
doms=$(cat /etc/xray/domssh)
clear
echo -e "
<= Detail Service Argo Tunnel =>
════════════════════════════════

Port HTTP:
- 80 ( Standar )
- 8080
- 8880
- 2052
- 2082
- 2086
- 2095

Port HTTPS:
- 443 ( Standar )
- 8443
- 2053
- 2083
- 2087
- 2096

#Detail
- Status       : $ssws
- Domain Nginx : $domargo
- Domain SSH WS: $doms
════════════════════════════════
Currently only supports connections on
-> SSH WebSockets
-> All Connection With Nginx
-> X-Ray/V2ray/V2rayfly/SibgBox Server
"
}
tamp() {
edussh_service=$(systemctl status cloudflared | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $edussh_service == "running" ]]; then
ssws="\e[1;32m[ ON ]\033[0m"
else
ssws="\e[1;31m[ OFF ]\033[0m"
fi
clear
echo -e "
<= Menu Argo Tunnel By FN =>
════════════════════════════
Status: $ssws

1. Install Argo
2. Restart Argo Tunnel
3. Detail Service Argo
0. Back To Menu Default
════════════════════════════
    Pres CTRL + C to Exit
"
read -p "Input Option: " opws
case $opws in
1) setup ;;
2) clear ; reres ;;
3) clear ; detail ;;
0) clear ; menu ;;
*) clear ; tamp ;;
esac
}

tamp
}

uninstall() {
clear

openeuler() {
clear
echo -e "
======================
<= OpenEuler Linux =>
======================

1. OpenEuler 20.03
2. OpenEuler 22.03
3. OpenEuler 24.03
======================
"
read -p "Input Option: " opn
case $opn in
1) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh openeuler 20.03 && reboot  ;;
2) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh openeuler 22.03 && reboot  ;;
3) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh openeuler 24.04 && reboot  ;;
*) openeuler
esac
}

opensuse() {
clear
echo -e "
====================
<= OpenSuse Linux =>
====================

1. OpenSuse 15.5
2. OpenSuse 16.6
3. OpenSuse tumbleweed
====================
"
read -p "Input Option: " osu
case $osu in
1) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh opensuse 15.5 && reboot  ;;
2) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh opensuse 15.6 && reboot  ;;
3) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh opensuse tumbleweed && reboot  ;;
*) opensuse ;;
esac
}

debian() {
clear
echo -e "
==================
<= Debian Linux =>
==================

1. Debian 9
2. Debian 10
3. Debian 11
4. Debian 12
==================
"
read -p "Input Option: " db
case $db in
1) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh debian 9 && reboot  ;;
2) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh debian 10 && reboot  ;;
3) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh debian 11 && reboot  ;;
4) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh debian 12 && reboot  ;;
*) debian ;;
esac
}

ubuntu() {
clear
echo -e "
==================
<= Ubuntu Linux =>
==================

1. Ubuntu 16.04
2. Ubuntu 18.04
3. Ubuntu 20.04
4. Ubuntu 22.04
5. Ubuntu 24.04
==================
"
read -p "Input Option: " wq
case $wq in
1) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh ubuntu 16.04 && reboot ;;
2) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh ubuntu 18.04 && reboot ;;
3) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh ubuntu 20.04 && reboot ;;
4) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh ubuntu 22.04 && reboot ;;
5) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh ubuntu 24.04 && reboot ;;
*) ubuntu ;;
esac
}

alpine() {
clear
echo -e "
==================
<= Alpine Linux =>
==================

1. Alpine 3.17
2. Alpine 3.18
3. Alpine 3.19
4. Alpine 3.20
==================
"
read -p "Input Option: " ap
case $ap in
1) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh alpine 3.17 && reboot ;;
2) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh alpine 3.18 && reboot ;;
3) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh alpine 3.19 && reboot ;;
4) cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh alpine 3.20 && reboot ;;
*) clear ; alpine ;;
esac
}

rocky() {
echo -e "
=================
<= Rocky Linux =>
=================

1. Rocky Linux 8
2. Rocky Linux 9
=================
"
read -p "Input Options: " opw
case $opw in
1) clear : cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh rocky 8 && reboot ;;
2) clear ; cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh rocky 9 && reboot ;;
*) rocky ;;
esac
}

information() {
uuid="123@@@"
clear
echo -e "
[ New Data Your VPS ]
=====================
Username: root
Password: $uuid
=====================
Please Save Your Data
"
read -p "Continue (y/n): " osw
if [[ $osw == "y" ]]; then
os
elif [[ $ip_version == "n" ]]; then
exit
fi
}

os() {
    clear
    echo -e "
< = [ Select New OS ] = >
=========================

01. Rocky
02. Alpine
03. Anolis
04. Debian
05. Ubuntu
06. RedHat
07. CentOS
08. AlmaLinux
09. OpenEuler
10. OpenSUSE
11. Arch Linux
12. NixOS Linux
13. Oracle Linux
14. Fedora Linux
15. Gentoo Linux
16. Open Cloud OS
17. Kali Linux / Kali Rolling

=========================
Press CTRL + C to Exit
"
    read -p "Input Options: " os
    case $os in
        01|1) clear ; rocky ;;
        02|2) clear ; alpine ;;
        03|3) clear ; cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh anolis 8 && reboot ;;
        04|4) clear ; debian ;;
        05|5) clear ; ubuntu ;;
        06|6) clear ; echo -e "Coming Soon" ;; #redhat;;
        07|7) clear ; cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh centos 9 && reboot ;;
        08|8) clear ; cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh alma 9 && reboot ;;
        09|9) clear ; openeuler ;;
        10) clear ; opensuse ;;
        11) clear ; cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh arch && reboot  ;;
        12) clear ; cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh nixos 24.05 && reboot ;;
        13) clear ; cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh oracle 8 && reboot ;;
        14) clear ; cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh fedora 40 && reboot ;;
        15) clear ; cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh gento && reboot  ;;
        16) clear ; cd /root ;curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh opencloudos 8 && reboot ;;
        17) clear ; cd /root ; curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh kali && reboot  ;;
        *) clear ; echo "Invalid option. Please select a valid number.";;
    esac
}

tampilan() {
clear
echo -e "
==========================
< = [ Menu Uninstall ] = >
==========================

1. Uninstall Script
2. Back To Default Menu
==========================
[ Press CTRL + C To Exit ]
==========================
  Autoscript FN Project
"
read -p "Input Option: " ws
case $ws in
1) clear ; information ;; #os ;;
2) menu ;;
*) tampilan ;;
esac
}

tampilan
}

tamp77() {
clear
echo -e "
======================
   [ 菜单系统面板 ]
======================

1. Menu Domain / Subdomain
2. Change Timezone Server
3. Report Bug on Autoscript
4. Menu Detail Information [ Other Menu ]
5. Menu Argo Tunnel Cloudflare [ Other Menu ]
6. Restart All Service On Server [ Other Menu ]
7. Uninstall This Autoscript [ Other Menu ]
8. Change Banner SSH [ Other Menu ]
9. Change Baner HTTP / 1.1 Switching Protocol
======================
Press CTRL + C to exit
"
read -p "Input Option: " opw
case $opw in
1) clear ; dm-menu ;;
2) clear ; tz ;;
3) clear ; report ;;
4) clear ; menu-detail ;;
5) clear ; menu-argo ;;
6) 
clear
#Enable
systemctl daemon-reload
systemctl enable proxy
systemctl enable server
systemctl enable badvpn
systemctl enable xray
systemctl enable edu
systemctl enable quota
systemctl enable http
systemctl enable trojan-go
#systemctl enable splithttp
#systemctl enable httpupgrade

#Start
systemctl start proxy
systemctl start server
systemctl start badvpn
systemctl start xray
systemctl start edu
systemctl start quota
systemctl start http
systemctl start trojan-go
#systemctl start splithttp
#systemctl start httpupgrade

#Restart
systemctl restart proxy
systemctl restart edu
systemctl restart server
systemctl restart badvpn
systemctl restart xray
systemctl restart sslh
systemctl restart haproxy
systemctl restart cron
systemctl restart dnstt
systemctl restart quota
systemctl restart http
systemctl restart trojan-go
#systemctl restart splithttp
#systemctl restart httpupgrade
#systemctl restart client-sldns
#systemctl restart server-sldns
                clear
                echo -e "\e[33m===================================\033[0m"
                echo -e "[ \033[32mInfo\033[0m ] Restart Begin"
                sleep 1
                echo -e "[ \033[32mok\033[0m ] Restarting xray Service (via systemctl) "
                sleep 0.5
                echo -e "[ \033[32mok\033[0m ] Restarting badvpn Service (via systemctl) "
                sleep 0.5
                echo -e "[ \033[32mok\033[0m ] Restarting websocket Service (via systemctl) "
                sleep 0.5
                echo -e "[ \033[32mInfo\033[0m ] ALL Service Restarted"
                echo ""
                echo -e "\e[33m===================================\033[0m"
                echo ""
;;
7) clear ; uninstall ;;
8) clear ; nano /etc/issue.net ;;
9) clear ; nano /usr/bin/ws ;;
*) clear ; tamp77 ;;
esac
}

tamp77
}

cek-service() {
# pewarna hidup
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BGreen='\e[1;32m'
BYellow='\e[1;33m'
BBlue='\e[1;34m'
BPurple='\e[1;35m'
NC='\033[0m'
yl='\e[32;1m'
bl='\e[36;1m'
gl='\e[32;1m'
rd='\e[31;1m'
mg='\e[0;95m'
blu='\e[34m'
op='\e[35m'
or='\033[1;33m'
bd='\e[1m'
color1='\e[031;1m'
color2='\e[34;1m'
color3='\e[0m'
# Getting
# IP Validation
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################

red='\e[1;31m'
green='\e[1;32m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
clear
# GETTING OS INFORMATION
source /etc/os-release
Versi_OS=$VERSION
ver=$VERSION_ID
Tipe=$NAME
URL_SUPPORT=$HOME_URL
basedong=$ID

# VPS ISP INFORMATION

echo -e "$ITAM"
REGION=$( curl -s ipinfo.io/region )
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
trgo="$(systemctl show trojan-go.service --no-page)"                                      
strgo=$(echo "${trgo}" | grep 'ActiveState=' | cut -f2 -d=)  

# CHEK STATUS 
tls_v2ray_status=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
nontls_v2ray_status=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
vless_tls_v2ray_status=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
vless_nontls_v2ray_status=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
shadowsocks=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
trojan_server=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
dropbear_status=$(/etc/init.d/dropbear status | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
stunnel_service=$(systemctl status haproxy | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
ssh_service=$(/etc/init.d/ssh status | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
vnstat_service=$(/etc/init.d/vnstat status | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
cron_service=$(/etc/init.d/cron status | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
fail2ban_service=$(/etc/init.d/fail2ban status | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
wstls=$(systemctl status edu.service | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
wsdrop=$(systemctl status edu.service | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
xray_service=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
nginx_service=$(systemctl status nginx | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
udpc=$(systemctl status udp-custom | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
dns1=$(systemctl status dnstt.service | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
# COLOR VALIDATION
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'

if [[ $xray_service == "running" ]]; then
status_xray="${GB}[ ON ]${NC}"
else
status_xray="${RB}[ OFF ]${NC}"
fi
if [[ $nginx_service == "running" ]]; then
status_nginx="${GB}[ ON ]${NC}"
else
status_nginx="${RB}[ OFF ]${NC}"
fi
clear

# STATUS SERVICE OPENVPN
if [[ $oovpn == "active" ]]; then
  status_openvpn="${GB}[ ON ]${NC}"
else
  status_openvpn="${RB}[ OFF ]${NC}"
fi

# STATUS SERVICE  SSH 
if [[ $ssh_service == "running" ]]; then 
   status_ssh="${GB}[ ON ]${NC}"
else
   status_ssh="${RB}[ OFF ]${NC}"
fi

# STATUS SERVICE  SQUID 
if [[ $squid_service == "running" ]]; then 
   status_squid="${GB}[ ON ]${NC}"
else
   status_squid="${RB}[ OFF ]${NC}"
fi

# STATUS SERVICE  VNSTAT 
if [[ $vnstat_service == "running" ]]; then 
   status_vnstat="${GB}[ ON ]${NC}"
else
   status_vnstat="${RB}[ OFF ]${NC}"
fi

# STATUS SERVICE  CRONS 
if [[ $cron_service == "running" ]]; then 
   status_cron="${GB}[ ON ]${NC}"
else
   status_cron="${RB}[ OFF ]${NC}"
fi

# STATUS SERVICE  FAIL2BAN 
if [[ $fail2ban_service == "running" ]]; then 
   status_fail2ban="${GB}[ ON ]${NC}"
else
   status_fail2ban="${RB}[ OFF ]${NC}"
fi

# STATUS SERVICE  TLS 
if [[ $tls_v2ray_status == "running" ]]; then 
   status_tls_v2ray="${GB}[ ON ]${NC}${NC}"
else
   status_tls_v2ray="${RB}[ OFF ]${NC}"
fi

# STATUS SERVICE NON TLS V2RAY
if [[ $nontls_v2ray_status == "running" ]]; then 
   status_nontls_v2ray="${GB}[ ON ]${NC}${NC}"
else
   status_nontls_v2ray="${RB}[ OFF ]${NC}"
fi

# STATUS SERVICE VLESS HTTPS
if [[ $vless_tls_v2ray_status == "running" ]]; then
  status_tls_vless="${GB}[ ON ]${NC}${NC}"
else
  status_tls_vless="${RB}[ OFF ]${NC}"
fi

# STATUS SERVICE VLESS HTTP
if [[ $vless_nontls_v2ray_status == "running" ]]; then
  status_nontls_vless="${GB}[ ON ]${NC}${NC}"
else
  status_nontls_vless="${RB}[ OFF ]${NC}"
fi
# STATUS SERVICE TROJAN
if [[ $trojan_server == "running" ]]; then 
   status_virus_trojan="${GB}[ ON ]${NC}${NC}"
else
   status_virus_trojan="${RB}[ OFF ]${NC}"
fi
# STATUS SERVICE DROPBEAR
if [[ $dropbear_status == "running" ]]; then 
   status_beruangjatuh="${GB}[ ON ]${NC}${NC}${NC}"
else
   status_beruangjatuh="${RB}[ OFF ]${NC}"
fi

# STATUS SERVICE STUNNEL
if [[ $stunnel_service == "running" ]]; then 
   status_stunnel="${GB}[ ON ]${NC}"
else
   status_stunnel="${RB}[ OFF ]${NC}"
fi
# STATUS SERVICE WEBSOCKET TLS
if [[ $wstls == "running" ]]; then 
   swstls="${GB}[ ON ]${NC}${NC}"
else
   swstls="${RB}[ OFF ]${NC}"
fi

# STATUS SERVICE WEBSOCKET DROPBEAR
if [[ $wsdrop == "running" ]]; then 
   swsdrop="${GB}[ ON ]${NC}${NC}"
else
   swsdrop="${RB}[ OFF ]${NC}"
fi

# STATUS SHADOWSOCKS
if [[ $shadowsocks == "running" ]]; then 
   status_shadowsocks="${GB}[ ON ]${NC}${NC}"
else
   status_shadowsocks="${RB}[ OFF ]${NC}"
fi

# STATUS SERVICE UDP CUSTOM
if [[ $udpc == "running" ]]; then
   udp2="${GB}[ ON ]${NC}${NC}"
else
   udp2="${RB}[ OFF ]${NC}"
fi

# STATUS SERVICE UDP CUSTOM
if [[ $dns1 == "running" ]]; then
   dns="${GB}[ ON ]${NC}${NC}"
else
   dns="${RB}[ OFF ]${NC}"
fi

# Status Service Trojan GO
if [[ $strgo == "active" ]]; then
  status_trgo="${GB}[ ON ]${NC}${NC}"
else
  status_trgo="${RB}[ OFF ]${NC}"
fi

# TOTAL RAM
total_ram=` grep "MemTotal: " /proc/meminfo | awk '{ print $2}'`
totalram=$(($total_ram/1024))

# KERNEL TERBARU
kernelku=$(uname -r)

# DNS PATCH
#tipeos2=$(uname -m)
# GETTING DOMAIN NAME
Domen="$(cat /etc/xray/domain)"
echo -e ""
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\e[33m             ❇ $(cat /etc/xray/domain) ❇           \033[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\e[33m❇\033[0m  SSH / TUN              :$status_ssh"
echo -e "\e[33m❇\033[0m  Dropbear               :$status_beruangjatuh"
echo -e "\e[33m❇\033[0m  XRAYS Vmess TLS        :$status_tls_v2ray"
echo -e "\e[33m❇\033[0m  XRAYS Vmess None TLS   :$status_nontls_v2ray"
echo -e "\e[33m❇\033[0m  XRAYS Vless TLS        :$status_tls_vless"
echo -e "\e[33m❇\033[0m  XRAYS Vless None TLS   :$status_nontls_vless"
echo -e "\e[33m❇\033[0m  XRAYS Trojan           :$status_virus_trojan"
echo -e "\e[33m❇\033[0m  Trojan GO/WS           :$status_trgo"
echo -e "\e[33m❇\033[0m  Websocket TLS          :$swstls"
echo -e "\e[33m❇\033[0m  Websocket None TLS     :$swstls"
echo -e "\e[33m❇\033[0m  UDP Custom             :$udp2"
echo -e "\e[33m❇\033[0m  DNS TUNNEL             :$dns"
echo -e "\e[33m❇\033[0m  Nginx Service          :$status_nginx"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
}

menu-dnstt() {
red='\e[31m'
green='\e[32m'
NC='\033[0;37m'
white='\033[0;97m'
    mna89() {
        clear
            status="$(systemctl show dnstt.service --no-page)"
            status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
        clear
        echo -e "
        =============================
        <= Slow DNS / DNSTT Tunnel =>
        ============================="
        
        if [ "${status_text}" == "active" ]; then
            echo -e "        ${white}慢速 DNS 隧道${NC}: "${green}"running"$NC" ✓"
        else
            echo -e "        ${white}慢速 DNS 隧道${NC}: "$red"not running (Error)"$NC" "
        fi

        echo -e "
        1. Change Nameserver
        2. Renew Public Key & Server Key
        3. Restart DNSTT Tunnel on server
        4. Exit to menu
        =============================
        Press CTRL + C to Exit"
        
        read -p "Input Options: " dn1
        case $dn1 in
            1)
                clear
                nsd=$(cat /etc/slowdns/nsdomain 2>/dev/null || echo "No nameserver found.")
                clear
                echo -e "
                =================
                Change Nameserver
                =================
                Nameserver: $nsd
                "
                read -p "Input Nameserver: " nsdomen
                clear
                echo "${nsdomen}" > /etc/slowdns/nsdomain
                systemctl stop dnstt.service
                systemctl disable dnstt.service
                clear
                
                echo -e "                [Unit]
                Description=SlowDNS FN Project Autoscript Service
                Documentation=https://t.me/fn_project
                After=network.target nss-lookup.target

                [Service]
                Type=simple
                User=root
                CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
                AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
                NoNewPrivileges=true
                ExecStart=/etc/slowdns/dns-server -udp :5300 -privkey-file /etc/slowdns/server.key $nsdomen 127.0.0.1:22
                Restart=on-failure

                [Install]
                WantedBy=multi-user.target" > /etc/systemd/system/dnstt.service
                systemctl daemon-reload
                systemctl enable dnstt
                systemctl start dnstt
                clear
                echo -e "
                Success Change Nameserver DNSTT
                ===============================
                New Nameserver: $nsdomen
                ==============================="
                ;;
            2)
                clear
                systemctl stop dnstt.service
                systemctl disable dnstt.service
                clear
                chmod +x /etc/slowdns/dns-server
                /etc/slowdns/dns-server -gen-key -privkey-file /etc/slowdns/server.key -pubkey-file /etc/slowdns/server.pub
                systemctl daemon-reload
                systemctl enable dnstt.service
                systemctl start dnstt.service
                clear
                echo -e "
                Success Renew Public Key & Server Key Slowdns
                ============================================="
                ;;
            3)
                clear
                systemctl daemon-reload
                systemctl restart dnstt.service
                clear
                echo -e "
                Success Restart SlowDNS
                ========================"
                ;;
            4)
                menu
                ;;
            *)
                clear
                mna89
                ;;
        esac
    }
    mna89
}

menu() {
clear
# @Rerechan02 | @fn_project Telegram
# This code is just a sample
# ___________________________________________

# the domain you want to ping test
url="nhentai.net"
# do a ping check against the url and cut only the ping text
ping=$(ping_result=$(ping -c 1 $url | grep -oP 'time=\K\d+\.\d+')
if (( $(echo "$ping_result < 100" | bc -l) )); then
    echo -e "\e[32m$ping_result ms\e[0m"
elif (( $(echo "$ping_result < 200" | bc -l) )); then
    echo -e "\e[33m$ping_result ms\e[0m"
else
    echo -e "\e[31m$ping_result ms\e[0m"
fi)
clear
# OS Uptime
uptime="$(uptime -p | cut -d " " -f 2-10)"
DATE2=$(date -R | cut -d " " -f -5)
tram=$(free -m | awk 'NR==2 {print $2}')
uram=$(free -m | awk 'NR==2 {print $3}')
fram=$(free -m | awk 'NR==2 {print $4}')
nama=$(cat /etc/xray/.email)
# // Exporting Language to UTF-8
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White
UWhite='\033[4;37m'       # White
On_IPurple='\033[0;105m'  #
On_IRed='\033[0;101m'
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White
NC='\e[0m'
#Download/Upload today
dtoday="$(vnstat -i eth0 | grep "today" | awk '{print $2" "substr ($3, 1, 1)}')"
utoday="$(vnstat -i eth0 | grep "today" | awk '{print $5" "substr ($6, 1, 1)}')"
ttoday="$(vnstat -i eth0 | grep "today" | awk '{print $8" "substr ($9, 1, 1)}')"
#Download/Upload yesterday
dyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $2" "substr ($3, 1, 1)}')"
uyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $5" "substr ($6, 1, 1)}')"
tyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $8" "substr ($9, 1, 1)}')"
#Download/Upload current month
dmon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $3" "substr ($4, 1, 1)}')"
umon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $6" "substr ($7, 1, 1)}')"
tmon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $9" "substr ($10, 1, 1)}')"
clear

# // Exporting Language to UTF-8

export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'


# // Export Color & Information
export red='\033[0;31m'
export green='\033[0;32m'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT='\033[0;37m'
export NC='\033[0m'

# // Export Banner Status Information
export EROR="[${RED} EROR ${NC}]"
export INFO="[${YELLOW} INFO ${NC}]"
export OKEY="[${GREEN} OKEY ${NC}]"
export PENDING="[${YELLOW} PENDING ${NC}]"
export SEND="[${YELLOW} SEND ${NC}]"
export RECEIVE="[${YELLOW} RECEIVE ${NC}]"

# // Export Align
export BOLD="\e[1m"
export WARNING="${RED}\e[5m"
export UNDERLINE="\e[4m"

# // Clear
clear
cek=$(service ssh status | grep active | cut -d ' ' -f5)
if [ "$cek" = "active" ]; then
stat=-f5
else
stat=-f7
fi
ssh=$(service ssh status | grep active | cut -d ' ' $stat)
if [ "$ssh" = "active" ]; then
ressh="${green}ON${NC}"
else
ressh="${red}OFF${NC}"
fi
sshstunel=$(service proxy status | grep active | cut -d ' ' $stat)
if [ "$sshstunel" = "active" ]; then
resst="${green}ON${NC}"
else
resst="${red}OFF${NC}"
fi
sshws=$(service edu status | grep active | cut -d ' ' $stat)
if [ "$sshws" = "active" ]; then
ressshws="${green}ON${NC}"
else
ressshws="${red}OFF${NC}"
fi
ngx=$(service nginx status | grep active | cut -d ' ' $stat)
if [ "$ngx" = "active" ]; then
resngx="${green}ON${NC}"
else
resngx="${red}OFF${NC}"
fi
dbr=$(service dropbear status | grep active | cut -d ' ' $stat)
if [ "$dbr" = "active" ]; then
resdbr="${green}ON${NC}"
else
resdbr="${red}OFF${NC}"
fi
v2r=$(service xray status | grep active | cut -d ' ' $stat)
if [ "$v2r" = "active" ]; then
resv2r="${green}ON${NC}"
else
resv2r="${red}OFF${NC}"
fi
m1=$(curl -s ifconfig.me)
m2=$(curl -s ifconfig.me)
IP="$m1 / $m2"
clear
echo -e "\e[33m ==================================================\033[0m" | lolcat
echo -e "                • FN Project •                 "
echo -e "\e[33m ==================================================\033[0m" | lolcat
echo -e "\e[33m OS            \e[0m:  "`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`
echo -e "\e[33m IP            \e[0m:  $IP"
echo -e "\e[33m RAM           \e[0m:  $uram MB / $tram MB"
echo -e "\e[33m ISP           \e[0m:  $(cat /root/.isp)"
echo -e "\e[33m CITY          \e[0m:  $(cat /root/.city)"
echo -e "\e[33m DOMAIN        \e[0m:  $(cat /etc/xray/domain)"
echo -e "\e[33m DATE & TIME   \e[0m:  $DATE2"
echo -e "\e[33m UPTIME        \e[0m:  $uptime"
echo -e "\e[33m Your Ping     \e[0m:  $ping \e[037;1m [ $url ]"
echo -e "\e[33m ==================================================\033[0m" | lolcat
echo -e " ${BICyan}SSH${NC}: $ressh"" ${BICyan}NGINX${NC}: $resngx"" ${BICyan}X-RAY${NC}: $resv2r"
echo -e " ${BICyan}STUNNEL${NC}: $resst"" ${BICyan}DROPBEAR${NC}: $resdbr"" ${BICyan}WS${NC}: $ressshws "
echo -e "\e[33m ==================================================\033[0m" | lolcat
echo -e "                 • SCRIPT MENU •                 "
echo -e "\e[33m ==================================================\033[0m" | lolcat
echo -e " [\e[36m 01 \e[0m] SSH Menu        [\e[36m 06 \e[0m] Bot Menu"
echo -e " [\e[36m 02 \e[0m] XRAY Menu       [\e[36m 07 \e[0m] Backup Menu"
echo -e " [\e[36m 03 \e[0m] NoobZ Menu      [\e[36m 08 \e[0m] System Menu"
echo -e " [\e[36m 04 \e[0m] Warp+ Menu      [\e[36m 09 \e[0m] Api Seting Menu"
echo -e " [\e[36m 05 \e[0m] Trojan Go Menu  [\e[36m 10 \e[0m] DNS Tunnel Menu"
echo -e ""
echo -e " [\e[36m•x\e[0m] Exit Panel"
echo -e ""
echo -e "\e[33m ==================================================\033[0m" | lolcat
echo -e "${BICyan}$NC ${BICyan}HARI ini${NC}: ${red}$ttoday$NC ${BICyan}KEMARIN${NC}: ${red}$tyest$NC ${BICyan}BULAN${NC}: ${red}$tmon$NC $NC"
echo -e "\e[33m ==================================================\033[0m" | lolcat
echo -e " \e[33mClient Name   \E[0m: @Rerechan02"
echo -e " \e[33mScrip Version \E[0m: FN Project X Rerechan02"
echo -e "\e[33m ==================================================\033[0m" | lolcat
echo -e   ""
read -p " Select menu : " opt
case $opt in
01|1) clear ; menu-ssh ;;
02|2) clear ; menu-xray ;;
03|3) clear ; nmenu ;;
04|4) clear ; menu-warp ;;
05|5) clear ; menu-trojan ;;
06|6) clear ; botmenu ;;
07|7) clear ; bmenu ;;
08|8) clear ; menu-set ;;
09|9) clear ; menu-api ;;
10) clear ; menu-dnstt ;;
11) clear ; cek-service ;;
X|XX|xx|x) exit ;;
*) menu ;;
esac
}

menu
