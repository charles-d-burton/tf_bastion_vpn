#!/bin/bash

INTERNAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)

sudo apt-get install strongswan strongswan-plugin-eap-mschapv2 moreutils iptables-persistent
mkdir vpn-certs
cd vpn-certs
ipsec pki --gen --type rsa --size 4096 --outform pem > server-root-key.pem

chmod 600 server-root-key.pem

ipsec pki --self --ca --lifetime 3650 --in server-root-key.pem --type rsa --dn "C=US, O=VPN Server, CN=VPN Server Root CA" --outform pem > server-root-ca.pem

ipsec pki --gen --type rsa --size 4096 --outform pem > vpn-server-key.pem

ipsec pki --pub --in vpn-server-key.pem --type rsa | ipsec pki --issue --lifetime 1825 --cacert server-root-ca.pem --cakey server-root-key.pem --dn "C=US, O=VPN Server, CN=$${INTERNAL_IP}" --san $${INTERNAL_IP} --flag serverAuth --flag ikeIntermediate -outform pem > vpn-server-cert.pem

sudo cp ./vpn-server-cert.pem /etc/ipsec.d/certs/vpn-server-cert.pem
sudo cp ./vpn-server-key.pem /etc/ipsec.d/private/vpn-server-key.pem
sudo chown root /etc/ipsec.d/private/vpn-server-key.pem
sudo chgrp root /etc/ipsec.d/private/vpn-server-key.pem
sudo chmod 600 /etc/ipsec.d/private/vpn-server-key.pem
sudo cp /etc/ipsec.conf /etc/ipsec.conf.original
echo '' | sudo tee /etc/ipsec.conf
cat << EOF > /etc/ipsec.conf
config setup
  charondebug="ike 1, knl 1, cfg 0"
  uniqueids=no
conn ikev2-vpn
  auto=add
  compress=no
  type=tunnel
  keyexchange=ikev2
  fragmentation=yes
  forceencaps=yes
  ike=aes256-sha1-modp1024,3des-sha1-modp1024!
  esp=aes256-sha1,3des-sha1!
  dpdaction=clear
  dpddelay=300s
  rekey=no
  left=%any
  leftid=$${INTERNAL_IP}
  leftcert=/etc/ipsec.d/certs/vpn-server-cert.pem
  leftsendcert=always
  leftsubnet=0.0.0.0/0
  right=%any
  rightid=%any
  rightauth=eap-mschapv2
  rightsourceip=${network_block}
  rightdns=8.8.8.8,8.8.4.4,169.254.169.253
  rightsendcert=never
  eap_identity=%identity
EOF

cat << EOF > /etc/ipsec.secrets
$${INTERNAL_IP} : RSA "/etc/ipsec.d/private/vpn-server-key.pem"
${username} %any%: EAP ${password}
EOF
sudo ipsec reload
sudo ufw disable

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F
iptables -Z
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -p udp --dport  500 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 4500 -j ACCEPT
sudo iptables -A FORWARD --match policy --pol ipsec --dir in  --proto esp -s ${network_block} -j ACCEPT
sudo iptables -A FORWARD --match policy --pol ipsec --dir out --proto esp -d ${network_block} -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s ${network_block} -o eth0 -m policy --pol ipsec --dir out -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s ${network_block} -o eth0 -j MASQUERADE
sudo iptables -t mangle -A FORWARD --match policy --pol ipsec --dir in -s ${network_block} -o eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360
sudo iptables -A INPUT -j DROP
sudo iptables -A FORWARD -j DROP
sudo netfilter-persistent save
sudo netfilter-persistent reload

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.ip_no_pmtu_disc = 1" >> /etc/sysctl.conf

sudo reboot


