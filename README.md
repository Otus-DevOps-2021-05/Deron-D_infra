# **Лекция №5: Знакомство с облачной инфраструктурой Yandex.Cloud**
<details>
  <summary>Сборка образов VM при помощи Packer</summary>

## **Задание:**
Запуск VM в Yandex Cloud, управление правилами фаервола, настройка SSH подключения, настройка SSH подключения через Bastion Host, настройка VPN сервера и VPN-подключения.

Цель:
В данном дз студент создаст виртуальные машины в Yandex.Cloud. Настроит bastion host и ssh. В данном задании тренируются навыки: создания виртуальных машин, настройки bastion host, ssh

Все действия описаны в методическом указании.

Критерии оценки:
0 б. - задание не выполнено 1 б. - задание выполнено 2 б. - выполнены все дополнительные задания

bastion_IP = 84.252.136.193
someinternalhost_IP = 10.129.0.18
---

## **Выполнено:**
1. Создаем инстансы VM bastion и someinternalhost через веб-морду Yandex.Cloud

2. Генерим пару ключей
```
ssh-keygen -t rsa -f ~/.ssh/appuser -C appuser -P ""
```

3. Проверяем подключение по полученному внешнему адресу
```
ssh -i ~/.ssh/appuser appuser@84.252.136.193
The authenticity of host '84.252.136.193 (84.252.136.193)' can't be established.
ECDSA key fingerprint is SHA256:mbIKmLTZYygwUXSfTBJ8E017RPU9kNESKHYfdoDWbXY.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '84.252.136.193' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-42-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

dpp@h470m ~/otus-devops/Deron-D_infra $ ssh -i ~/.ssh/appuser appuser@84.252.136.193
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-42-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Last login: Sun Jun 20 13:12:26 2021 from 82.194.224.170
appuser@bastion:~$ ssh 10.129.0.18
The authenticity of host '10.129.0.18 (10.129.0.18)' can't be established.
ECDSA key fingerprint is SHA256:WsrgIfB+b7qerWOk1tNLqeyGmKoBfKdWkdVJKVzo6u8.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.129.0.18' (ECDSA) to the list of known hosts.
appuser@10.129.0.18: Permission denied (publickey).
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
ssh -i ~/.ssh/appuser -A appuser@84.252.136.193
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-42-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Last login: Sun Jun 20 13:22:54 2021 from 82.194.224.170
appuser@bastion:~$ ssh 10.129.0.18
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-42-generic x86_64)

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

appuser@someinternalhost:~$ uname -a
Linux someinternalhost 5.4.0-42-generic #46-Ubuntu SMP Fri Jul 10 00:24:02 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux

appuser@someinternalhost:~$ ip a show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether d0:0d:e1:f3:67:f3 brd ff:ff:ff:ff:ff:ff
    inet 10.129.0.18/24 brd 10.129.0.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::d20d:e1ff:fef3:67f3/64 scope link
       valid_lft forever preferred_lft forever
```

- Проверим отсутствие каких-либо приватных ключей на bastion машине:
```
appuser@bastion:~$ ls -la ~/.ssh/
total 16
drwx------ 2 appuser appuser 4096 Jun 20 13:19 .
drwxr-xr-x 4 appuser appuser 4096 Jun 20 13:12 ..
-rw------- 1 appuser appuser  561 Jun 20 13:11 authorized_keys
-rw-r--r-- 1 appuser appuser  222 Jun 20 13:19 known_hosts
```

- Самостоятельное задание. Исследовать способ подключения к someinternalhost в одну команду из вашего рабочего устройства:

Добавим в ~/.ssh/config содержимое:
```
dpp@h470m ~/otus-devops/Deron-D_infra $ cat ~/.ssh/config
Host 84.252.136.193
  User appuser
  IdentityFile /home/dpp/.ssh/appuser
Host 10.129.0.18
  User appuser
  ProxyCommand ssh -W %h:%p 84.252.136.193
  IdentityFile /home/dpp/.ssh/appuser
```

Проверяем работоспособность найденного решения:
```
~/otus-devops/Deron-D_infra $ ssh 10.129.0.18
The authenticity of host '10.129.0.18 (<no hostip for proxy command>)' can't be established.
ECDSA key fingerprint is SHA256:WsrgIfB+b7qerWOk1tNLqeyGmKoBfKdWkdVJKVzo6u8.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.129.0.18' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-42-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Failed to connect to https://changelogs.ubuntu.com/meta-release-lts. Check your Internet connection or proxy settings

Last login: Sun Jun 20 13:24:16 2021 from 10.129.0.30

```
- Дополнительное задание:

На локальной машине правим /etc/hosts
```
sudo bash -c 'echo "10.129.0.18 someinternalhost" >> /etc/hosts'
```

Добавим в ~/.ssh/config содержимое:
```
Host someinternalhost
  User appuser
  ProxyCommand ssh -W %h:%p 84.252.136.193
  IdentityFile /home/dpp/.ssh/appuser
```

Проверяем:
```
dpp@h470m ~/otus-devops/Deron-D_infra $ ssh someinternalhost
The authenticity of host 'someinternalhost (<no hostip for proxy command>)' can't be established.
ECDSA key fingerprint is SHA256:WsrgIfB+b7qerWOk1tNLqeyGmKoBfKdWkdVJKVzo6u8.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'someinternalhost' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-42-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Failed to connect to https://changelogs.ubuntu.com/meta-release-lts. Check your Internet connection or proxy settings

Last login: Sun Jun 20 14:03:20 2021 from 10.129.0.30
```

- Создаем VPN-сервер для серверов Yandex.Cloud:

Создан скрипт установки VPN-сервера (setupvpn.sh)[./setupvpn.sh]

[Веб-интерфейс VPN-сервера Pritunl](https://84-252-136-193.sslip.io/#dashboard)


## **Полезное:**
- [SSH: подключение в приватную сеть через Bastion и немного про Multiplexing](https://rtfm.co.ua/ssh-podklyuchenie-v-privatnuyu-set-cherez-bastion-i-nemnogo-pro-multiplexing/)
</details>

# **Лекция №6: Деплой тестового приложения**
<details>
  <summary>Деплой тестового приложения</summary>

## **Задание:**
Практика управления ресурсами yandex cloud через yc.

Цель:
В данном дз произведет ручной деплой тестового приложения. Напишет bash скрипт для автоматизации задач настройки VM и деплоя приложения. В данном задании тренируются навыки: деплоя приложения на сервер, написания bash скриптов.

Ручной деплой тестового приложения. Написание bash скриптов для автоматизации задач настройки VM и деплоя приложения. Все действия описаны в методическом указании.

Критерии оценки:
0 б. - задание не выполнено 1 б. - задание выполнено 2 б. - выполнены все дополнительные задания

testapp_IP = 217.28.229.75
testapp_port = 9292
---

## **Выполнено:**

- Установлен YC CLI:
```
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```

- Создан новый инстанс reddit-app [create_instance.sh](https://github.com/Otus-DevOps-2021-05/Deron-D_infra/blob/main/config-scripts/create_instance.sh):
```
yc compute instance create \
 --name reddit-app \
 --hostname reddit-app \
 --memory=4 \
 --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
 --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
 --metadata serial-port-enable=1 \
 --ssh-key ~/.ssh/appuser.pub
```

- Установлен Ruby [install_ruby.sh](https://github.com/Otus-DevOps-2021-05/Deron-D_infra/blob/main/config-scripts/install_ruby.sh):
```
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential
```

- Проверен Ruby и Bundler:
```
$ ruby -v
ruby 2.3.1p112 (2016-04-26) [x86_64-linux-gnu]
$ bundler -v
Bundler version 1.11.2
```

- Установлен и запущен MongoDB [install_mongodb.sh](https://github.com/Otus-DevOps-2021-05/Deron-D_infra/blob/main/config-scripts/install_mongodb.sh):
```
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates

sudo apt-get update
sudo apt-get install -y mongodb-org

sudo systemctl start mongod
sudo systemctl enable mongod
```

- Выполнен деплой приложения [deploy.sh](https://github.com/Otus-DevOps-2021-05/Deron-D_infra/blob/main/config-scripts/deploy.sh):
```
sudo apt-get install -y git
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install

```

- Дополнительное задание:

Для создания инстанса с уже развернутым приложением достаточно запустить:
```
yc compute instance create \
 --name reddit-app \
 --hostname reddit-app \
 --memory=4 \
 --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
 --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
 --metadata-from-file user-data=metadata.yaml \
 --metadata serial-port-enable=1
```

Содержимое [metadata.yaml](https://github.com/Otus-DevOps-2021-05/Deron-D_infra/blob/main/config-scripts/metadata.yaml):
```
#cloud-config
users:
  - default
  - name: yc-user
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUSGRF2QvKndsn1hbFv93CgS3/AiwCoETwjHL6Wzkyape+sW5EXKT/MXjCTlBVfqPtKWvY2pqXpEY7oJAOmJJrBvwnuod2SzEEoFncK1YOLXJOhzeXkT1+1cgo27jJYb4TQTWjawCYv48kJnPNwSL/jNLGQSdosfH3POQVWkB3xCjoLZ7/kMqZQbFEvol5BI5T0HM7uKtPJdWUPD0X1Jpu5MgFV6ZmSWWVrGY25nTehs0nTy4AkAv5mp8VJQtzpKu+fennhQdeb+8aGEaZkFNUOGFAf9ph0G4Lq/gks491Un7cL1/HvcRgPvDdqS+ZRKaPopqK/f978VkpzovlZNJWERZyTrzbgkme6x88zv+rWUu3DiWhldGNuBdghA2kOGhSpSX80gLlj8yE3IP8pdveOq10OztLVpy+8j7tSegOdU9QnBNZ/wqgSVa9kWCU/fui4ASDAA4IAWtthUkaqmDdSPM8mPv8KYueR75LOPKMCCclAOz8S8LK1kFRwcJVEs8= appuser"

runcmd:
  - wget https://raw.githubusercontent.com/Otus-DevOps-2021-05/Deron-D_infra/cloud-testapp/bootstrap.sh
  - bash bootstrap.sh

```

Содержимое [bootstrap.sh](https://github.com/Otus-DevOps-2021-05/Deron-D_infra/blob/main/config-scripts/bootstrap.sh):
```
#!/bin/bash
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates ruby-full ruby-bundler build-essential mongodb-org git
sudo systemctl --now enable mongod
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d

```

## **Полезное:**
</details>

# **Лекция №7: Сборка образов VM при помощи Packer**
<details>
  <summary>Сборка образов VM при помощи Packer</summary>

## **Задание:**
Подготовка базового образа VM при помощи Packer.

Цель:
В данном дз студент произведет сборку готового образа с уже установленным приложением при помощи Packer. Задеплоит приложение в Compute Engine при помощи ранее подготовленного образа. В данном задании тренируются навыки: работы с Packer, работы с GCP Compute Engine.

Все действия описаны в методическом указании.

Критерии оценки:
0 б. - задание не выполнено 1 б. - задание выполнено 2 б. - выполнены все дополнительные задания

---

## **Выполнено:**

1. Установлен Packer:
```
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install packer
```

2.1 Создан сервисный аккаунт:
```
SVC_ACCT="svcuser"
FOLDER_ID="b1gu87e4thvariradsue"
yc iam service-account create --name $SVC_ACCT --folder-id $FOLDER_ID
```

2.2 Делегированы правы сервисному аккаунту для Packer:
```
$ ACCT_ID=$(yc iam service-account get $SVC_ACCT | \
grep ^id | \
awk '{print $2}')
$ yc resource-manager folder add-access-binding --id $FOLDER_ID \
--role editor \
--service-account-id $ACCT_ID
```

2.3 Создан service account key file
```
Deron-D_infra git:(packer-base) ✗  yc iam key create --service-account-id $ACCT_ID --output ~/.yc_keys/key.json
id: aje6jvgee8cm640mh2b0
service_account_id: ajeeg8qoctaevkcq8jmv
created_at: "2021-06-28T13:08:50.312786870Z"
key_algorithm: RSA_2048

Deron-D_infra git:(packer-base) ✗ ll ~/.yc_keys
total 4.0K
-rw-------. 1 dpp dpp 2.4K Jun 28 16:08 key.json
```

3. Создан файла-шаблона Packer [ubuntu16.json](https://raw.githubusercontent.com/Otus-DevOps-2021-05/Deron-D_infra/packer-base/packer/ubuntu16.json)

4. Созданы скрипты для provisioners [install_ruby.sh](https://raw.githubusercontent.com/Otus-DevOps-2021-05/Deron-D_infra/packer-base/packer/scripts/install_ruby.sh);[install_mongodb.sh](https://raw.githubusercontent.com/Otus-DevOps-2021-05/Deron-D_infra/packer-base/packer/scripts/install_mongodb.sh)

5. Выполнена проверка на ошибки
```
packer validate ./ubuntu16.json
```

6. Произведен запуск сборки образа
```
packer build ./ubuntu16.json
```

7. Создана ВМ с использованием созданного образа

8. Выполнено "дожаривание" ВМ для запуска приложения:
```
sudo apt-get update
sudo apt-get install -y git
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
```

9. Выполнено параметризирование шаблона с применением [variables.json.example](https://raw.githubusercontent.com/Otus-DevOps-2021-05/Deron-D_infra/packer-base/packer/variables.json.example)

10. Построение bake-образа `*`
- Создан [immutable.json](https://raw.githubusercontent.com/Otus-DevOps-2021-05/Deron-D_infra/packer-base/packer/immutable.json)
- Создан systemd unit [puma.service](https://raw.githubusercontent.com/Otus-DevOps-2021-05/Deron-D_infra/packer-base/packer/files/puma.service)
- Запущена сборка
```
packer build -var-file=./variables.json immutable.json
```
- Проверка созданных образов:
```
➜  packer git:(packer-base) yc compute image list
+----------------------+------------------------+-------------+----------------------+--------+
|          ID          |          NAME          |   FAMILY    |     PRODUCT IDS      | STATUS |
+----------------------+------------------------+-------------+----------------------+--------+
| fd821hvkilmtrb7tbi2n | reddit-base-1624888205 | reddit-base | f2el9g14ih63bjul3ed3 | READY  |
| fd8t49b4simvfj6crpta | reddit-full-1624909929 | reddit-full | f2el9g14ih63bjul3ed3 | READY  |
+----------------------+------------------------+-------------+----------------------+--------+
```

11. Автоматизация создания ВМ `*`
- Создан [create-reddit-vm.sh](./config-scripts/create-reddit-vm.sh)


## **Полезное:**

</details>
