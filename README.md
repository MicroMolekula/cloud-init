# Запуск виртуальных машин с cloud-init

Скрипты в этом репозитории подготавливают конфигурацию cloud-init и запускают виртуальную машину VirtualBox на хосте с Ubuntu. При первой загрузке ВМ получает имя хоста, статический IP и SSH-ключи из конфигурации. Пакеты `htop` и `tree` устанавливаются автоматически.

## Подготовка

На хосте нужны VirtualBox, `ytt` и `cloud-localds` из пакета `cloud-image-utils`. Базовый диск должен лежать в `images/ubuntu.vdi`. Его можно получить из облачного образа Ubuntu 24.04 с помощью `qemu-img` из пакета `qemu-utils`:

```bash
qemu-img convert -p -f qcow2 -O vdi images/noble-server-cloudimg-amd64.img images/ubuntu.vdi
```

Настройки сети и ВМ для площадки `home` лежат в `sites/home/`. Шаблоны cloud-init находятся в `templates/`, а параметры VirtualBox для хоста, включая имя сетевого адаптера, задаются в `hosts/*.env`. В примере ниже используется профиль `sergey-PC`. На другом компьютере укажите свой профиль и проверьте, что IP ВМ свободен и подходит для вашей сети.

## Запуск и проверка

Команды выполняются из корня репозитория. Скрипт запуска сам собирает `builds/home/service1/seed.iso` и подключает его к ВМ.

```bash
bash start-vm-ytt.sh service1 sergey-PC home
ssh root@192.168.0.229 'hostname; cloud-init status --wait; dpkg-query -W htop tree'
```

Для входа используйте ключ, чей публичный ключ указан в конфигурации площадки. При проверке ВМ ответила с именем `service1-pc`, cloud-init завершился со статусом `done`, оба пакета были установлены.

ISO можно собрать отдельно, без запуска ВМ:

```bash
bash create-seed-ytt.sh service1 home
```

## Удаление ВМ

Для проверки удаления использовалась отдельная ВМ `service2` с адресом `192.168.0.230`. После подключения по SSH её ключ появился в `~/.ssh/known_hosts`.

```bash
bash delete-vm.sh service2 home
```
