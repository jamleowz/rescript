#!/bin/bash
#
#  |════════════════════════════════════════════════════════════════════════════════════════════════════════════════|
#  • Autoscript AIO Lite Menu By FN Project                                          |
#  • FN Project Developer @Rerechan02 | @PR_Aiman | @farell_aditya_ardian            |
#  • Copyright 2024 18 Marc Indonesia [ Kebumen ] | [ Johor ] | [ 上海，中国 ]       |
#  |════════════════════════════════════════════════════════════════════════════════════════════════════════════════|
#

link="https://raw.githubusercontent.com/DindaPutriFN/DindaPutriFN/main/api"
clear
#echo "Port 22
Port 3303
#Port 53" >> /etc/ssh/sshd_config
#systemctl stop systemd-resolved
systemctl restart ssh
systemctl restart sshd
#systemctl start systemd-resolved
clear
[[ -e $(which curl) ]] && if [[ -z $(cat /etc/resolv.conf | grep "1.1.1.1") ]]; then cat <(echo "nameserver 1.1.1.1") /etc/resolv.conf > /etc/resolv.conf.tmp && mv /etc/resolv.conf.tmp /etc/resolv.conf; fi
clear

#Bikin File
clear
mkdir -p /etc/slowdns
mkdir -p /etc/xray
mkdir -p /etc/funny
mkdir -p /var
mkdir -p /var/lib
mkdir -p /var/log
mkdir -p /var/log/xray
touch /var/log/xray/access.log
chmod +x /var/log/xray/*
clear

#domain
read -rp "Masukkan Domain: " domain
#read -p "Nameserver: " nsdomain
#read -p "Api Bot Token: " api
#read -p "Admin ID Telegram: " id
#echo "$api" > /etc/funny/.keybot
#echo "$id" > /etc/funny/.chatid
#echo "$nsdomain" >/etc/slowdns/nsdomain
echo "$domain" > /etc/xray/domain

#Key
uuid=$(cat /proc/sys/kernel/random/uuid)
echo -e "${uuid}" > /etc/xray/.key
chmod +x /etc/xray/.key
api773=$(cat /etc/xray/.key)

#email
#read -rp "Masukkan Email anda: " email

#Preparation
clear
cd;
apt-get update;

#Remove unused Module
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;
apt-get -y --purge remove apache2*
apt remove apache2 -y
apt autoremove -y

clear

#install toolkit
apt-get install libio-socket-inet6-perl libsocket6-perl libcrypt-ssleay-perl libnet-libidn-perl perl libio-socket-ssl-perl libwww-perl libpcre3 libpcre3-dev zlib1g-dev dbus iftop zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr dnsutils sudo at htop iptables bsdmainutils cron lsof lnav -y

#Install tools
apt install binutils -y
apt install socat -y
apt install lolcat -y
apt install ruby -y
gem install lolcat
apt install lolcat -y
apt install wget curl -y
apt install htop -y
apt install speedtest-cli -y
apt install cron -y
apt install figlet -y
apt install zip unzip -y
apt install jq -y
apt install certbot -y
apt install python2 -y
apt install python3 -y
apt install screen -y
apt install haproxy -y
apt install at -y

# Information
curl ipinfo.io/org > /root/.isp
curl ipinfo.io/city > /root/.city
curl ipinfo.io/region > /root/.region

# // Menginstall Dropbear
apt install dropbear -y
rm /etc/default/dropbear
rm /etc/issue.net
cat> /etc/issue.net << END
</strong> <p style="text-align:center"><b> <br><font color="#00FFE2"<br>┏━━━━━━━━━━━━━━━┓<br> RERECHAN STORE<br>┗━━━━━━━━━━━━━━━┛<br></font><br><font color="#00FF00"></strong> <p style="text-align:center"><b> <br><font color="#00FFE2">क═══════क⊹⊱✫⊰⊹क═══════क</font><br><font color='#FFFF00'><b> ★ [ ༆Hʸᵖᵉʳ᭄W̺͆E̺͆L̺͆C̺͆O̺͆M̺͆E̺͆
T̺͆O̺͆ M̺͆Y̺͆ S̺͆E̺͆R̺͆V̺͆E̺͆R̺͆ V͇̿I͇̿P͇̿ ] ★ </b></font><br><font color="#FFF00">ℝ𝕖𝕣𝕖𝕔𝕙𝕒𝕟 𝕊𝕥𝕠𝕣𝕖</font><br> <font color="#FF00FF">❖Ƭʜᴇ No DDOS</font><br> <font color="#FF0000">❖Ƭʜᴇ No Torrent</font><br> <font color="#FFB1C2">❖Ƭʜᴇ No Bokep </font><br> <font color="#FFFFFF">❖Ƭʜᴇ No Hacking</font><br>
<font color="#00FF00">❖Ƭʜᴇ No Mining</font><br> <font color="#00FF00">➳ᴹᴿ᭄ Oder / Trial :
https://wa.me/62858630085249 </font><br>
<font color="#00FFE2">क═══════क⊹⊱✫⊰⊹क═══════क</font><br></font><br><font color="FFFF00">❖Ƭʜᴇ WHATSAPP GRUP => https://chat.whatsapp.com/LlJmbvSQ2DsHTA1EccNGoO</font><br>
END
clear
cat>  /etc/default/dropbear << END
# disabled because OpenSSH is installed
# change to NO_START=0 to enable Dropbear
NO_START=0
# the TCP port that Dropbear listens on
DROPBEAR_PORT=111

# any additional arguments for Dropbear
DROPBEAR_EXTRA_ARGS="-p 109 -p 69 "

# specify an optional banner file containing a message to be
# sent to clients before they connect, such as "/etc/issue.net"
DROPBEAR_BANNER="/etc/issue.net"

# RSA hostkey file (default: /etc/dropbear/dropbear_rsa_host_key)
#DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"

# DSS hostkey file (default: /etc/dropbear/dropbear_dss_host_key)
#DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"

# ECDSA hostkey file (default: /etc/dropbear/dropbear_ecdsa_host_key)
#DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"

# Receive window size - this is a tradeoff between memory and
# network performance
DROPBEAR_RECEIVE_WINDOW=65536
END
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
dd=$(ps aux | grep dropbear | awk '{print $2}')
kill $dd
clear
systemctl daemon-reload
/etc/init.d/dropbear restart
clear

#Mengintall Xray
cd /etc/xray
wget -q -O config.json "https://raw.githubusercontent.com/DindaPutriFN/sslh/main/config.json"
#wget -q -O http.json "https://raw.githubusercontent.com/DindaPutriFN/sslh/main/http.json"
#wget -q -O split.json "https://raw.githubusercontent.com/DindaPutriFN/sslh/main/split.json"
chmod +x /etc/xray/*

# Other
cd /usr/bin
wget -q -O m.zip "https://raw.githubusercontent.com/DindaPutriFN/menu/main/.1.13.zip"
yes A | unzip m.zip
rm -fr m.zip
chmod +x *
cd /usr/bin/rere
chmod +x *
cd

#Apache2 Fix
systemctl daemon-reload
systemctl stop apache2
systemctl disable apache2

# Seting Stunnel4
apt install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/xray/funny.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[openssh]
accept = 777
connect = 127.0.0.1:3303

[dropbear]
accept = 447
connect = 127.0.0.1:109

[openvpn]
accept = 444
connect = 127.0.0.1:1194
END

#Set Timezone GMT+7
timedatectl set-timezone Asia/Jakarta;

#install latest xray
cd /usr/bin
wget -q https://raw.githubusercontent.com/DindaPutriFN/DindaPutriFN/main/api/xray.zip
yes A | unzip xray.zip ; rm -fr xray.zip
chmod +x *.dat
chmod +x xray
cd

#profile
apt install neofetch -y
cat > /root/.profile << END
if [ "$BASH" ]; then
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
fi
mesg n || true
clear
#neofetch --ascii_distro Arcolinux_small
info
END
chmod 644 /root/.profile

#crontab
echo "0 0,6,12,18 * * * root backup
0,15,30,45 * * * * root /usr/bin/xp
*/5 * * * * root limit-ip
*/30 * * * * root clear-log
*/5 * * * * root kill-quota" >> /etc/crontab
systemctl restart cron

#Install VNSTAT
apt install vnstat -y

# Menginstal Argo Core
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
rm -fr cloudflared-linux-amd64.deb

# Menginstall Nodejs
apt install nodejs -y

#Install Speedtest
#curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
#sudo apt-get install speedtest -y

#install nginx
apt install nginx -y
rm /etc/nginx/conf.d/default.conf
cd /etc/nginx 
rm -fr nginx.conf
wget -q -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/DindaPutriFN/sslh/main/nginx.conf"
cd

#detail nama perusahaan
country="ID"
state="Central Kalimantan"
locality="Kab. Kota Waringin Timur"
organization="FN Project"
organizationalunit="99999"
commonname="FN"
email="rerechan0202@gmail.com"

# delete
systemctl stop nginx haproxy
rm -fr /etc/xray/xray*
rm -fr /etc/xray/funny.pem

# make a certificate
openssl genrsa -out /etc/xray/xray.key 2048
openssl req -new -x509 -key /etc/xray/xray.key -out /etc/xray/xray.crt -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat /etc/xray/xray.key /etc/xray/xray.crt >> /etc/xray/funny.pem
chmod 644 /etc/xray/*
systemctl restart nginx haproxy

#install socat
apt install iptables -y
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion -y

#install firewall
apt install ufw -y

# swap ram 2gb
#wget https://raw.githubusercontent.com/Cretezy/Swap/master/swap.sh -O swap
#sh swap 2G
#rm swap

# Make Other
touch /etc/xray/proxy.log

# Install NoobzVPN'S
# [ Create Directory File ]
mkdir -p /etc/noobzvpns

# [ Membersihkan layar ]
clear

# [ Membuat Json Config yang di gunakan pada server ]
cat > /etc/noobzvpns/config.json <<-JSON
{
	"tcp_std": [
		8080
	],
	"tcp_ssl": [
		8443
	],
	"ssl_cert": "/etc/noobzvpns/cert.pem",
	"ssl_key": "/etc/noobzvpns/key.pem",
	"ssl_version": "AUTO",
	"conn_timeout": 60,
	"dns_resolver": "/etc/resolv.conf",
	"http_ok": "HTTP/1.1 101 Switching Protocols[crlf]Upgrade: websocket[crlf][crlf]"
}
JSON
# Port Dari tcp_std & tcp_ssl edit sesuai kemauan kalian agar tidak bentrok dengan service lain pada vps kalian


# [ wget ambil file ]
wget -q -O /usr/bin/noobzvpns "https://github.com/noobz-id/noobzvpns/raw/master/noobzvpns.x86_64"
wget -q -O /etc/noobzvpns/cert.pem "https://github.com/noobz-id/noobzvpns/raw/master/cert.pem"
wget -q -O /etc/noobzvpns/key.pem "https://github.com/noobz-id/noobzvpns/raw/master/key.pem"


# [ memberi izin pada file json & cert + key ]
chmod +x /etc/noobzvpns/*

# [ Memberi Izin Exec pada file biner ]
chmod +x /usr/bin/noobzvpns

# [ Mengambil Service yang di perlukan ]
wget -q -O /etc/systemd/system/noobzvpns.service "https://github.com/noobz-id/noobzvpns/raw/master/noobzvpns.service"

# [ Enable Service ]
systemctl enable noobzvpns

# [ Firewall Port Noobz ]
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8443 -j ACCEPT
sudo ufw allow 8080/tcp
sudo ufw allow 8443/tcp

# [ Restart Service ]
systemctl restart noobzvpns

# [ Membersihkan layar ]
clear

# Install Slowdns
cd
wget -q https://raw.githubusercontent.com/DindaPutriFN/Autoscript/main/slowdns.sh; chmod +x slowdns.sh; ./slowdns.sh; rm -fr slowdns.sh

# Install Chisel Proxy
cd
wget -q https://raw.githubusercontent.com/DindaPutriFN/Autoscript/main/chisel.sh; chmod +x chisel.sh; ./chisel.sh; rm -fr chisel.sh

#Install Lainya
cd
wget -q https://raw.githubusercontent.com/Rerechan02/UDP/main/udp.sh && chmod +x udp.sh && ./udp.sh

# Install Plugin HideSSH
cd
wget -q https://github.com/praiman99/Plugin-FN/raw/Beginner/plugin.sh ; chmod 777 plugin.sh ; ./plugin.sh ; rm -fr plugin.sh

# Install Warp Cloudflare
cd /root; wget -O wgcf.sh "https://raw.githubusercontent.com/DindaPutriFN/warp/main/install-warp.sh"; chmod +x /root/*; /root/wgcf.sh; rm -fr /root/*

# Install Backup Google Drive
cd /root
wget https://raw.githubusercontent.com/DindaPutriFN/enhanced/main/set-br.sh
chmod +x /root/*
cd /root
./set-br.sh
rm -fr /root/*

clear

#Install OpenVPN
cd
wget -q https://raw.githubusercontent.com/DindaPutriFN/DindaPutriFN/main/openvpn/vpn.sh && chmod +x vpn.sh && ./vpn.sh

# // Membuat Service
cat> /etc/systemd/system/xray.service << END
[Unit]
Description=Xray by FunnyVPN
Documentation=https://indo-ssh.com
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/xray -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
END

#cat> /etc/systemd/system/httpupgrade.service << END
#[Unit]
#Description=Xray by FunnyVPN
#Documentation=https://indo-ssh.com
#After=network.target nss-lookup.target
#
#[Service]
#User=root
#CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
#AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
#NoNewPrivileges=true
#ExecStart=/usr/bin/xray -config /etc/xray/http.json
#Restart=on-failure
#RestartPreventExitStatus=23
#
#[Install]
#WantedBy=multi-user.target
#END
#
#cat> /etc/systemd/system/splithttp.service << END
#[Unit]
#Description=Xray by FunnyVPN
#Documentation=https://indo-ssh.com
#After=network.target nss-lookup.target
#
#[Service]
#User=root
#CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
#AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
#NoNewPrivileges=true
#ExecStart=/usr/bin/xray -config /etc/xray/split.json
#Restart=on-failure
#RestartPreventExitStatus=23
#
#[Install]
#WantedBy=multi-user.target
#END

#systemctl enable splithttp
#systemctl enable httpupgrade
#systemctl start splithttp
#systemctl start httpupgrade
#systemctl restart splithttp
#systemctl restart httpupgrade

wget -O /usr/bin/badvpn https://raw.githubusercontent.com/powermx/badvpn/master/badvpn-udpgw
chmod +x /usr/bin/badvpn
cat> /etc/systemd/system/badvpn.service << END
[Unit]
Description=BadVPN Gaming Support Port 7300 By FN Project
Documentation=https://t.me/fn_project
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/bin/badvpn --listen-addr 127.0.0.1:7300 --max-clients 500
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
END

# Seting Up Konfigurasi Badvpn Lainya
#cd /etc
#nohup badvpn --listen-addr 127.0.0.1:7100 --max-clients 500 & >/dev/null
#nohup badvpn --listen-addr 127.0.0.1:7200 --max-clients 500 & >/dev/null
#cd

wget "https://docs.google.com/uc?export=download&id=1IbwfNpKpa1JzvXsDT-WgNpp5nWrklisG" -O /usr/bin/ws-com
chmod +x /usr/bin/ws-com
wget -O /usr/bin/config.yaml "https://raw.githubusercontent.com/DindaPutriFN/FN-API/main/core/config.yaml"
chmod +x /usr/bin/config.yaml
cat> /etc/systemd/system/proxy.service << END
[Unit]
Description=Proxy Socet All OS By Rerechan02
Documentation=https://github.com/Rerechan-Team
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/bin/ws-com -f /usr/bin/config.yaml
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
END

wget -q -O /usr/bin/ws "https://raw.githubusercontent.com/DindaPutriFN/WebSocket-Proxy/main/ws.py"
cat> /etc/systemd/system/edu.service << END
[Unit]
Description=Proxy Socet All OS By Rerechan02
Documentation=https://github.com/Rerechan02
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/bin/python3 /usr/bin/ws
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
END

wget -O /usr/bin/loop "https://raw.githubusercontent.com/DindaPutriFN/FN-API/main/core/quota.sh"
chmod +x /usr/bin/loop
cat> /etc/systemd/system/quota.service << END
[Unit]
Description=Xray Quota Management Service By FN Project
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/loop
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
END

wget -O /usr/bin/server "https://raw.githubusercontent.com/DindaPutriFN/FN-API/main/core/server"
cat> /etc/systemd/system/server.service << END
[Unit]
Description=WebAPI Server Proxy All OS By Rerechan02
Documentation=https://github.com/Rerechan-Team
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/bin/python3 /usr/bin/server
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
END

cd
clear

# Install HTTP Proxy
wget -O /usr/bin/http "https://raw.githubusercontent.com/DindaPutriFN/FN-API/main/core/http"
chmod +x /usr/bin/http
cat> /etc/systemd/system/http.service << END
[Unit]
Description=WebAPI Server Proxy All OS By Rerechan02
Documentation=https://github.com/Rerechan-Team
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/bin/http
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
END

# Install OHP Server
wget -O /root/ohp.sh "https://raw.githubusercontent.com/DindaPutriFN/Autoscript/main/ohp.sh"
chmod +x /root/ohp.sh
cd /root
./ohp.sh
rm -fr /root/*

# Install Trojan Go
latest_version="$(curl -s "https://api.github.com/repos/p4gefau1t/trojan-go/releases" | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
trojango_link="https://github.com/p4gefau1t/trojan-go/releases/download/v${latest_version}/trojan-go-linux-amd64.zip"
mkdir -p "/usr/bin/trojan-go"
mkdir -p "/etc/trojan-go"
cd `mktemp -d`
curl -sL "${trojango_link}" -o trojan-go.zip
unzip -q trojan-go.zip && rm -rf trojan-go.zip
mv trojan-go /usr/local/bin/trojan-go
chmod +x /usr/local/bin/trojan-go
mkdir /var/log/trojan-go/
touch /etc/trojan-go/akun.conf
touch /var/log/trojan-go/trojan-go.log

# Buat Config Trojan Go
mkdir -p /etc/trojan-go/
cat > /etc/trojan-go/config.json << END
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 2087,
  "remote_addr": "127.0.0.1",
  "remote_port": 89,
  "log_level": 1,
  "log_file": "/var/log/trojan-go/trojan-go.log",
  "password": [
      "Rere02"
  ],
  "disable_http_check": true,
  "udp_timeout": 60,
  "ssl": {
    "verify": false,
    "verify_hostname": false,
    "cert": "/etc/xray/xray.crt",
    "key": "/etc/xray/xray.key",
    "key_password": "",
    "cipher": "",
    "curves": "",
    "prefer_server_cipher": false,
    "sni": "$domain",
    "alpn": [
      "http/1.1"
    ],
    "session_ticket": true,
    "reuse_session": true,
    "plain_http_response": "",
    "fallback_addr": "127.0.0.1",
    "fallback_port": 0,
    "fingerprint": "firefox"
  },
  "tcp": {
    "no_delay": true,
    "keep_alive": true,
    "prefer_ipv4": true
  },
  "mux": {
    "enabled": false,
    "concurrency": 8,
    "idle_timeout": 60
  },
  "websocket": {
    "enabled": true,
    "path": "/trojango",
    "host": "$domain"
  },
    "api": {
    "enabled": false,
    "api_addr": "",
    "api_port": 0,
    "ssl": {
      "enabled": false,
      "key": "",
      "cert": "",
      "verify_client": false,
      "client_cert": []
    }
  }
}
END

# Installing Trojan Go Service
cat > /etc/systemd/system/trojan-go.service << END
[Unit]
Description=Trojan-Go Service Mod By Rere02
Documentation=github.com/adammoi/vipies
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/trojan-go -config /etc/trojan-go/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
END

# Trojan Go Uuid
cat > /etc/trojan-go/uuid.txt << END
Rere02
END
# Trojan Go Acount
cat > /etc/trojan-go/akun.conf << END
### 

END
systemctl daemon-reload
systemctl enable trojan-go
systemctl start trojan-go

clear

#Enable
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

#Firewall UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 80/tcp
sudo ufw allow 8880/tcp
sudo ufw allow 443/tcp
sudo ufw allow 1194/tcp
sudo ufw allow 447/tcp
sudo ufw allow 444/tcp
sudo ufw allow 777/tcp
sudo ufw allow 2080/tcp
sudo ufw allow 2082/tcp
sudo ufw allow 2200/udp
sudo ufw allow 5300/udp
sudo ufw allow 8000/tcp
sudo ufw allow 9443/tcp
sudo ufw allow 8443/tcp
sudo ufw allow 1080/tcp
yes | sudo ufw enable

# Firewall Iptables
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8880 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 1194 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 447 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 444 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 777 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 2080 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 2082 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 2200 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 5300 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 9443 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8443 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 1080 -j ACCEPT

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

#finishing
apt autoremove -y
apt clean
cd
rm /root/*.sh
rm -fr /root/*.py
nsdomain=$(cat /etc/slowdns/nsdomain)
systemctl restart nginx
systemctl restart ufw
OUTPUT="
DETAIL INSTALL SCRIPT 1.13
=========================
IP: $(curl ifconfig.me)
Domain: $domain
Namserver: $nsdomain
WebAPI: $api773
=========================
@fn_project Autoscript
"
CHATID="6389176425"
KEY="6981433170:AAFhh3UQi2H_lsJiAjGEMoj4xad2TdNHQfI"
TIME="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
curl -s --max-time $TIME --data-urlencode "chat_id=$CHATID" --data-urlencode "text=$OUTPUT" $URL >/dev/null 2>&1
clear
echo ""
echo -e "\033[96m_______________________________\033[0m"
echo -e "\033[92m         INSTALL SUCCES\033[0m"
echo -e "\033[96m_______________________________\033[0m"
sleep 1.5