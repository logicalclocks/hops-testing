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

./geneate_test_manifesto.sh rollback <branchname> reverts the Berksfile master changes.

This will generate a new commit for hopsworks-chef for your branch with the Berksfile references all set back to '<branchname>', so you can run Vagrant again.
