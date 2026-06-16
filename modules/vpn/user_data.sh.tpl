#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing OpenVPN and Easy-RSA"
apt-get update
apt-get install -y openvpn easy-rsa iptables

# ── PKI setup ─────────────────────────────────────────────────────────────────
mkdir -p /etc/openvpn/easy-rsa
cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/
cd /etc/openvpn/easy-rsa

cat > vars <<EOF
set_var EASYRSA_ALGO     ec
set_var EASYRSA_CURVE    prime256v1
set_var EASYRSA_CA_EXPIRE  3650
set_var EASYRSA_CERT_EXPIRE 3650
EOF

./easyrsa init-pki
echo "K8s VPN CA" | ./easyrsa build-ca nopass
./easyrsa gen-req server nopass <<< "server"
echo "yes" | ./easyrsa sign-req server server
./easyrsa gen-dh
openvpn --genkey secret /etc/openvpn/ta.key

# ── Copy certs to openvpn directory ───────────────────────────────────────────
cp pki/ca.crt               /etc/openvpn/
cp pki/issued/server.crt    /etc/openvpn/
cp pki/private/server.key   /etc/openvpn/
cp pki/dh.pem               /etc/openvpn/

# ── Server config ─────────────────────────────────────────────────────────────
cat > /etc/openvpn/server.conf <<EOF
port 1194
proto udp
dev tun

ca   /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key  /etc/openvpn/server.key
dh   /etc/openvpn/dh.pem

tls-auth /etc/openvpn/ta.key 0
cipher AES-256-GCM
auth SHA256

server ${vpn_client_cidr}
push "route ${vpc_cidr}"

keepalive 10 120
persist-key
persist-tun

status      /var/log/openvpn-status.log
log-append  /var/log/openvpn.log
verb 3
EOF

# ── Enable IP forwarding ───────────────────────────────────────────────────────
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# ── NAT — forward VPN client traffic into VPC ─────────────────────────────────
iptables -t nat -A POSTROUTING -s ${vpn_client_cidr} -o eth0 -j MASQUERADE
apt-get install -y iptables-persistent
netfilter-persistent save

# ── Start OpenVPN ──────────────────────────────────────────────────────────────
systemctl enable openvpn@server
systemctl start  openvpn@server

echo "==> OpenVPN server ready"