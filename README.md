# hops-testing
Scripts and files for running end-to-end platform testing for Hops


## Run tests

You should have the same name for all branches of chef cookbooks in this JIRA issue. 
I keep a human readable name, not the JIRA number, as it can be remembered. Like 'tf_serving'.
This means the Berksfile for hopsworks-chef branch should have references to the same 'tf_serving' branch in tensorflow-chef, ndb-chef, kagent-chef, etc.

1. Fork hops-testing to your own repository.

2. git checkout -b JIRA-ID

3. git push -u origin JIRA-ID

4. Generate test_manifesto

./scripts/generate_test_manifesto.sh <branchname>

This will generate a new commit for hopsworks-chef for your branch with the Berksfile references all set to 'master', making a backup with the old Berksfile, so you can rollback for running Vagrant again.

## Back to Vagrant

./scripts/generate_test_manifesto.sh rollback <branchname> reverts the Berksfile master changes.

This will generate a new commit for hopsworks-chef for your branch with the Berksfile references all set back to '<branchname>', so you can run Vagrant again.

## Integration Tests
Some tests don't need to run with every testing instance, as they take too much time to complete and the testing pipeline is slowed down. To run *only* these tests, in your hops-testing pull request you need to set the `"it" => false` property to `"it" => true` in **both** ` hops-testing/templates/Vagrantfile-centos` and ` hops-testing/templates/Vagrantfile-ubuntu` files.
