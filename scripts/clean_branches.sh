#!/bin/bash
set -e

cd repos
for repo in */ ; do
  cd $repo
  git fetch origin
  if [ "$(git branch --list $BUILD_NUMBER)" ]
  then
    git reset --hard HEAD
    git checkout master
    git branch -D $BUILD_NUMBER
    if [ "$(git show-branch remotes/origin/$BUILD_NUMBER)" ]
    then
      git push origin :$BUILD_NUMBER
    fi
  fi
done
