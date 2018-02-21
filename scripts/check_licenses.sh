#!/bin/bash

set -e

checker_bin="$WORKSPACE/scripts/licensecheck.pl"
whitelist_dir="$WORKSPACE/licenses_whitelist"

# All the repositories are in the repos directory under the workspace directory
cd ../repos

# Currently we only check the license headers in Hopsworks
repos=(hopsworks)

for repo in "${repos[@]}"
do
  cd $repo
  diff <($checker_bin -r . | grep -v "MIT" | sort) <(cat "$whitelist_dir/$repo" | sort)
  cd ..
done
