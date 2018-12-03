#!/bin/bash

set -e

# Check if virtualenv has been created
cd ..
if [ ! -d license_checker_env ]
then
  virtualenv -p python3.6 license_checker_env
  source license_checker_env/bin/activate
  pip install gitpython
else
  source license_checker_env/bin/activate
fi

# All the repositories are in the repos directory under the workspace directory
cd repos

# Currently we only check the license headers in Hopsworks
python $WORKSPACE/scripts/license_checker.py --dir hopsworks --whitelist_dir $WORKSPACE/licenses_whitelist --branch test_platform --fork_commit ccc0d2c5f9a5ac661e60e6eaf138de7889928b8b
