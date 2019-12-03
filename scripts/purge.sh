#!/bin/bash

VBOX_MANAGE=/usr/bin/vboxmanage

vms=`$VBOX_MANAGE list vms | grep -e "\-$BUILD_NUMBER[\.\"]" | awk -F'[{|}]' '{print $2}'
privnetif=`${VBOX_MANAGE} showvminfo ubuntu-$BUILD_NUMBER.1 | grep 'Host-only Interface' | awk -F',' '{print $2}' | awk -F' ' '{print $4}' | sed "s/'//g"`

pkill VBoxHeadless
sleep 10

for vm in ${vms}; do
  $VBOX_MANAGE unregistervm ${vm}
done

$VBOX_MANAGE hostonlyif remove $privnetif

rm -rf $HOME/VirtualBox\ VMs/*
