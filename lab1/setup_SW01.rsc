/system identity set name=SW01
/user set admin password=12345 group=full

/interface bridge
add name=bridge1 vlan-filtering=yes

/interface bridge port
add bridge=bridge1 interface=ether2
add bridge=bridge1 interface=ether3
add bridge=bridge1 interface=ether4


/interface bridge vlan
add bridge=bridge1 tagged=ether2,ether3 vlan-ids=10
add bridge=bridge1 tagged=ether2,ether4 vlan-ids=20