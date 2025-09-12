/system identity set name=SW02
/user set admin password=54321

/interface bridge
add name=bridge1 vlan-filtering=yes

/interface bridge port
add bridge=bridge1 interface=ether1
add bridge=bridge1 interface=ether2 

/interface bridge vlan
add bridge=bridge1 tagged=ether1 untagged=ether2 vlan-ids=10