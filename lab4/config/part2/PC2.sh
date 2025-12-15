#!/bin/sh
ip route del default via 172.21.21.1 dev eth0
udhcpc -i eth1