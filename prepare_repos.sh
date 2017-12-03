#!/bin/bash
set -e

# Do everything one directory above to make cleaning easier
cd ..

# List of cookbooks and hopsworks repos
repos=(hopsworks hopsworks-chef conda-chef kagent-chef hops-hadoop-chef
	   spark-chef flink-chef zeppelin-chef livy-chef ndb-chef
	   dr-elephant-chef tensorflow-chef epipe-chef dela-chef
	   kzookeeper kafka-cookbook elasticsearch-chef hopslog-chef
	   hopsmonitor-chef chef-glassfish chef-ulimit hive-chef)

# Create a cookbook directory - if it doesn't exists
if [ ! -d repos ];
then
    mkdir repos
fi
cd repos

# Clone and/or update the repos
for repo in "${repos[@]}"
do
  if [ -d $repo ]; then
    cd $repo
    git checkout master
  else
    git clone git@github.com:hopsworksjenkins/$repo.git
    cd $repo
    git remote add upstream git@github.com:hopshadoop/$repo.git
  fi

  # Update the repositories
  git pull upstream master
  git checkout -b test_platform
  cd ..
done

# Parse the test specification file
while IFS= read -r line
do
  org=$(awk '{split($0, splits, "/"); print splits[1]}' <<< $line)
  repo=$(awk '{split($0, splits, "/"); print splits[2]}' <<< $line)
  branch=$(awk '{split($0, splits, "/"); print splits[3]}' <<< $line)

  cd $repo
  git pull --no-edit git://github.com/$org/$repo.git $branch
  cd ..
done <"../test_manifesto"

# Replace all the Berksfile links from
find . -type f -name "Berksfile" -exec  sed -i 's/hopshadoop/hopsworksjenkins/g' {} \;
find . -type f -name "Berksfile" -exec  sed -i 's/master/test_platform/g' {} \;

# Push everything
for repo in "${repos[@]}"
do
  cd $repo
  # Check if there is anything to commit
  if [ "$(git diff --exit-code)" ];
  then
    git add -A
    git commit -m "Test"
  fi

  git push origin test_platform
  cd ..
done
