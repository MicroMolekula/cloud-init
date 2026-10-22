#!/bin/bash
set -euo pipefail

ENV_FILE="./hosts/${2:-$(hostname)}.env"

source "$ENV_FILE"

VM_NAME="${1:?не указан параметр VM_NAME}"

VBoxManage controlvm "$VM_NAME" poweroff || true
VBoxManage unregistervm "$VM_NAME" --delete
if [ "${VM_IP:-}" ]; then
    echo "попали в условие"
    ssh-keygen -R "$VM_IP"
fi
rm -R ./vms/"$VM_NAME"
rm ./builds/"$VM_NAME"/seed.iso