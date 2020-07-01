#!/usr/bin/env bash
set -o errexit
# ==============================================================================
# unset-commit-template.sh
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
#
# TODO DOCUMENT:
#   - usage
# ==============================================================================

# Functions --------------------------------------------------------------------

# Verify that this is a git repo.
#
# Calls git status silently. Any error will be printed to STDERR and the script
# will exit.
verify_git_repo() {
    git status 1> /dev/null
}

# Returns the path to the root of this git repo.
git_repo_root() {
    git rev-parse --show-toplevel
}

# Returns the configured value of commit.template for this repo.
git_commit_template() {
    git config --local --get commit.template
}

# Main -------------------------------------------------------------------------

# Checks the local commit.template config for the current repo. If configured,
# will unset and delete the template file it was set to.
main() {
    # Check that this is a git repo
    verify_git_repo

    # TODO: -D to not delete file?

    # Get template (if configured)
    local commit_template_file="$(git_commit_template)"
    [[ -z "$commit_template_file" ]] && echo "No local commit template configured." && exit

    echo "Unsetting commit.template..."
    git config --local --unset commit.template

    echo "Removing template file..."
    local current_dir="$(pwd)"
    local repo_root_dir="$(git_repo_root)"
    cd "$repo_root_dir"
    rm -f "$commit_template_file"
    echo "Template removed."

    # Return to previous directory before exiting
    cd "$current_dir"
}

# Run main, pass any command line options to it for parsing
main "$@"

