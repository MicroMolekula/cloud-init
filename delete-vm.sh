VBoxManage controlvm test poweroff
VBoxManage unregistervm test --delete
rm -R ./vms/test
rm ./template/test/seed.iso