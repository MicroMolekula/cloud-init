#!/bin/bash
set -euo pipefail

VM_NAME="${1:?не указан параметр VM_NAME}"
SITE_NAME="${2:-home}"
BUILD_DIR="$PWD/builds/$SITE_NAME/$VM_NAME"
BASE_IMAGE="$PWD/images/ubuntu.vdi"
SEED_DIR="$PWD/template/$VM_NAME/config"
USER_DATA_DIR="$PWD/templates/$VM_NAME"

if [ ! -d "$USER_DATA_DIR" ]; then
    echo>&2 "Ожидаемая папка $USER_DATA_DIR c user-data не была найдена"
    exit 1
fi

mkdir -p "$BUILD_DIR"

echo "#cloud-config" > "$BUILD_DIR/user-data" && ytt -f "$PWD/templates/schema.yml" -f  "$PWD/sites/$SITE_NAME/common.yml" -f "$PWD/sites/$SITE_NAME/$VM_NAME.yml" -f "$USER_DATA_DIR/data-base.yml" -f "$USER_DATA_DIR/user-data.yml" >> "$BUILD_DIR/user-data"
ytt -f "$PWD/templates/schema.yml" -f  "$PWD/sites/$SITE_NAME/common.yml" -f "$PWD/sites/$SITE_NAME/$VM_NAME.yml" -f "$USER_DATA_DIR/meta-data.yml" > "$BUILD_DIR/meta-data"
ytt -f "$PWD/templates/schema.yml" -f  "$PWD/sites/$SITE_NAME/common.yml" -f "$PWD/sites/$SITE_NAME/$VM_NAME.yml" -f "$USER_DATA_DIR/network-config.yml" > "$BUILD_DIR/network-config"

case "$(uname -s)" in
    Linux)
        cloud-localds -N "$BUILD_DIR"/network-config "$BUILD_DIR"/seed.iso "$BUILD_DIR"/user-data "$BUILD_DIR"/meta-data
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