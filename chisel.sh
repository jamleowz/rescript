#!/bin/bash

# Memastikan skrip dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# --- CONFIGURATION VARIABLES ---
# You can change these values to suit your needs
CHISEL_VERSION="1.9.1" # Check https://github.com/jpillora/chisel/releases for latest
SSL_PORT="9443"
HTTP_PORT="8000"
TLS_CERT="/etc/xray/xray.key" # Will generate if not exists
TLS_KEY="/etc/xray/xray.crt"  # Will generate if not exists

# --- OFFICIAL DOWNLOAD URL ---
# Constructing the official download URL for the latest version
ARCH=$(uname -m)
case $ARCH in
  "x86_64")
    ARCH="amd64"
    ;;
  "aarch64"|"arm64")
    ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# Official GitHub release URL
URL="https://github.com/jpillora/chisel/releases/download/v${CHISEL_VERSION}/chisel_${CHISEL_VERSION}_linux_${ARCH}.gz"

echo "Downloading Chisel v${CHISEL_VERSION} from official GitHub release..."
echo "URL: $URL"

# Download and extract Chisel
wget -q -O /tmp/chisel.gz "${URL}"
gunzip -f /tmp/chisel.gz
mv /tmp/chisel /usr/bin/chisel
chmod +x /usr/bin/chisel
rm -
echo "Chisel installed successfully to /usr/bin/chisel."
# Membuat file service systemd untuk Chisel di port 9443 (HTTPS)
echo "Creating systemd service for Chisel SSL (port 9443)..."
cat <<EOF > /etc/systemd/system/chisell-ssl.service
[Unit]
Description=Chisel Server SSL By FN Project
After=network.target

[Service]
ExecStart=/usr/bin/chisell server --port 9443 --tls-key /etc/xray/xray.key --tls-cert /etc/xray/xray.crt --socks5
Restart=always
User=nobody
Group=nogroup

[Install]
WantedBy=multi-user.target
EOF

# Membuat file service systemd untuk Chisel di port 8000 (HTTP)
echo "Creating systemd service for Chisel HTTP (port 8000)..."
cat <<EOF > /etc/systemd/system/chisell-http.service
[Unit]
Description=Chisel Server HTTP By FN Project
After=network.target

[Service]
ExecStart=/usr/bin/chisell server --port 8000 --socks5
Restart=always
User=nobody
Group=nogroup

[Install]
WantedBy=multi-user.target
EOF

# Memuat ulang daemon systemd
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Mengaktifkan dan memulai service Chisel SSL (port 9443)
echo "Enabling and starting Chisel SSL service..."
systemctl enable chisell-ssl.service
systemctl start chisell-ssl.service

# Mengaktifkan dan memulai service Chisel HTTP (port 8000)
echo "Enabling and starting Chisel HTTP service..."
systemctl enable chisell-http.service
systemctl start chisell-http.service

#Merestart layanan
sudo iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 9443 -j ACCEPT
sudo ufw allow 8000/tcp
sudo ufw allow 9443/tcp
systemctl restart chisell-http.service
systemctl restart chisell-ssl.service

# Membersihkan layar
rm -fr chisel.sh
clear
