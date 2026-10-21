#!/bin/bash

VMNAME=$1

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

VBoxManage controlvm $VMNAME poweroff
VBoxManage unregistervm $VMNAME --delete
rm -R "$PWD/vms/$VMNAME"
rm "$PWD/template/$VMNAME/seed.iso"

exit 0;