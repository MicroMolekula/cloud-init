#!/bin/bash
set -euo pipefail

VM_NAME="${1:?не указан параметр VM_NAME}"


VBoxManage controlvm "$VM_NAME" poweroff || true
VBoxManage unregistervm "$VM_NAME" --delete
rm -R ./vms/"$VM_NAME"
rm ./builds/"$VM_NAME"/seed.iso