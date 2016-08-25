#!/bin/bash

interface='eth0'

ipAddress=$(ifconfig $interface | grep -oP 'inet addr:\K\S+')
broadcast=$(ifconfig $interface | grep -oP 'Bcast:\K\S+')
mask=$(ifconfig $interface | grep -oP 'Mask:\K\S+')
IFS=. read -r io1 io2 io3 io4 <<< "$ipAddress"
IFS=. read -r mo1 mo2 mo3 mo4 < <(ifconfig -a | sed -n "/inet addr:$ipAddress /{ s/.*Mask://;p; }")
netAddr="$((io1 & mo1)).$(($io2 & mo2)).$((io3 & mo3)).$((io4 & mo4))"
dgw=$(/sbin/ip route | awk '/default/ { print $3 }')

echo "auto lo
iface lo inet loopback

iface $interface inet static
address $ipAddress
netmask $mask
network $netAddr
broadcast $broadcast
gateway $dgw" | sudo tee /etc/network/interfaces

