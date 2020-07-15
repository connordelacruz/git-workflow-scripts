#!/usr/bin/env bash
set -o errexit
# ==============================================================================
# unset-commit-template.sh
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
# ------------------------------------------------------------------------------
# For use with commit-template.sh
#
# Unset local git config for commit.template if configured. Template file will
# be deleted unless -D argument was specified.
#
# ------------------------------------------------------------------------------
# Usage
# ------------------------------------------------------------------------------
# Running unset-commit-template -h will display details on usage and arguments:
#
# Usage: unset-commit-template.sh [-D] [-h]
# Options:
#   -D  Don't delete commit template file.
#   -h  Show this help message and exit.
#
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

# Display help message for this script
show_help() {
    echo "Usage: unset-commit-template.sh [-D] [-h]"
    echo "Options:"
    echo "  -D  Don't delete commit template file."
    echo "  -h  Show this help message and exit."
}

# Main -------------------------------------------------------------------------

# Checks the local commit.template config for the current repo. If configured,
# will unset and delete the template file it was set to.
#
# Arguments:
#   Takes all optional arguments for script. For details on these arguments,
#   see show_help()
main() {
    # Parse arguments:
    # -D (don't delete template file)
    local arg_no_delete
    while getopts 'Dh' opt; do
        case ${opt} in
            D)
                arg_no_delete=1
                ;;
            h|?)
                show_help
                [[ "$opt" = "?" ]] && local exit_code=1 || local exit_code=0
                exit $exit_code
                ;;
        esac
    done
    shift $((OPTIND -1))

    # Check that this is a git repo before proceeding
    verify_git_repo

    # Get template (if configured)
    local commit_template_file="$(git_commit_template)"
    [[ -z "$commit_template_file" ]] && echo "No local commit template configured." && exit

    echo "Unsetting commit.template..."
    git config --local --unset commit.template

    if [[ -n "$arg_no_delete" ]]; then
        echo "-D was specified, leaving template file $commit_template_file."
    else
        echo "Removing template file..."
        local current_dir="$(pwd)"
        local repo_root_dir="$(git_repo_root)"
        cd "$repo_root_dir"
        rm -f "$commit_template_file"
        echo "Template removed."
        # Return to previous directory before exiting
        cd "$current_dir"
    fi
}

# Run main, pass any command line options to it for parsing
main "$@"
