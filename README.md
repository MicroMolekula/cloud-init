- Конвертация образа из формата qcow2 (.img) в формат .vdi:

```bash
qemu-img convert -p -f qcow2 -O vdi ./images/noble-server-cloudimg-amd64.img ./images/ubuntu.vdi
```

- Увеличение виртуального диска до 20 ГБ

```bash
VBoxManage modifymedium disk ./images/ubuntu.vdi --resize 20480
```

- В start-vm.sh
  нужно изменить Ubuntu_arm64, "en0: Wi-Fi"

- Запись валидного user-data файла в результате заполнения шаблона с помощью ytt

```bash
echo "#cloud-config" > builds/service1/user-data && ytt -f templates/schema.yml -f templates/service1/user-data.yml >> builds/service1/user-data
```

Запуск nginx на хосте для раздачи файлов, чтобы можно было их прокидывать в ВМ:
```bash
docker run -d --name nginx-static -p 8080:80 -v "$(pwd)":/usr/share/nginx/html:ro nginx
```