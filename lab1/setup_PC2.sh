#!/bin/bash
set -e 

apt-get update
apt-get install -y isc-dhcp-client iproute2 iputils-ping net-tools

dhclient -v eth1

ip addr show eth1

