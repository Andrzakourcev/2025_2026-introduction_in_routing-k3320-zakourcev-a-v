#!/bin/sh
set -e
ip link add link eth1 name VLAN10 type vlan id 10

ip link set VLAN10 up

dhclient -v VLAN10 || exit 0
