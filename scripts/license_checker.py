import argparse
import git
import re
import sys
import os

from git import Repo

agpl_regex = "GNU Affero General Public License as published by the Free Software Foundation"
mit_regex = "Permission is hereby granted, free of charge, to any person obtaining a copy of " \
            "this software and associated documentation files \(the \"Software\"\), " \
            "to deal in the Software"

commit_regex_placeholder = "Changes to this file committed (before|after) and (not )?including commit-id: commit_id " \
                           "are released under the following license:"

copyright_with_rise_regex = "Copyright \(C\) 2013 - 2018, Logical Clocks AB and RISE SICS AB\. All rights reserved"
copyright_lc_regex = "Copyright \(C\) 2018, Logical Clocks AB\. All rights reserved"


def read_whitelist(whitelist_dir):
    with open(os.path.join(whitelist_dir, 'hopsworks_whitelist'), 'r') as wh:
        return wh.read().splitlines()


def read_lc_files(whitelist_dir):
    with open(os.path.join(whitelist_dir, 'lc_files'), 'r') as lc_files:
        return lc_files.read().splitlines()


def history_shas(repo, branch):
    shas = []

    for commit in repo.iter_commits(branch):
        shas.append(commit.hexsha)

    return shas


def get_file_content(file_path):
    with open(file_path, 'r') as file:
        content = file.read()

        # Remove newlines, tabs and spaces
        content = content.replace('\n', '').replace('\t', '')

        # Remove SQL comments
        content = content.replace("--", '')

        # Remove comments for licenses
        content = content.replace("  ~", '').replace(" *", '')

        # Remove ruby headers
        return content.replace("=begin", '').replace("=end", '')


def check_only_agpl(file_path, fork_commit):
    content = get_file_content(file_path)

    matches_agpl = re.findall(agpl_regex, content)
    matches_mit = re.findall(mit_regex, content)
    matches_copyright = re.findall(copyright_lc_regex, content)
    matches_copyright_rise = re.findall(copyright_with_rise_regex, content)

    commit_regex = commit_regex_placeholder.replace("commit_id", str(fork_commit))
    matches_commit = re.findall(commit_regex, content)

    return len(matches_agpl) == 1 and len(matches_mit) == 0 \
           and len(matches_copyright) == 1 and len(matches_copyright_rise) == 0 \
           and len(matches_commit) == 0



def check_double_license(file_path, fork_commit):
    content = get_file_content(file_path)

    commit_regex = commit_regex_placeholder.replace("commit_id", str(fork_commit))
    matches_commit = re.findall(commit_regex, content)

    matches_agpl = re.findall(agpl_regex, content)
    matches_mit = re.findall(mit_regex, content)

    matches_copyright = re.findall(copyright_lc_regex, content)
    matches_copyright_rise = re.findall(copyright_with_rise_regex, content)

    return len(matches_commit) == 2 and len(matches_agpl) == 1 and len(matches_mit) == 1 \
           and len(matches_copyright) == 1 and len(matches_copyright_rise) == 1


# TODO: this is extremely slow. An optimization would be to check only
# new files and files which have changed.
def check_file(repo, file_rel_path, file_path, branch, shas, fork_commit, fork_commit_idx, lc_files):
    git_handle = repo.git
    git_handle.checkout(branch)
    full_log = git_handle.log('--follow', file_path)
    commit_list = re.findall("commit\ [a-z0-9]{40}", full_log)
    revisions = [sha.split(" ")[1] for sha in commit_list]

    # The last commit is the oldest one
    first_commit_idx = shas.index(revisions[-1])
    if (first_commit_idx < fork_commit_idx) or (file_rel_path in lc_files):
        # File newer than the fork. Check only AGPL license
        return check_only_agpl(file_path, fork_commit)
    else:
        # File older than the fork. Check both header present.
        return check_double_license(file_path, fork_commit)


def main(hopsworks_dir, whitelist_dir, branch, fork_commit):
    # Read white list. List of files with specific licenses or no licenses at all
    # (e.g. scripts)
    whitelist = read_whitelist(whitelist_dir)

    # Read file list of files committed into the repo before the fork, but only edited
    # by LC employees. - This is a small list of stuff Jim committed himself
    lc_files = read_lc_files(whitelist_dir)

    # Extensions of files to check
    ext = ['java', 'xml', 'html', 'xhtml', 'js', 'css', 'rb', 'py', 'sc', 'scala', 'php', 'erb']

    repo = Repo(hopsworks_dir)

    # Get all the commit SHAs in the repo history
    shas = history_shas(repo, branch)

    # Find index of the fork_commit
    fork_commit_idx = shas.index(fork_commit)

    # Iterate over all the files and check if they are older than the fork_commit

    # Create tree object of the repository
    tree = repo.heads[branch].commit.tree

    # Iterate over all the entries but check only the files
    wrong_files = False
    # check_file(repo,'hopsworks-api/src/main/java/io/hops/hopsworks/api/util/VersionsDTO.java','/home/fabio/work/hopsworks/hopsworks-api/src/main/java/io/hops/hopsworks/api/util/VersionsDTO.java',
    #             branch, shas, fork_commit, fork_commit_idx, lc_files)
    for entry in tree.list_traverse():
        if isinstance(entry, git.objects.blob.Blob):
            try:
                if entry.path not in whitelist and entry.name.split('.')[-1] in ext:
                    # If entry is not in the whitelist then check the file
                    if not check_file(repo, entry.path, entry.abspath, branch, shas, fork_commit, fork_commit_idx, lc_files):
                        wrong_files = True
                        print(entry.abspath + " does not have the correct license header")
            except UnicodeDecodeError:
                # File is not text, move on
                pass

    # If there were any file with wrong license exit with 1
    # So that Jenkins can pick up the error and fail the whole pipeline.
    if wrong_files:
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Hopsworks license checker arguments")
    parser.add_argument("--dir", type=str, help="Hopsworks directory")
    parser.add_argument("--whitelist_dir", type=str, help="Directory for whitelist files")
    parser.add_argument("--branch", type=str, help="Branch on which run the script")
    parser.add_argument("--fork_commit", type=str, help="Hash of the fork commit")

    args = parser.parse_args()

    if len(sys.argv) != 9:
        parser.print_help()
        sys.exit(1)

    main(args.dir, args.whitelist_dir, args.branch, args.fork_commit)
