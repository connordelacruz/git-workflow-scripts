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

# Check for git 2.23+ (required for per-branch configs)
verify_git_version() {
    local expr="git version ([0-9]+)\.([0-9]*)\.[0-9]*.*"
    local version="$(git --version)"
    if [[ $version =~ $expr ]]; then
        local major="${BASH_REMATCH[1]}"
        local minor="${BASH_REMATCH[2]}"
        if (( $major < 2 )) || (( $minor < 23 )); then
            echo "Requires git version 2.23 or greater (installed: $version)"
            exit 1
        fi
    # else
    #     # TODO something went wrong?
    fi
}

# Returns the path to the root of this git repo.
git_repo_root() {
    git rev-parse --show-toplevel
}

# Returns the name of the current branch
git_current_branch() {
    git symbolic-ref --short HEAD
}

# Returns the formatted name of

# Returns the of the branch's config file
git_branch_config_path() {
    local branch_name="$1"
    git config --local --get includeif.onbranch:${branch_name}.path
}

# Returns the filename of the configured commit template
git_branch_commit_template() {
    local branch_config="$1"
    git config -f ".git/$branch_config" --get commit.template
}

# Returns the configured value of commit.template for this repo.
# TODO LOCAL FALLBACK
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

    # Check git version > 2.23 and that we're in a repo currently
    verify_git_version
    verify_git_repo

    # Get current branch and assiociated config
    local project_branch="$(git_current_branch)"
    local branch_config="$(git_branch_config_path "$project_branch")"
    [[ -z "$branch_config" ]] && echo "No config file specified for this branch." && exit
    local commit_template_file="$(git_branch_commit_template "$branch_config")"
    local repo_root_dir="$(git_repo_root)"
    echo "Removing branch config..."
    git config --local --unset includeIf.onbranch:${project_branch}.path
    rm "$repo_root_dir/.git/$branch_config"

    # TODO USE AS FALLBACK??
    # Get template (if configured)
    # local commit_template_file="$(git_commit_template)"
    [[ -z "$commit_template_file" ]] && echo "No local commit template configured." && exit

    # echo "Unsetting commit.template..."
    # git config --local --unset commit.template

    if [[ -n "$arg_no_delete" ]]; then
        echo "-D was specified, leaving template file $commit_template_file."
    else
        echo "Removing template file..."
        rm "$repo_root_dir/$commit_template_file"
        echo "Template removed."
    fi
}

# Run main, pass any command line options to it for parsing
main "$@"
