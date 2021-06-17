# **Домашнее задание №3: Знакомство с облачной инфраструктурой Yandex.Cloud**

## **Задание:**
Запуск VM в Yandex Cloud, управление правилами фаервола, настройка SSH подключения, настройка SSH подключения через Bastion Host, настройка VPN сервера и VPN-подключения.

Цель:
В данном дз студент создаст виртуальные машины в Yandex.Cloud. Настроит bastion host и ssh. В данном задании тренируются навыки: создания виртуальных машин, настройки bastion host, ssh

Все действия описаны в методическом указании.

Критерии оценки:
0 б. - задание не выполнено 1 б. - задание выполнено 2 б. - выполнены все дополнительные задания

---

## **Выполнено:**
1. Создаем инстансы VM bastion и someinternalhost через веб-морду Yandex.Cloud

2. Генерим пару ключей
```
ssh-keygen -t rsa -f ~/.ssh/appuser -C appuser -P ""
```

3. Проверяем подключение по полученному внешнему адресу
```
$ ssh -i ~/.ssh/appuser appuser@178.154.255.112
Welcome to Ubuntu 16.04.7 LTS (GNU/Linux 4.4.0-142-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

```

4. Используем Bastion host для прямого подключения к инстансам внутренней сети:
- Настроим SSH Forwarding на нашей локальной машине:
```
 ~/otus-devops/Deron-D_infra $ eval $(ssh-agent -s)
Agent pid 1739595
```

- Добавим приватный ключ в ssh агент авторизации:
```
~/otus-devops/Deron-D_infra $ ssh-add ~/.ssh/appuser
Identity added: /home/dpp/.ssh/appuser (appuser)
```

- Проверяем прямое подключение:
```
ssh -i ~/.ssh/appuser -A appuser@178.154.255.112
Welcome to Ubuntu 16.04.7 LTS (GNU/Linux 4.4.0-142-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
appuser@bastion:~$ ssh someinternalhost
The authenticity of host 'someinternalhost (10.128.0.23)' can't be established.
ECDSA key fingerprint is SHA256:yi63ao27SBUQTEWJRB5qfWKepRhRc9S2CqkRTP5ISPQ.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'someinternalhost' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 16.04.7 LTS (GNU/Linux 4.4.0-142-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

appuser@someinternalhost:~$ uname -n
someinternalhost
appuser@someinternalhost:~$ ip a show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether d0:0d:d2:c8:62:93 brd ff:ff:ff:ff:ff:ff
    inet 10.128.0.23/24 brd 10.128.0.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::d20d:d2ff:fec8:6293/64 scope link
       valid_lft forever preferred_lft forever

```

- Проверим отсутствие каких-либо приватных ключей на bastion машине:
```
appuser@bastion:~$ ls -la ~/.ssh/
total 16
drwx------ 2 appuser appuser 4096 Jun 17 14:46 .
drwxr-xr-x 4 appuser appuser 4096 Jun 17 14:36 ..
-rw------- 1 appuser appuser  561 Jun 17 14:07 authorized_keys
-rw-r--r-- 1 appuser appuser  444 Jun 17 15:32 known_hosts
```

- Самостоятельное задание. Исследовать способ подключения к someinternalhost в одну команду из вашего рабочего устройства:
Добавим в ~/.ssh/config содержимое:
```
dpp@h470m ~/otus-devops/Deron-D_infra $ cat ~/.ssh/config
Host 178.154.255.112
  User appuser
  IdentityFile /home/dpp/.ssh/appuser
Host 10.128.0.23
  User appuser
  ProxyCommand ssh -W %h:%p 178.154.255.112
  IdentityFile /home/dpp/.ssh/appuser
```
Проверяем работоспособность найденного решения:
```
~/otus-devops/Deron-D_infra $ ssh 10.128.0.23
Welcome to Ubuntu 16.04.7 LTS (GNU/Linux 4.4.0-142-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
appuser@someinternalhost:~$

```
- Дополнительное задание:

На локальной машине правим /etc/hosts
```
sudo bash -c 'echo "10.128.0.23 someinternalhost" >> /etc/hosts'
```

Добавим в ~/.ssh/config содержимое:
```
Host someinternalhost
  User appuser
  ProxyCommand ssh -W %h:%p 178.154.255.112
  IdentityFile /home/dpp/.ssh/appuser
```

Проверяем:
```
 ~/otus-devops/Deron-D_infra $ ssh someinternalhost
Welcome to Ubuntu 16.04.7 LTS (GNU/Linux 4.4.0-142-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
appuser@someinternalhost:~$

```

ssh someinternalhost

## **Полезное:**
- [SSH: подключение в приватную сеть через Bastion и немного про Multiplexing](https://rtfm.co.ua/ssh-podklyuchenie-v-privatnuyu-set-cherez-bastion-i-nemnogo-pro-multiplexing/)
