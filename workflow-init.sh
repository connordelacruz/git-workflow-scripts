#!/usr/bin/env bash
set -o errexit
# ==============================================================================
# workflow-init.sh
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
# ------------------------------------------------------------------------------
# Creates workflow git config file and adds include to local git config.
# ==============================================================================

# Imports ----------------------------------------------------------------------
readonly UTIL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/util"
source "$UTIL_DIR/output.sh"
source "$UTIL_DIR/git.sh"

# Main -------------------------------------------------------------------------

main() {
    # Check git version > 2.23 and that we're in a repo currently
    local version_check="$(verify_git_version)"
    [[ -n "$version_check" ]] && error "$version_check" && exit 1
    verify_git_repo

    [[ "$(is_workflow_configured)" > 0 ]] && echo "Repo already initialized." && exit

    local repo_root_dir="$(git_repo_root)"
    local workflow_config_path="$repo_root_dir/.git/config_workflow"
    echo "Creating workflow config file for this repo..."
    git config -f "$workflow_config_path" workflow.configpath "$workflow_config_path"
    if [[ "$(verify_workflow_config_file "$repo_root_dir")" > 0 ]]; then
        success "Workflow config created:" \
                "$workflow_config_path"
    else
        error "Unable to create workflow config at the following path:" \
              "$workflow_config_path"
        exit 1
    fi
    # It may be possible that the config file was deleted but the include.path
    # value was still present in local git config. To avoid adding duplicate
    # entries, check for the include before updating configurations
    if [[ "$(verify_workflow_config_include)" < 1 ]]; then
        echo "Updating local config..."
        git config --local --add include.path config_workflow
    fi
    # Regardless of whether the config was updated above or not, we want to
    # check again here before displaying the success message
    if [[ "$(verify_workflow_config_include)" > 0 ]]; then
        success "Repo configured. Initialization complete."
    else
        error "Something went wrong when adding include.path for workflow config to local repo."
        exit 1
    fi
}
main "$@"
