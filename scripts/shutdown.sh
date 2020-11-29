#!/bin/bash

set -x

export LIBVIRT_DEFAULT_URI="qemu:///system"

virsh undefine "karamel-chef_$1"
virsh destroy "karamel-chef_$1"

rm -rf /home/fabio/libvirt/images/karamel-chef_$1.img

# Centos also has a separate HD
rm -rf /home/fabio/libvirt/images/$1.img


# don't fail the script if the machines are already down
exit 0
