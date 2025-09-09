#!/bin/bash
ip=$(curl -s ifconfig.me)
domain=$(cat /etc/xray/domain)
date=$(date)
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
#echo "Telah Berjaya Melakukan Backup"
  echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "SUCCESSFULL RESTORE YOUR VPS"
    echo -e "Please Save The Following Data"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "Your VPS IP : $ip"
    echo -e "DOMAIN      : $domain"
    echo -e "DATE        : $date"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━"