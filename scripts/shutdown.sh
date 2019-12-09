#!/bin/bash

vms=`vboxmanage list vms | grep $1 | awk -F'[{|}]' '{print $2}'`

for vm in $vms
do
    vboxmanage controlvm $vm poweroff
done

# don't fail the script if the machines are already down
exit 0
