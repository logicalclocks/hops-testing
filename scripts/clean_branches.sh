#!/bin/bash
set -e

cd $HOME/workspace

# Check if the repos directory is there
if [ ! -d repos ]
then
  exit 0
fi

if [ -f test_manifesto ]
then
  rm test_manifesto
fi

cd repos
for repo in */ ; do
  cd $HOME/workspace/repos/$repo
  if [ "$(git branch --list test_platform)" ]
  then
    git reset --hard HEAD
    git checkout master
    git branch -D test_platform
    if [ "$(git show-branch remotes/origin/test_platform)" ]
    then
      git push origin :test_platform
    fi
  fi
done
