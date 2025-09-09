#!/bin/bash
#  |════════════════════════════════════════════════════════════════════════════════════|
#  • Autoscript AIO Lite Menu By FN Project                                          |
#  • FN Project Developer @Rerechan02 | @PR_Aiman | @farell_aditya_ardian            |
#  • Copyright 2024 18 Marc Indonesia [ Kebumen ] | [ Johor ] | [ 上海，中国 ]       |
#  |════════════════════════════════════════════════════════════════════════════════════|
#
domain=$(cat /etc/xray/domain)
clear
user=trial`</dev/urandom tr -dc 0-9 | head -c3`
pass="1"
masaaktif="1"
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
Expired   : 60 Minutes
════════════════════════════"
CHATID=$(cat /etc/funny/.chatid)
KEY=$(cat /etc/funny/.keybot)
TIME="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
curl -s --max-time $TIME -d "chat_id=$CHATID&text=$TEKS" $URL
echo "noobzvpns --remove-user ${user} && systemctl restart noobzvpns" | at now + 60 minutes
clear
echo "$TEKS"