/system identity set name=SW03
/user set admin password=12345

/interface bridge
add name=bridge1

/interface vlan 
add name=VLAN10 vlan-id=10 interface=bridge1
add name=VLAN20 vlan-id=20 interface=bridge1

/interface bridge port
add bridge=bridge1 interface=ether1
add bridge=bridge1 interface=ether2 

/interface bridge vlan
add bridge=bridge1 tagged=bridge1,ether1 untagged=ether2 vlan-ids=20

/interface bridge port
set [find interface=ether2] pvid=20
