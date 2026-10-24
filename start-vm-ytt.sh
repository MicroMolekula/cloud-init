#!/bin/bash
set -euo pipefail

ENV_FILE="$PWD/hosts/${2:-$(hostname)}.env"

if [ ! -f "$ENV_FILE" ]; then 
    echo>&2 "Профиль не найден: $ENV_FILE"
    echo>&2 "Доступные:"
    echo>&2 "$(for f in ./hosts/*.env; do
                    basename -s .env "$f"
                done)"
    echo>&2 "Использование: $0 <имя_VM> [название профиля без .env]"
    exit 1
fi 

source "$ENV_FILE"

VM_NAME="${1:?не указан параметр VM_NAME}"
BUILD_DIR="$PWD/builds/$VM_NAME"
BASE_IMAGE="$PWD/images/ubuntu.vdi"
SEED_DIR="$PWD/template/$VM_NAME/config"
USER_DATA_DIR="$PWD/templates/$VM_NAME"

if [ ! -d "$USER_DATA_DIR" ]; then
    echo>&2 "Ожидаемая папка $USER_DATA_DIR c user-data не была найдена"
    exit 1
fi

mkdir -p "$BUILD_DIR"

echo "#cloud-config" > "$BUILD_DIR/user-data" && ytt -f "$PWD/templates/schema.yml" -f "$PWD/templates/values.yml" -f "$USER_DATA_DIR" >> "$BUILD_DIR/user-data"

case "$(uname -s)" in
    Linux)
        cloud-localds -N "$SEED_DIR"/network-config "$BUILD_DIR"/seed.iso "$BUILD_DIR"/user-data "$SEED_DIR"/meta-data
        ;;
    Darwin)
        rm -f "$BUILD_DIR/seed.iso"
        hdiutil makehybrid -o "$BUILD_DIR"/seed.iso -hfs -joliet -iso -default-volume-name cidata "$SEED_DIR"
        ;;
    *)
        echo>&2 "Отсутствует инструкция для подготовки seed-образа на вашей хостовой ОС: $(uname -s)"
        exit 1
        ;;
esac

VBoxManage createvm --name "$VM_NAME" --ostype "$VM_OSTYPE" --basefolder "$PWD"/vms --register
VBoxManage modifyvm "$VM_NAME" --memory "$VM_MEMORY_MB" --cpus "$VM_CPUS" --nic1 bridged --bridgeadapter1 "$BRIDGE_ADAPTER" --graphicscontroller none --uart1 0x3F8 4 --uartmode1 file "$PWD"/vms/"$VM_NAME"/console.log

VBoxManage storagectl "$VM_NAME" --name VirtIO --add virtio --controller VirtIO
VBoxManage storageattach "$VM_NAME" --storagectl VirtIO --port 0 --device 0 --type hdd --medium "$BASE_IMAGE" --mtype immutable
VBoxManage storageattach "$VM_NAME" --storagectl VirtIO --port 1 --device 0 --type dvddrive --medium "$BUILD_DIR"/seed.iso

VBoxManage startvm "$VM_NAME" --type headless

