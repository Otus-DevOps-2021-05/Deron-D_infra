# **Домашнее задание №5: Сборка образов VM при помощи Packer**
<details>
  <summary>Домашнее задание №5: Сборка образов VM при помощи Packer</summary>

## **Задание:**
<details>
 <summary>Подробнее</summary>
Подготовка базового образа VM при помощи Packer.

Цель:
В данном дз студент произведет сборку готового образа с уже установленным приложением при помощи Packer. Задеплоит приложение в Compute Engine при помощи ранее подготовленного образа. В данном задании тренируются навыки: работы с Packer, работы с GCP Compute Engine.

Все действия описаны в методическом указании.

Критерии оценки:
0 б. - задание не выполнено 1 б. - задание выполнено 2 б. - выполнены все дополнительные задания
</details>

---

## **Выполнено:**
<details>
 <summary>Подробнее</summary>

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


</details>

## **Полезное:**

</details>
