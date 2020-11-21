#!/bin/bash

virsh undefine karamel-chef_$1
virsh destroy karamel-chef_$1

# don't fail the script if the machines are already down
exit 0
