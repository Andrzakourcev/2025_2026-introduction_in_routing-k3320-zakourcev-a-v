#Make vlans
/interface vlan
add interface=ether1 name=VLAN10 vlan-id=10
add interface=ether1 name=VLAN20 vlan-id=20

#ip gateway
/ip address 
add address=10.0.10.1/24 interface=VLAN10
add address=10.0.20.1/24 interface=VLAN20

#pool ip address
/ip pool
add name=pool_vlan10 ranges=10.0.10.100-10.0.10.200 disable=no
add name=pool_vlan20 ranges=10.0.20.100-10.0.20.200 disable=no

#DHCP
/ip dhcp-server
add name=dhcp_vlan10 interface=VLAN10 address-pool=pool_vlan10
add name=dhcp_vlan20 interface=VLAN20 address-pool=pool_vlan20
enable dhcp_vlan10
enable dhcp_vlan20

/ip dhcp-server network
add address=10.0.10.0/24 gateway=10.0.10.1
add address=10.0.20.0/24 gateway=10.0.20.1

/user add name=andrey password=andrey group=full
/system identity set name=R1




