#!/bin/bash

# Cek apakah `curl` terpasang, lalu tambahkan `1.1.1.1` ke `/etc/resolv.conf` jika belum ada
[[ -e $(which curl) ]] && grep -q "1.1.1.1" /etc/resolv.conf || { 
    echo "nameserver 1.1.1.1" | cat - /etc/resolv.conf > /etc/resolv.conf.tmp && mv /etc/resolv.conf.tmp /etc/resolv.conf
}

# Informasi skrip dan tim pengembang
#  |=================================================================================|
#  • Autoscript AIO Lite Menu By FN Project                                          |
#  • FN Project Developer @Rerechan02 | @PR_Aiman | @farell_aditya_ardian            |
#  • Copyright 2024 18 Marc Indonesia [ Kebumen ] | [ Johor ] | [ 上海，中国 ]       |
#  |=================================================================================|

# Inisialisasi variabel
date=$(date)
domain=$(cat /etc/xray/domain)
cpt="$date / $domain"
MYIP=$(curl -s ifconfig.me)

# Proses Backup
clear
echo "Mohon Menunggu, Proses Backup sedang berlangsung!!"
rm -rf /root/backup /root/*
mkdir /root/backup
cp /etc/passwd /root/backup/
cp /etc/group /root/backup/
cp /etc/shadow /root/backup/
cp /etc/gshadow /root/backup/
cp -r /etc/trojan-go /root/backup/trojan-go/
cp -r /etc/xray /root/backup/xray
cp -r /etc/funny /root/backup/funny
cp -r /etc/noobzvpns /root/backup/noobzvpns
cp -r /etc/cloudflared /root/backup/cloudflared
cp -r /root/.cloudflared /root/backup/.cloudflared

# Membuat file ZIP dari backup
cd /root
zip -r backup.zip backup > /dev/null 2>&1

# Upload file ZIP ke file.io dan ambil link
random_number=$(gpg --gen-random 2 90 | tr -dc A-Za-z0-9 | sed 's/\(..\)/\1:/g; s/.$//')
file_path="/root/backup.zip"
api_url="https://file.io"
expiry_duration=$((14 * 24 * 60 * 60))
response=$(curl -s -F "file=@$file_path" -F "expiry=$expiry_duration" $api_url)
upload_link=$(echo $response | jq -r .link)
id_link=$(echo $response | jq -r .key)

TEKS="
[ Information Your Backup Data ]
================================

Your ID    : $id_link
Your IP    : $MYIP
Link Backup: $upload_link
Date / Domain: $date / $domain
================================
Your File Backup AutoDelete After 7 Days
"
# Cek dan buat file backup.log jika tidak ada
if [ ! -f /etc/funny/backup.log ]; then
    touch /etc/funny/backup.log
    echo "File /etc/funny/backup.log telah dibuat."
else
    echo "File /etc/funny/backup.log sudah ada, melanjutkan perintah selanjutnya."
fi

# Menyimpan Log Backup
echo "$TEKS" >> /etc/funny/backup.log
clear
rm -fr /root/backup*
clear
echo "$TEKS"
echo "Please Save your Link Backup"