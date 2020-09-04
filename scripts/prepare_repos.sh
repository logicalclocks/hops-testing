#!/bin/bash
set -e

# List of cookbooks and hopsworks repos
repos=(hopsworks hopsworks-chef
conda-chef kagent-chef hops-hadoop-chef
	   spark-chef flink-chef livy-chef ndb-chef
	   dr-elephant-chef tensorflow-chef epipe-chef dela-chef cloud-chef
	   kzookeeper kafka-cookbook elasticsearch-chef hopslog-chef
	   hopsmonitor-chef chef-glassfish chef-ulimit hive-chef airflow-chef kube-hops-chef consul-chef)

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
    # Make sure there is no garbage laying around
    git add -A
    git reset --hard origin/master
  else
    git clone git@github.com:hopsworksjenkins/$repo.git
    cd $repo
    git remote add upstream git@github.com:logicalclocks/$repo.git
  fi

  # Update the repositories
  git pull upstream master

  git checkout -b $BUILD_NUMBER
  cd ..
done

# This means, for instance, that wc -l shows a n-1 number of lines
# The next part of the script assumes that bash can count the number of lines correctly
# The following is a trick to add the newline at the end, if it doesn't exist
sed -i '$a\' ../test_manifesto

# Parse the test specification file
while IFS= read -r line
do
  org=$(awk '{split($0, splits, "/"); print splits[1]}' <<< $line)
  repo=$(awk '{split($0, splits, "/"); print splits[2]}' <<< $line)
  branch=$(awk '{split($0, splits, "/"); print splits[3]}' <<< $line)

  cd $repo
  git pull --no-edit git@github.com:$org/$repo.git $branch
  cd ..
done <"../test_manifesto"

# Replace all the Berksfile links from
find . -type f -name "Berksfile" -exec  sed -i 's/logicalclocks/hopsworksjenkins/g' {} \;
find . -type f -name "Berksfile" -exec  sed -i "s/master/$BUILD_NUMBER/g" {} \;

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

  # Check if there are some wild dependencies.
  if cat Berksfile | grep github: | grep -v $BUILD_NUMBER
  then
    echo "$repo has non-master dependencies"
    exit 1
  fi

  if cat Berksfile | grep github: | grep -v hopsworksjenkins
  then
    echo "$repo has non-master dependencies"
    exit 1
  fi

  git push origin $BUILD_NUMBER
  cd ..
done
