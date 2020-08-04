#!/usr/bin/env bash
set -o errexit
# ==============================================================================
# init.sh
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
# ------------------------------------------------------------------------------
# TODO DOC
# ==============================================================================

# Imports ----------------------------------------------------------------------
readonly UTIL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/util"
source "$UTIL_DIR/output.sh"
source "$UTIL_DIR/git.sh"

# Main -------------------------------------------------------------------------

# TODO DOC
main() {
    # Check git version > 2.23 and that we're in a repo currently
    local version_check="$(verify_git_version)"
    [[ -n "$version_check" ]] && error "$version_check" && exit 1
    verify_git_repo

    # TODO See if this repo has been initialized, do nothing if it has (unless -f?)

    local repo_root_dir="$(git_repo_root)"
    local workflow_config_path="$repo_root_dir/.git/config_workflow"
    echo "Creating workflow config file for this repo..."
    git config -f "$workflow_config_path" workflow.configpath "$workflow_config_path"
    if [[ -f "$workflow_config_path" ]]; then
        success "Workflow config created:" \
                "$workflow_config_path"
    else
        error "Unable to create workflow config at the following path:" \
              "$workflow_config_path"
        exit 1
    fi
    echo "Updating local config..."
    git config --local --add include.path config_workflow
    if [[ -n "$(git config --local --includes --get workflow.configpath)" ]]; then
        success "Repo configured. Initialization complete."
    else
        error "Something went wrong when adding include.path for workflow config to local repo."
        exit 1
    fi
}
main "$@"
