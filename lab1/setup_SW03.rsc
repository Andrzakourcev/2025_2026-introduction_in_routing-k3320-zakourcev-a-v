/system identity set name=SW03
/user set admin password=12345

/interface bridge
add name=bridge1 vlan-filtering=yes

/interface bridge port
add bridge=bridge1 interface=ether2
add bridge=bridge1 interface=ether3

/interface bridge vlan
add bridge=bridge1 tagged=ether2 untagged=ether3 vlan-ids=20