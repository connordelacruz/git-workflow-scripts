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
    local branch_name="$(git_current_branch)"
    local branch_config="$(git config --local --get includeif.onbranch:${branch_name}.path)"
    [[ -z "$branch_config" ]] && echo "No config file specified for this branch." && exit
    local repo_root_dir="$(git_repo_root)"
    local branch_config_path="$repo_root_dir/.git/$branch_config"
    local commit_template_file="$(git config -f "$branch_config_path" --get commit.template)"
    local commit_template_path="$repo_root_dir/$commit_template_file"

    # Unset branch config
    echo "Unsetting local repo config..."
    git config --local --unset includeIf.onbranch:${branch_name}.path
    success "Local repo updated." \
            "Will no longer include configs from .git/$branch_config" \
            "when on branch $branch_name."
    echo "Deleting branch config file .git/$branch_config..."
    rm "$branch_config_path"
    success "Branch config file removed."

    # Delete commit template (unless -D was specified)
    if [[ -z "$commit_template_file" ]]; then
        warning "Template file $commit_template_file not found."
        exit
    fi
    if [[ -n "$arg_no_delete" ]]; then
        warning "-D was specified, leaving template file $commit_template_file."
    else
        echo "Removing commit template file $commit_template_file..."
        rm "$commit_template_path"
        success "Removed $commit_template_path"
    fi
}
main "$@"