#!/bin/bash


### // Colloring
export r='\033[0;31m'
export g='\033[0;32m'
export NC='\033[0m'

## // Clearing CLI
clear

install() {

tools() {
apt install wget -y
apt install python3 -y
apt install python3-pip -y
}

clone() {
cd /usr/local/bin
git clone https://github.com/DindaPutriFN/rerechan
clear
cd rerechan
apt install libsystemd-dev -y
apt install pkg-config -y
pip3 install -r requirements.txt
pip3 install pystemd
cd /usr/local/bin
clear
}

konfigurasi() {
clear
echo -e "
Setup Bot Panel
===============

Make sure the Telegram panel bot token API data is different from the notification bot API token
"
read -p "Input Token: " token
read -p "Input ID Admin: " id
clear

#Data
rm -fr /usr/local/bin/rerechan/database.txt
DM=$(cat /etc/xray/domain)
NSD=$(cat /etc/slowdns/nsdomain)
PUB=$(cat /etc/slowdns/server.pub)
clear
echo -e BOT_TOKEN='"'$token'"' >> /usr/local/bin/rerechan/database.txt
echo -e ADMIN='"'$id'"' >> /usr/local/bin/rerechan/database.txt
echo -e DOMAIN='"'$DM'"' >> /usr/local/bin/rerechan/database.txt
echo -e HOST='"'$NSD'"' >> /usr/local/bin/rerechan/database.txt
echo -e PUB='"'$PUB'"' >> /usr/local/bin/rerechan/database.txt
}

service() {
cd /usr/local/bin/rerechan
rm -fr .*
cd
clear

# Looping File
if [ -e /etc/systemd/system/resbot.service ]; then
echo ""
else
rm -fr /etc/systemd/system/resbot.service
fi

# Create File
echo -e "
[Unit]
Description=Bot Panel Telegram FN Project
After=network.target

[Service]
WorkingDirectory=/usr/local/bin
ExecStart=/usr/bin/python3 -m rerechan
Restart=always

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/resbot.service
systemctl daemon-reload
systemctl enable resbot.service
systemctl start resbot.service
}

last() {
bot_service=$(systemctl status resbot | grep active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $bot_service == "running" ]]; then 
   sts_bot="${g}[ON]${NC}"
else
   sts_bot="${r}[OFF]${NC}"
fi
clear
echo -e "
Database Bot Panel
==================

ADMIN      : $id
Token Bot  : $token
Domain     : $DM
Nameserver : $NSD
Publik Key : $PUB

STATUS BOT PANEL : $sts_bot
==================
"
}

ins() {
tools
clone
konfigurasi
service
last
}

ins
}

uninstall() {
clear
echo -e "Starting Uninstall Bot"
systemctl stop resbot
systemctl disable resbot
rm -fr /etc/systemd/system/resbot.service
rm -fr /usr/local/bin/rerechan
clear
apt autoremove
clear
echo -e "
\n
Success Uninstall Bot Panel
"
}

restart() {
clear
systemctl daemon-reload
systemctl restart resbot
clear
echo -e "Done Restart Bot Panel"
}

menu7() {
bot_service=$(systemctl status resbot | grep active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $bot_service == "running" ]]; then 
   sts_bot="${g}[ON]${NC}"
else
   sts_bot="${r}[OFF]${NC}"
fi
clear
echo -e "
======================
[ Bot Panel Telegram ]
======================
状態: $sts_bot

1. Install Bot Panel
2. Uninstall Bot Panel
3. Restart Service Bot Panel
4. Back To Default Menu
======================
Press CTRL + C to Exit
"
read -p "Input Option: " opws
case $opws in
1) clear ; install ;;
2) clear ; uninstall ;;
3) clear ; restart ;;
4) menu ;;
*) menu7 ;;
esac
}

menu7
