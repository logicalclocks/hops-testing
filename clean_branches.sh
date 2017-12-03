#!/bin/bash
set -e

# Check if the repos directory is there
if [ ! -d ../repos ]
then
  exit 0
fi

for repo in ../repos/*/
do
  cd $repo
  if [ "$(git branch --list test_platform)" ]
  then
    git checkout master
    git branch -D test_platform
    if [ "$(git show-branch remotes/origin/test_platform)" ]
    then
      git push origin :test_platform
    fi
  fi
  cd ..
done
