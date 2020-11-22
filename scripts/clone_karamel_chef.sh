#!/bin/bash

if [ -d karamel-chef ]; then
  cd karamel-chef
  git pull
  cd ..
else
  git clone "https://github.com/siroibaf/karamel-chef"
  cd karamel-chef
  git checkout kvm
  cd ..
fi
