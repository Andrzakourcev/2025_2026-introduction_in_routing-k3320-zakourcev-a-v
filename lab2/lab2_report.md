# Отчет по лабораторной работе №2 - "Эмуляция распределенной корпоративной сети связи, настройка статической маршрутизации между филиалами".

## Информация

University: [ITMO University](https://itmo.ru/ru/)
Faculty: [FPIN](https://fpin.itmo.ru/)
Course: [Introduction in routing](https://github.com/itmo-ict-faculty/introduction-in-routing)
Year: 2025/2026
Group: K3320
Author: Zakourcev Andrey Vadimovich
Lab: Lab2
Date of create: 09.11.2025
Date of finished: 09.11.2025

## Описание

В данной лабораторной работе вы первый раз познакомитесь с компанией "RogaIKopita Games" LLC которая занимается разработкой мобильных игр с офисами в Москве, Франкфурте и Берлине. Для обеспечения работы своих офисов "RogaIKopita Games" вам как сетевому инженеру необходимо установить 3 роутера, назначить на них IP адресацию и поднять статическую маршрутизацию. В результате работы сотрудник из Москвы должен иметь возможность обмениваться данными с сотрудником из Франкфурта или Берлина и наоборот.

## Цель работы

Ознакомиться с принципами планирования IP адресов, настройке статической маршрутизации и сетевыми функциями устройств.

## Задание

Основная часть лабораторной работы:

Вам необходимо сделать сеть связи в трех геораспределенных офисах "RogaIKopita Games" изображенную на рисунке 1 в ContainerLab. Необходимо создать все устройства указанные на схеме и соединения между ними.

<img width="541" height="361" alt="image" src="https://github.com/user-attachments/assets/f3da6535-54a5-4ca3-8786-3e18bc56fcdf" />

Помимо этого вам необходимо настроить IP адреса на интерфейсах.
Создать DHCP сервера на роутерах в сторону клиентских устройств.
Настроить статическую маршрутизацию.
Настроить имена устройств, сменить логины и пароли.

# Ход работы 

## Схема 

Ниже представлено графическое отображение данной топологии. Отображено с помощью команды clab graph -t <имя_лаборатории>

<img width="867" height="688" alt="image" src="https://github.com/user-attachments/assets/5c1adbcd-d6ac-4869-94d3-87005adbdcfa" />

Схема из draw.io:

<img width="945" height="761" alt="image" src="https://github.com/user-attachments/assets/c7536690-7d0c-4684-821b-26cbb7593905" />

## Yaml`ик

Во многом схож с первой лабой, единственное добавился один комп, соединение в кольцо и ко всем пк подключаемся по eth3

## Конфиги маршрутизаторов

На примере BRL:

```
/user
add name=andrey password=andrey group=full
remove admin

/system identity
set name=R.BRL

/ip address
add address=192.168.12.2/30 interface=ether3
add address=192.168.13.1/30 interface=ether2
add address=10.3.0.1/16 interface=ether4

/ip pool
add name=dhcp-pool ranges=10.3.0.10-10.3.255.254

/ip dhcp-server
add address-pool=dhcp-pool disabled=no interface=ether4 name=dhcp-server

/ip dhcp-server network
add address=10.3.0.0/16 gateway=10.3.0.1

/ip route
add distance=1 dst-address=10.1.0.0/16 gateway=192.168.13.2
add distance=1 dst-address=10.2.0.0/16 gateway=192.168.12.1
```

Этот конфиг настраивает роутер с именем R.BRL, назначает IP-адреса интерфейсам (`ether3` — 192.168.12.2/30, ether2 — 192.168.13.1/30, ether4 — 10.3.0.1/16 для компьютеров), создаёт DHCP-пул 10.3.0.10–10.3.255.254 и включает DHCP-сервер на ether4 с шлюзом по умолчанию 10.3.0.1, а также настраивает статические маршруты к сетям 10.1.0.0/16 через 192.168.13.2 и 10.2.0.0/16 через 192.168.12.1.

Остальные аналогично.

## Конфиги пк

```
#!/bin/sh
ip route del default via 172.16.16.1 dev eth0
udhcpc -i eth1
```
Этот скрипт выполняет две вещи: сначала удаляет дефолтный маршрут через интерфейс eth0 (чтобы трафик не уходил через сеть управления), а затем запускает DHCP-клиент udhcpc на интерфейсе eth1, чтобы получить IP-адрес от локального DHCP-сервера.

## Проверка работоспособности

PC1:

<img width="917" height="878" alt="image" src="https://github.com/user-attachments/assets/69ceb66f-4418-4a05-8357-517502fcabab" />

PC2:

<img width="920" height="910" alt="image" src="https://github.com/user-attachments/assets/c0c0d475-6836-46aa-834d-116d8d3dbe24" />

PC3:

<img width="937" height="911" alt="image" src="https://github.com/user-attachments/assets/c6f0a372-59c3-45fc-a41d-c439fed92a53" />

А также с роутера в Берлине посмотрим таблицу маршрутизации и раздачу DHCP-сервером адреса:

<img width="1243" height="351" alt="image" src="https://github.com/user-attachments/assets/686c06ba-83ad-4e32-858e-d44c8d9037de" />

## Заключение

В процессе работы были развернуты все устройства, указанные на схеме, и настроены их интерфейсы с соответствующими IP-адресами. Для клиентских машин были организованы DHCP-серверы, а также настроена статическая маршрутизация между сетями. Таким образом, поставленная задача по созданию сети для трёх географически распределённых офисов компании «RogaIKopita Games» была успешно выполнена.

