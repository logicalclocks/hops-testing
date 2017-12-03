#!/bin/bash
sh ./clone_karamel_chef.sh

# Copy correct Vagrantfile/cluster
if [ "$1" == "ubuntu" ]; then
  cp templates/Vagrantfile-ubuntu karamel-chef/Vagrantfile
  cp templates/cluster-ubuntu karamel-chef/cluster.yml
else
  # Centos
  cp templates/Vagrantfile-centos karamel-chef/Vagrantfile
  cp templates/cluster-centos karamel-chef/cluster.yml
fi

# Execute the tests
cd karamel-chef
sh ./test.sh
