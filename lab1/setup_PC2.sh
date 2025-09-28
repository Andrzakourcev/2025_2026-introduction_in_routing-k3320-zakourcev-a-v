#!/bin/sh
set -e
ip link add link eth1 name VLAN10 type vlan id 20

ip link set VLAN20 up

dhclient -v VLAN20 || exit 0
