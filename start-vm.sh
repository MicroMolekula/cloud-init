#!/bin/bash

VMNAME=$1
IMAGENAME="ubuntu.vdi"
BRIDGEINTERFACE="en0: Wi-Fi"

if [ -z $VMNAME ]
then
    echo "vm's name is required"
    exit 1;
fi

if [[ ! -e "$PWD/template/$VMNAME" ]]
then
    echo "cloud-init template not found"
    exit 1;
fi

VBoxManage createvm --name $VMNAME --ostype Ubuntu_arm64 --basefolder "$PWD/vms" --register
VBoxManage modifyvm $VMNAME --memory 2048 --cpus 2 --nic1 bridged --bridgeadapter1 "$BRIDGEINTERFACE" --graphicscontroller none --uart1 0x3F8 4 --uartmode1 file "$PWD/vms/$VMNAME/console.log"

hdiutil makehybrid -ov -o "$PWD/template/$VMNAME/seed.iso" -hfs -joliet -iso -default-volume-name cidata "$PWD/template/$VMNAME/seed"

VBoxManage storagectl $VMNAME --name VirtIO --add virtio --controller VirtIO
VBoxManage storageattach $VMNAME --storagectl VirtIO --port 0 --device 0 --type hdd --medium "$PWD/images/$IMAGENAME" --mtype immutable
VBoxManage storageattach $VMNAME --storagectl VirtIO --port 1 --device 0 --type dvddrive --medium "$PWD/template/$VMNAME/seed.iso"

VBoxManage startvm $VMNAME --type headless

exit 0;
