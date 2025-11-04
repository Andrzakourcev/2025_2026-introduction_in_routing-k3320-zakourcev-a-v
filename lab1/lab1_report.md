# Отчет по лабораторной работе №1 - "Установка ContainerLab и развертывание тестовой сети связи".

## Информация

University: [ITMO University](https://itmo.ru/ru/)
Faculty: [FPIN](https://fpin.itmo.ru/)
Course: [Introduction in routing](https://github.com/itmo-ict-faculty/introduction-in-routing)
Year: 2025/2026
Group: K3320
Author: Filianin Ivan Victorovich
Lab: Lab1
Date of create: 02.09.2025
Date of finished: 04.11.2025

## Описание

В данной лабораторной работе вы познакомитесь с инструментом ContainerLab, развернете тестовую сеть связи, настроите оборудование на базе Linux и RouterOS.

## Цель работы

Ознакомиться с ContainerLab и методами работы с ним, изучить работу VLAN, IP адресации и т.д.

## Задание

Вам необходимо сделать трехуровневую сеть связи классического предприятия изображенную на рисунке 1 в ContainerLab. Необходимо создать все устройства указанные на схеме и соединения между ними, правила работы с СontainerLab можно изучить по [ссылке](https://containerlab.dev/quickstart/).

<img width="411" height="291" alt="image" src="https://github.com/user-attachments/assets/154540a7-11e4-4d80-aaa8-c7da83da9cf7" />

> Подсказка №1 Не забудьте создать mgmt сеть, чтобы можно было зайти на CHR.  
> Подсказка №2 Для mgmt_ipv4 не выбирайте первый и последний адрес в выделенной сети, ходить на CHR можно используя SSH и Telnet (admin/admin).

* Помимо этого вам необходимо настроить IP адреса на интерфейсах и 2 VLAN-a для PC1 и PC2, номера VLAN-ов вы вольны выбрать самостоятельно.
* Также вам необходимо создать 2 DHCP сервера на центральном роутере в ранее созданных VLAN-ах для раздачи IP адресов в них. PC1 и PC2 должны получить по 1 IP адресу из своих подсетей.
* Настроить имена устройств, сменить логины и пароли.

## Выполнение работы

Файл network.clab.yaml описывает сетевую топологию, состоящую из маршрутизатора R1, трёх коммутаторов (SW1, SW2, SW3) и двух конечных устройств — PC1 и PC2. Для каждого узла предусмотрен собственный конфигурационный файл, расположенный в папке configs, который автоматически загружается при запуске соответствующего контейнера.

```
name: lab1

mgmt:
  network: my_mgmt
  ipv4-subnet: 172.16.16.0/24

topology:
  kinds:
    vr-ros:
      image: vrnetlab/mikrotik_routeros:6.47.9
  
  nodes:
    R01:
      kind: vr-ros
      mgmt-ipv4: 172.16.16.150
      startup-config: config/setup_R01.rsc
    SW01:
      kind: vr-ros
      mgmt-ipv4: 172.16.16.151
      startup-config: config/setup_SW01.rsc
    SW02:
      kind: vr-ros
      mgmt-ipv4: 172.16.16.152
      startup-config: config/setup_SW02.rsc
    SW03:
      kind: vr-ros
      mgmt-ipv4: 172.16.16.153
      startup-config: config/setup_SW03.rsc
    PC1:
      kind: linux
      image: alpine:latest
      mgmt-ipv4: 172.16.16.2
      binds:
        - ./config:/config
      exec:
        - sh /config/setup_PC1.sh
    PC2:
      kind: linux
      image: alpine:latest
      mgmt-ipv4: 172.16.16.3
      binds:
        - ./config:/config
      exec:
        - sh /config/setup_PC2.sh
  links:
    - endpoints: ["R01:eth1", "SW01:eth1"]
    - endpoints: ["SW01:eth2", "SW02:eth1"]
    - endpoints: ["SW01:eth3", "SW03:eth1"]
    - endpoints: ["SW02:eth2", "PC1:eth1"]
    - endpoints: ["SW03:eth2", "PC2:eth1"]
```

Ниже представлено графическое отображение данной топологии. Отображено с помощью команды clab graph -t <имя_лаборатории>

<img width="606" height="698" alt="image" src="https://github.com/user-attachments/assets/6a29f1e6-d876-4717-b018-0a5258ed2584" />


### Настройка маршрутизатора R1

На маршрутизаторе R1 созданы два VLAN — VLAN 10 и VLAN 20. Они используются для разделения трафика между двумя сетевыми сегментами, к которым подключены PC1 и PC2. Для каждого VLAN настроен собственный DHCP-сервер, автоматически назначающий IP-адреса устройствам внутри соответствующих сегментов. Также был добавлен новый пользователь с правами администратора и изменено имя хоста устройства.

Конфигурация маршрутизатора R1 выглядит следующим образом:
```
/interface vlan
add name=vlan10 vlan-id=10 interface=ether2
add name=vlan20 vlan-id=20 interface=ether2

/ip address
add address=10.10.0.1/24 interface=vlan10
add address=10.20.0.1/24 interface=vlan20

/ip pool
add name=dhcp-pool10 ranges=10.10.0.10-10.10.0.254
add name=dhcp-pool20 ranges=10.20.0.10-10.20.0.254

/ip dhcp-server
add address-pool=dhcp-pool10 disabled=no interface=vlan10 name=dhcp-server10
add address-pool=dhcp-pool20 disabled=no interface=vlan20 name=dhcp-server20

/ip dhcp-server network
add address=10.10.0.0/24 gateway=10.10.0.1
add address=10.20.0.0/24 gateway=10.20.0.1

/user
add name=andrey password=andrey group=full
remove admin

/system identity
set name=R01
```

### Настройка коммутатора SW1

На коммутаторе SW1 созданы VLAN-интерфейсы, назначенные различным портам, а также настроен мост, объединяющий VLAN 10 и VLAN 20. Это обеспечивает корректную передачу трафика между интерфейсами, принадлежащими соответствующим VLAN.

Конфигурация коммутатора SW1 выглядит следующим образом:

```
/interface bridge
add name=bridge1 vlan-filtering=yes

/interface vlan
add name=vlan10 vlan-id=10 interface=bridge1
add name=vlan20 vlan-id=20 interface=bridge1

/interface bridge port
add bridge=bridge1 interface=ether2
add bridge=bridge1 interface=ether3
add bridge=bridge1 interface=ether4

/interface bridge vlan
add bridge=bridge1 tagged=bridge1,ether2,ether3 vlan-ids=10
add bridge=bridge1 tagged=bridge1,ether2,ether4 vlan-ids=20

/ip address
add address=10.10.0.2/24 interface=vlan10
add address=10.20.0.2/24 interface=vlan20

/user
add name=andrey password=andrey group=full
remove admin

/system identity
set name=SW01
```

### Настройка коммутаторов SW2 и SW3

Конфигурация данных коммутаторов выполнена по аналогии с SW1 — для каждого устройства созданы VLAN-интерфейсы и настроен мост, объединяющий соответствующие порты.

Пример конфигурации для коммутатора SW2:

```
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
```

### Настройка конечных устройств PC1 и PC2

На конечных устройствах PC1 и PC2 создаются VLAN-интерфейсы с помощью команды ip link. Затем при помощи утилиты udhcpc -i на этих интерфейсах запрашивается IP-адрес у DHCP-сервера. После получения адреса добавляется статический маршрут командой ip route add 10.x0.0.0/24 via 10.x0.0.1 dev vlanx0, чтобы обеспечить взаимную доступность компьютеров в сети.

Пример конфигурации для PC1:
```
#!/bin/sh
ip link add link eth1 name vlan10 type vlan id 10
ip link set vlan10 up
udhcpc -i vlan10
ip route add 10.20.0.0/24 via 10.10.0.1 dev vlan10
```
Пример конфигурации для PC2:
```
#!/bin/sh
ip link add link eth1 name vlan20 type vlan id 20
ip link set vlan20 up
udhcpc -i vlan20
ip route add 10.10.0.0/24 via 10.20.0.1 dev vlan20```
```

### Проверка работоспособности сети

Для развертывания лабораторной сети используется команда:
`clab deploy -t <имя_лаборатории>`
<img width="857" height="754" alt="image" src="https://github.com/user-attachments/assets/1424f542-9794-417d-94e2-6f3c086a1b46" />

После успешного запуска можно подключаться к контейнеру в сети с помощью команды:
`docker exec -it <имя_контейнера> sh`

К маршрутизатору и коммутаторам доступ по **SSH** — именно для этого в топологии была настроена management сеть.

Далее подключимся к **PC1**, а затем к **PC2**, чтобы убедиться в корректной работе сети.

<img width="992" height="713" alt="image" src="https://github.com/user-attachments/assets/d5196487-1567-46a6-869e-4f1cbeed93dc" />

Как видно, **PC1** успешно видит **PC2** — соединение работает корректно.

<img width="970" height="717" alt="image" src="https://github.com/user-attachments/assets/9b540236-f15a-4820-aec0-634d7ea36e91" />

В обратную сторону все также ок.

### Заключение

В ходе выполнения лабораторной работы №1 были изучены основы работы с инструментом ContainerLab. Я научился описывать сетевую топологию в YAML-файле и развертывать виртуальные сетевые устройства на базе RouterOS и Linux. В процессе работы была реализована трёхуровневая архитектура сети, настроены VLAN, DHCP-серверы и IP-адресация, а также проведена проверка связности между конечными устройствами, подтвердившая корректность настройки сети.
