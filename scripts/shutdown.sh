#!/bin/bash

set -x

export LIBVIRT_DEFAULT_URI="qemu:///system"

virsh undefine "karamel-chef_$1"
virsh destroy "karamel-chef_$1"

# don't fail the script if the machines are already down
exit 0
