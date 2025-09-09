#!/bin/bash
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
echo -e "### $user $exp" >> /etc/trojan-go/akun.conf
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
clear
echo -e "$TEKS"