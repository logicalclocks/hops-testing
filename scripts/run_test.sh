#!/bin/bash

export BERKSHELF_PATH=$PWD

# Exit the scripts directory
sh scripts/clone_karamel_chef.sh

# Copy correct Vagrantfile/cluster
if [ "$1" == "ubuntu" ]; then
  cp templates/Vagrantfile-ubuntu karamel-chef/Vagrantfile
  cp templates/cluster-ubuntu karamel-chef/cluster.yml
  sed -i "s/ubuntu-name/ubuntu-$BUILD_NUMBER/g" karamel-chef/Vagrantfile
else
  # Centos
  cp templates/Vagrantfile-centos karamel-chef/Vagrantfile
  cp templates/cluster-centos karamel-chef/cluster.yml
  sed -i "s/centos-name/centos-$BUILD_NUMBER/g" karamel-chef/Vagrantfile
fi

sed -i "s/BRANCH/$BUILD_NUMBER/g" karamel-chef/Vagrantfile
sed -i "s/BRANCH/$BUILD_NUMBER/g" karamel-chef/cluster.yml
sed -i "s/NEXUS_USER/$NEXUS_USER/g" karamel-chef/cluster.yml
sed -i "s/NEXUS_PW/$NEXUS_PW/g" karamel-chef/cluster.yml

# Execute the tests
cd karamel-chef
./test.sh
