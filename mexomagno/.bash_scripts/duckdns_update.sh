#!/bin/bash

source ~/.bash_env
source $SHARED_FS/mexomagno/.bash_env
# Duck DNS. Script for updating my ISP-provided Dynamic IP DNS name

# Get current gateway mac
# Of course you need to source our custom shared environment in order to use the next variable
wanted_mac="$DEPA_HOTSPOT_MAC"
actual_gateway_mac="$(arp -i wlp3s0 | grep '192.168.0.1 ' | awk '{print $3}')"
echo "wanted: $wanted_mac"
# Update DNS only if we are in the house :D
if [ "$wanted_mac" == "$actual_gateway_mac" ]; then
	echo url="https://www.duckdns.org/update?domains=mexomagno&token=89667eaf-ddd0-44a2-8133-cdb215347c62&ip=" | curl -k -o $HOME/.duck.log -K -
else
	echo "We are not at home! Doing nothing." > $HOME/.duck.log
fi
