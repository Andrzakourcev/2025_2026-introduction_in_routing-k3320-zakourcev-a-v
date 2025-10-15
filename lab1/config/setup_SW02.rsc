/interface bridge
add name=bridge1
/interface vlan
add name=vlan10 vlan-id=10 interface=bridge1
/interface bridge port
add bridge=bridge1 interface=ether2
add bridge=bridge1 interface=ether3 pvid=10
/interface bridge vlan
add bridge=bridge1 tagged=bridge1,ether2 untagged=ether3 vlan-ids=10
/ip address
add address=10.10.0.3/24 interface=vlan10
/user
add name=andrey password=andrey group=full
remove admin
/system identity
set name=SW02