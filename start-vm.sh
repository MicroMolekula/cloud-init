#!/bin/bash

VBoxManage createvm --name test --ostype Ubuntu_arm64 --basefolder "$PWD/vms" --register
VBoxManage modifyvm test --memory 2048 --cpus 2 --nic1 bridged --bridgeadapter1 "en0: Wi-Fi" --graphicscontroller none --uart1 0x3F8 4 --uartmode1 file "$PWD/vms/test/console.log"

hdiutil makehybrid -o ./template/test/seed.iso -hfs -joliet -iso -default-volume-name cidata ./template/test/seed

VBoxManage storagectl test --name VirtIO --add virtio --controller VirtIO
VBoxManage storageattach test --storagectl VirtIO --port 0 --device 0 --type hdd --medium ./images/ubuntu.vdi --mtype immutable
VBoxManage storageattach test --storagectl VirtIO --port 1 --device 0 --type dvddrive --medium ./template/test/seed.iso

VBoxManage startvm test --type headless
