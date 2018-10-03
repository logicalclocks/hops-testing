#!/bin/bash

# if [ -d karamel-chef ]; then
#   cd karamel-chef
#   git pull
#   cd ..
# else
#   git clone "https://github.com/hopshadoop/karamel-chef"
# fi

rm -rf karamel-chef
git clone "https://github.com/kouzant/karamel-chef.git"
cd karamel-chef
git checkout HOPSWORKS-582
cd ..
