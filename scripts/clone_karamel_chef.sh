#!/bin/bash

if [ -d karamel-chef ]; then
  cd karamel-chef
  git pull
  cd ..
else
  git clone "https://github.com/logicalclocks/karamel-chef"
fi
