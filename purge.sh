#!/bin/bash

set -e
VBOX_MANAGE=/usr/bin/vboxmanage

vms=`$VBOX_MANAGE list vms | awk -F'[{|}]' '{print $2}'`

pkill VBoxHeadless
sleep 5

for vm in ${vms}; do
  $VBOX_MANAGE unregistervm ${vm}
done

rm -rf $HOME/VirtualBox\ VMs/*
