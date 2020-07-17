#!/usr/bin/env bash
set -o errexit
# ==============================================================================
# unset-commit-template.sh
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
# ------------------------------------------------------------------------------
# For use with commit-template.sh
#
# Unset current branch's git config for commit.template. Template file will be
# deleted unless -D argument was specified.
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

# Imports ----------------------------------------------------------------------
readonly UTIL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/util"
source "$UTIL_DIR/output.sh"
source "$UTIL_DIR/git.sh"

# Functions --------------------------------------------------------------------

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

# TODO local fallback?
# Returns the configured value of commit.template for this repo.
# git_local_commit_template() {
#     git config --local --get commit.template
# }

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
    local version_check="$(verify_git_version)"
    [[ -n "$version_check" ]] && error "$version_check" && exit 1
    verify_git_repo

    # Get current branch and assiociated config
    local project_branch="$(git_current_branch)"
    local branch_config="$(git_branch_config_path "$project_branch")"
    [[ -z "$branch_config" ]] && echo "No config file specified for this branch." && exit
    local commit_template_file="$(git_branch_commit_template "$branch_config")"
    local repo_root_dir="$(git_repo_root)"

    echo "Removing branch config for $project_branch..."
    git config --local --unset includeIf.onbranch:${project_branch}.path
    rm "$repo_root_dir/.git/$branch_config"
    success "Branch config removed."

    # Get template (if configured)
    [[ -z "$commit_template_file" ]] && echo "No local commit template configured." && exit
    # TODO local fallback?
    # local commit_template_file="$(git_local_commit_template)"
    # echo "Unsetting commit.template..."
    # git config --local --unset commit.template

    if [[ -n "$arg_no_delete" ]]; then
        warning "-D was specified, leaving template file $commit_template_file."
    else
        echo "Removing commit template file..."
        rm "$repo_root_dir/$commit_template_file"
        success "Commit template removed."
    fi
}

# Run main, pass any command line options to it for parsing
main "$@"
