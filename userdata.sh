#!/bin/bash

wget https://git.io/vpnsetup -O vpnsetup.sh && sudo \
VPN_IPSEC_PSK='${psk}' \
VPN_USER='${username}' \
VPN_PASSWORD='${password}' sh vpnsetup.sh > /root/vpnsetup.log

