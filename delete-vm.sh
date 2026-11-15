#!/bin/bash
set -euo pipefail

ENV_FILE="./hosts/${2:-$(hostname)}.env"

source "$ENV_FILE"

VM_NAME="${1:?не указан параметр VM_NAME}"

VM_IP="$(ytt -f templates/schema.yml -f sites/home/common.yml -f "sites/home/${VM_NAME}.yml" -f templates/vm-ip.yml | awk '$1 == "ip:" {print $2}')"
VM_IP="${VM_IP%/*}"

VBoxManage controlvm "$VM_NAME" poweroff || true
VBoxManage unregistervm "$VM_NAME" --delete
if [ "${VM_IP:-}" ]; then
    ssh-keygen -R "$VM_IP"
fi
rm -rf ./vms/"$VM_NAME"
rm -rf ./builds/"$VM_NAME"

