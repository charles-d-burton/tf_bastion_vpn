#!/bin/bash
wget https://raw.githubusercontent.com/charles-d-burton/openvpn-install/master/openvpn-install.sh -O openvpn-install.sh \
&& NETWORK_ROUTE="${network_block}" GATEWAY=${gateway} CIDR=${cidr} NETMASK=${netmask} bash openvpn-install.sh > /root/vpnsetup.log

