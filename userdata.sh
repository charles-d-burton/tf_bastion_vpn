#!/bin/bash
export NETWORK_ROUTE=${network_block}
export GATEWAY=${gateway}
export CIDR=${cidr}
export NETMASK=${netmask}
wget https://raw.githubusercontent.com/charles-d-burton/openvpn-install/master/openvpn-install.sh -O /root/openvpn-install.sh
chmod a+x /root/openvpn-install.sh
/root/openvpn-install.sh > /root/vpnsetup.log

