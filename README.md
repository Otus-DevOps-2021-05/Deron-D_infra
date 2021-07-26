# **Лекция №5: Знакомство с облачной инфраструктурой Yandex.Cloud**
> _cloud-bastion_
<details>
  <summary>Знакомство с облачной инфраструктурой</summary>

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
```bash
ssh-keygen -t rsa -f ~/.ssh/appuser -C appuser -P ""
```

3. Проверяем подключение по полученному внешнему адресу
```bash
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
```bash
 ~/otus-devops/Deron-D_infra $ eval $(ssh-agent -s)
Agent pid 1739595
```
- Добавим приватный ключ в ssh агент авторизации:
```bash
~/otus-devops/Deron-D_infra $ ssh-add ~/.ssh/appuser
Identity added: /home/dpp/.ssh/appuser (appuser)
```

- Проверяем прямое подключение:
```bash
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
```bash
appuser@bastion:~$ ls -la ~/.ssh/
total 16
drwx------ 2 appuser appuser 4096 Jun 20 13:19 .
drwxr-xr-x 4 appuser appuser 4096 Jun 20 13:12 ..
-rw------- 1 appuser appuser  561 Jun 20 13:11 authorized_keys
-rw-r--r-- 1 appuser appuser  222 Jun 20 13:19 known_hosts
```

- Самостоятельное задание. Исследовать способ подключения к someinternalhost в одну команду из вашего рабочего устройства:

Добавим в ~/.ssh/config содержимое:
```bash
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
```bash
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
```bash
sudo bash -c 'echo "10.129.0.18 someinternalhost" >> /etc/hosts'
```

Добавим в ~/.ssh/config содержимое:
```bash
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
> _cloud-testapp_
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
```bash
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```

- Создан новый инстанс reddit-app [create_instance.sh](https://github.com/Otus-DevOps-2021-05/Deron-D_infra/blob/main/config-scripts/create_instance.sh):

```bash
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
```bash
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential
```

- Проверен Ruby и Bundler:
```bash
$ ruby -v
ruby 2.3.1p112 (2016-04-26) [x86_64-linux-gnu]
$ bundler -v
Bundler version 1.11.2
```

- Установлен и запущен MongoDB [install_mongodb.sh](https://github.com/Otus-DevOps-2021-05/Deron-D_infra/blob/main/config-scripts/install_mongodb.sh):
```bash
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
```
```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates
```
```bash
sudo apt-get update
sudo apt-get install -y mongodb-org
```
```bash
sudo systemctl start mongod
sudo systemctl enable mongod
```

- Выполнен деплой приложения [deploy.sh](https://github.com/Otus-DevOps-2021-05/Deron-D_infra/blob/main/config-scripts/deploy.sh):
```bash
sudo apt-get install -y git
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
```

- Дополнительное задание:

Для создания инстанса с уже развернутым приложением достаточно запустить:
```bash
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
```yaml
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
```bash
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
> _packer-base_
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
~~~bash
packer git:(packer-base) yc compute image list
~~~

~~~
+----------------------+------------------------+-------------+----------------------+--------+
|          ID          |          NAME          |   FAMILY    |     PRODUCT IDS      | STATUS |
+----------------------+------------------------+-------------+----------------------+--------+
| fd821hvkilmtrb7tbi2n | reddit-base-1624888205 | reddit-base | f2el9g14ih63bjul3ed3 | READY  |
| fd8t49b4simvfj6crpta | reddit-full-1624909929 | reddit-full | f2el9g14ih63bjul3ed3 | READY  |
+----------------------+------------------------+-------------+----------------------+--------+
~~~

11. Автоматизация создания ВМ `*`
- Создан [create-reddit-vm.sh](./config-scripts/create-reddit-vm.sh)


## **Полезное:**

</details>


# **Лекция №8: Знакомство с terraform**
> _terraform-1_
<details>
  <summary>Знакомство с terraform</summary>

## **Задание:**
Декларативное описание в виде кода инфраструктуры YC, требуемой для запуска тестового приложения, при помощи Terraform.

Цель:
В данном дз студент опишет всю инфраструктуру в Yandex Cloud при помощи Terraform. В данном задании тренируются навыки: создания и описания инфраструктуры при помощи Terraform. Принципы и подходы IaC.

Все действия описаны в методическом указании.

Критерии оценки:
0 б. - задание не выполнено 1 б. - задание выполнено 2 б. - выполнены все дополнительные задания

---

## **Выполнено:**

1. Установлен terraform 0.12.8 с помощью [terraform-switcher](https://github.com/warrensbox/terraform-switcher)

```
curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | sudo bash

➜  Deron-D_infra git:(terraform-1) ✗ tfswitch
Use the arrow keys to navigate: ↓ ↑ → ←
? Select Terraform version:
  ▸ 0.12.8 *recent

terraform git:(terraform-1) ✗ terraform -v
Terraform v0.12.8
```

2. В корне репозитория создали файл [.gitignore](https://github.com/Otus-DevOps-2021-05/Deron-D_infra/blob/terraform-1/.gitignore) с содержимым:

```
*.tfstate
*.tfstate.*.backup
*.tfstate.backup
*.tfvars
.terraform/
```

3. Узнаем свои параметры токена, идентификатора облака и каталога:
```bash
yc config list
➜  Deron-D_infra git:(terraform-1) ✗ yc config list
token: <OAuth или статический ключ сервисного аккаунта>
cloud-id: <идентификатор облака>
folder-id: <идентификатор каталога>
compute-default-zone: ru-central1-a
```

4. Создадим сервисный аккаунт для работы terraform:
~~~bash
FOLDER_ID=$(yc config list | grep folder-id | awk '{print $2}')
SRV_ACC=trfuser
yc iam service-account create --name $SRV_ACC --folder-id $FOLDER_ID
SRV_ACC_ID=$(yc iam service-account get $SRV_ACC | grep ^id | awk '{print $2}')
yc resource-manager folder add-access-binding --id $FOLDER_ID --role editor --service-account-id $SRV_ACC_ID
yc iam key create --service-account-id $SRV_ACC_ID --output ~/.yc_keys/key.json
~~~

5. Cмотрим информацию о имени, семействе и id пользовательских образов своего каталога с помощью команды yc compute image list:

~~~
Deron-D_infra git:(terraform-1) yc compute image list
+----------------------+------------------------+-------------+----------------------+--------+
|          ID          |          NAME          |   FAMILY    |     PRODUCT IDS      | STATUS |
+----------------------+------------------------+-------------+----------------------+--------+
| fd821hvkilmtrb7tbi2n | reddit-base-1624888205 | reddit-base | f2el9g14ih63bjul3ed3 | READY  |
| fd8t49b4simvfj6crpta | reddit-full-1624909929 | reddit-full | f2el9g14ih63bjul3ed3 | READY  |
+----------------------+------------------------+-------------+----------------------+--------+
~~~

6. Cмотрим информацию о имени и id сети своего каталога с помощью команды yc vpc network list:

~~~
Deron-D_infra git:(terraform-1) yc vpc network list
+----------------------+--------+
|          ID          |  NAME  |
+----------------------+--------+
| enpv6gbrqnhhbp41jurh | my-net |
+----------------------+--------+
~~~

7. Правим main.tf до состояния:

```hcl
terraform {
  required_version = "0.12.8"
}

provider "yandex" {
  version= "0.35"
  service_account_key_file = pathexpand("~/.yc_keys/key.json")
  folder_id = "b1gu87e4thvariradsue"
  zone = "ru-central1-a"
}

resource "yandex_compute_instance" "app" {
  name = "reddit-app"
  resources {
    cores = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
    # Указать id образа созданного в предыдущем домашнем задании
    image_id = "fd821hvkilmtrb7tbi2n"
    }
  }
  network_interface {
  # Указан id подсети default-ru-central1-a
  subnet_id = "e9b7qomc4stvbnr6ejde"
  nat = true
  }
}
```

8. Для того чтобы загрузить провайдер и начать его использовать выполняем следующую команду в
директории terraform:

```bash
terraform init
```

9. Планируем изменения:

```bash
terraform plan
...
Plan: 1 to add, 0 to change, 0 to destroy.
------------------------------------------------------------------------
```

10. Создаем VM согласно описанию:

```bash
➜  terraform git:(terraform-1) terraform apply -auto-approve
yandex_compute_instance.app: Creating...
yandex_compute_instance.app: Still creating... [10s elapsed]
yandex_compute_instance.app: Still creating... [20s elapsed]
yandex_compute_instance.app: Still creating... [30s elapsed]
yandex_compute_instance.app: Still creating... [40s elapsed]
yandex_compute_instance.app: Creation complete after 46s [id=fhm2sg90ppv3l27lhudf]
```

11. Смотрим внешний IP адрес созданного инстанса,

```bash
terraform git:(terraform-1) ✗ terraform show | grep nat_ip_address
        nat_ip_address = "84.201.158.45"
```

12. Пробуем подключиться по SSH:

```bash
terraform git:(terraform-1) ✗ ssh ubuntu@84.201.158.45
ubuntu@84.201.158.45's password:
```

13. Нужно определить SSH публичный ключ пользователя ubuntu в метаданных нашего инстанса добавив в main.tf:

```hcl
metadata = {
ssh-keys = "ubuntu:${file("~/.ssh/appuser.pub")}"
}
```

14. Проверяем:

```bash
➜  terraform git:(terraform-1) ✗ ssh ubuntu@178.154.201.37 -i ~/.ssh/appuser -o StrictHostKeyChecking=no
Warning: Permanently added '178.154.201.37' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 16.04.7 LTS (GNU/Linux 4.4.0-142-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
```

15. Создадим файл outputs.tf для управления выходными переменными с содержимым:

```hcl
output "external_ip_address_app" {
  value = yandex_compute_instance.app.network_interface.0.nat_ip_address
}
```

16. Проверяем работоспособность outputs.tf:

```bash
➜  terraform git:(terraform-1) ✗ terraform refresh
yandex_compute_instance.app: Refreshing state... [id=fhm5o0gooknpnp6v5nmk]
Outputs:
external_ip_address_app = 84.201.157.46

➜  terraform git:(terraform-1) ✗ terraform output
external_ip_address_app = 84.201.157.46
```

17. Добавляем provisioners в main.tf:

```hcl
provisioner "file" {
  source = "files/puma.service"
  destination = "/tmp/puma.service"
}

provisioner "remote-exec" {
script = "files/deploy.sh"
}
```

18. Создадим файл юнита для провижионинга [puma.service](https://github.com/Otus-DevOps-2021-05/Deron-D_infra/blob/terraform-1/terraform/files/puma.service)

19. Добавляем секцию для определения паметров подключения привиженеров:

```hcl
connection {
  type = "ssh"
  host = yandex_compute_instance.app.network_interface.0.nat_ip_address
  user = "ubuntu"
  agent = false
  # путь до приватного ключа
  private_key = file("~/.ssh/appuser")
  }
```

20. Проверяем работу провижинеров. Говорим terraform'y пересоздать ресурс VM при следующем
применении изменений:

```bash
➜  terraform git:(terraform-1) ✗ terraform taint yandex_compute_instance.app
Resource instance yandex_compute_instance.app has been marked as tainted.
```

21. Планируем и применяем изменения:

```bash
terraform plan
terraform apply --auto-approve
```

22. Проверяем результат изменений и работу приложения:

```bash
Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
Outputs:
external_ip_address_app = 178.154.206.153
```

23. Параметризируем конфигурационные файлы с помощью входных переменных:
- Создадим для этих целей еще один конфигурационный файл [variables.tf](https://github.com/Otus-DevOps-2021-05/Deron-D_infra/blob/terraform-1/terraform/variables.tf)
- Определим соответствующие параметры ресурсов main.tf через переменные:

```hcl
provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id = var.cloud_id
  folder_id = var.folder_id
  zone = var.zone
}
```

```hcl
boot_disk {
  initialize_params {
    # Указать id образа созданного в предыдущем домашем задании
    image_id = var.image_id
  }
}

network_interface {
  # Указан id подсети default-ru-central1-a
  subnet_id = var.subnet_id
  nat       = true
}

metadata = {
ssh-keys = "ubuntu:${file(var.public_key_path)}"
}
```

24. Определим переменные используя специальный файл [terraform.tfvars](https://github.com/Otus-DevOps-2021-05/Deron-D_infra/blob/terraform-1/terraform/terraform.tfvars.example)

25. Форматирование и финальная проверка:

```bash
terraform fmt
terraform destroy
terraform plan
terraform apply --auto-approve
```

## **Проверка сервиса по адресу: [http://178.154.206.153:9292/](http://178.154.206.153:9292/)**

### Создание HTTP балансировщика `**`
1. Создадим файл lb.tf со следующим содержимым:

```hcl
resource "yandex_lb_target_group" "reddit_lb_target_group" {
  name      = "reddit-app-lb-group"
  region_id = var.region_id

  target {
    subnet_id = var.subnet_id
    address   = yandex_compute_instance.app.network_interface.0.ip_address
  }
}

resource "yandex_lb_network_load_balancer" "load_balancer" {
  name = "reddit-app-lb"

  listener {
    name = "reddit-app-listener"
    port = 80
    target_port = 9292
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.reddit_lb_target_group.id}"

    healthcheck {
      name = "http"
      http_options {
        port = 9292
        path = "/"
      }
    }
  }
}
```

2. Добавляем в outputs.tf переменные адреса балансировщика и проверяем работоспособность решения:

```hcl
output "loadbalancer_ip_address" {
  value = yandex_lb_network_load_balancer.load_balancer.listener.*.external_address_spec[0].*.address
}
```

3. Добавляем в код еще один terraform ресурс для нового инстанса приложения (reddit-app2):
- main.tf

```hcl
resource "yandex_compute_instance" "app2" {
  name = "reddit-app2"
  resources {
    cores  = 2
    memory = 2
  }
...
  connection {
    type  = "ssh"
    host  = yandex_compute_instance.app2.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file("~/.ssh/appuser")
  }
```

- lb.tf

```hcl
target {
  address = yandex_compute_instance.app2.network_interface.0.ip_address
  subnet_id = var.subnet_id
}
```

- outputs.tf

```hcl
output "external_ip_address_app2" {
  value = yandex_compute_instance.app2.network_interface.0.nat_ip_address
}
```

## **Проблемы в данной конфигурации:**
- Избыточный код
- На инстансах нет единого бэкэнда в части БД (mongodb)

3. Подход с заданием количества инстансов через параметр ресурса count:
- Добавим  в variables.tf

```hcl
variable count_of_instances {
  description = "Count of instances"
  default     = 1
}
```

- В main.tf удалим код для reddit-app2 и добавим:

```hcl
resource "yandex_compute_instance" "app" {
  name  = "reddit-app-${count.index}"
  count = var.count_of_instances
  resources {
    cores  = 2
    memory = 2
  }
...
connection {
  type  = "ssh"
  host  = self.network_interface.0.nat_ip_address
  user  = "ubuntu"
  agent = false
  # путь до приватного ключа
  private_key = file("~/.ssh/appuser")
}
```

- В lb.tf внесем изменения для динамического определения target:
```hcl
dynamic "target" {
  for_each = yandex_compute_instance.app.*.network_interface.0.ip_address
  content {
    subnet_id = var.subnet_id
    address   = target.value
  }
}
```

## **Полезное:**
- [Создать внутренний сетевой балансировщик](https://cloud.yandex.ru/docs/network-load-balancer/operations/internal-lb-create)
- [yandex_lb_network_load_balancer](https://registry.terraform.io/providers/yandex-cloud/yandex/0.44.0/docs/resources/lb_network_load_balancer)
- [yandex_lb_target_group](https://registry.terraform.io/providers/yandex-cloud/yandex/0.44.0/docs/resources/lb_target_group)
- [dynamic Blocks](https://www.terraform.io/docs/language/expressions/dynamic-blocks.html)
- [HashiCorp Terraform 0.12 Preview: For and For-Each](https://www.hashicorp.com/blog/hashicorp-terraform-0-12-preview-for-and-for-each)

```bash
➜  terraform git:(terraform-1) ✗ yc load-balancer network-load-balancer list
+----------------------+---------------+-------------+----------+----------------+------------------------+--------+
|          ID          |     NAME      |  REGION ID  |   TYPE   | LISTENER COUNT | ATTACHED TARGET GROUPS | STATUS |
+----------------------+---------------+-------------+----------+----------------+------------------------+--------+
| b7rul6kjivb12lgkrfud | reddit-app-lb | ru-central1 | EXTERNAL |              1 | enp46hq1qjve9id5v9oo   | ACTIVE |
+----------------------+---------------+-------------+----------+----------------+------------------------+--------+

➜  terraform git:(terraform-1) ✗ yc load-balancer target-group list
+----------------------+---------------------+---------------------+-------------+--------------+
|          ID          |        NAME         |       CREATED       |  REGION ID  | TARGET COUNT |
+----------------------+---------------------+---------------------+-------------+--------------+
| enp46hq1qjve9id5v9oo | reddit-app-lb-group | 2021-07-24 12:42:52 | ru-central1 |            2 |
+----------------------+---------------------+---------------------+-------------+--------------+
```
</details>

# **Лекция №9: Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform**
> _terraform-2_
<details>
  <summary>Создание Terraform модулей для управления компонентами инфраструктуры.</summary>


## **Задание:**
Создание Terraform модулей для управления компонентами инфраструктуры.

Цель:
В данном дз студент продолжит работать с Terraform. Опишет и произведет настройку нескольких окружений при помощи Terraform. Настроит remote backend. В данном задании тренируются навыки: работы с Terraform, использования внешних хранилищ состояния инфраструктуры.

Описание и настройка инфраструктуры нескольких окружений. Работа с Terraform remote backend.

Критерии оценки:
0 б. - задание не выполнено 1 б. - задание выполнено 2 б. выполнены все дополнительные задания

---

## **Выполнено:**

## **Полезное:**
</details>
