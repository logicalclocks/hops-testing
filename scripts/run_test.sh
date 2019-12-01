#!/bin/bash

# Exit the scripts directory
sh scripts/clone_karamel_chef.sh

# Copy correct Vagrantfile/cluster
if [ "$1" == "ubuntu" ]; then
  sleep 5m
  rm -rf $HOME/.berkshelf

  cp templates/Vagrantfile-ubuntu karamel-chef/Vagrantfile
  cp templates/cluster-ubuntu karamel-chef/cluster.yml
  sed -i "s/ubuntu-name/ubuntu-$BUILD_NUMBER/g" karamel-chef/Vagrantfile
else
  # Centos
  cp templates/Vagrantfile-centos karamel-chef/Vagrantfile
  cp templates/cluster-centos karamel-chef/cluster.yml
fi

sed -i "s/centos-name/centos-$BUILD_NUMBER/g" karamel-chef/Vagrantfile

# Execute the tests
cd karamel-chef
sh ./test.sh
