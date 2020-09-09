#!/usr/bin/env bash
set -o errexit
# ==============================================================================
# workflow-init
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
# ------------------------------------------------------------------------------
# Set up the git repository for use with workflow scripts.
#
# NOTE: Scripts that depend on the workflow config set up should run this
# script automagically if the current repo has not been initialized, so you
# probably won't ever need to run this directly.
#
# ------------------------------------------------------------------------------
# Details
# ------------------------------------------------------------------------------
# 1. Create .git/config_workflow. Any configurations made by other workflow
#    scripts will be set in this file.
# 2. Add include.path=config_workflow to local repo config. This will pull in
#    any configurations from that file into the local repo.
# ==============================================================================

# Returns 1 if current repo is already configured, 0 otherwise
#
# Arguments:
#   (Optional) Root of the git repo. Will determine using git_repo_root if
#   unspecified
is_workflow_configured() {
    local repo_root_dir="${1:-$(git_repo_root)}"
    local config_file_exists="$(verify_workflow_config_file "$repo_root_dir")"
    local config_include_exists="$(verify_workflow_config_include)"
    echo $(( $config_file_exists * $config_include_exists ))
}

# Returns 1 if repo has config file for workflow, 0 otherwise
verify_workflow_config_file() {
    local repo_root_dir="$1"
    local workflow_config_path="$repo_root_dir/.git/config_workflow"
    [[ -f "$workflow_config_path" ]] && echo 1 || echo 0
}

# Returns 1 if local config + includes has workflow.configpath set, 0
# otherwise
verify_workflow_config_include() {
    [[ -n "$(git config --local --includes --get workflow.configpath)" ]] &&
        echo 1 || echo 0
}

# TODO args?
init_workflow() {
    [[ "$(is_workflow_configured)" > 0 ]] && echo "Repo already initialized." && exit
    local repo_root_dir="$(git_repo_root)"
    local workflow_config_path="$repo_root_dir/.git/config_workflow"

    echo "Creating workflow config file for this repo..."
    git config -f "$workflow_config_path" workflow.configpath "$workflow_config_path"
    if [[ "$(verify_workflow_config_file "$repo_root_dir")" > 0 ]]; then
        echo_success "Workflow config created:" \
                     "$workflow_config_path"
    else
        echo_error "Unable to create workflow config at the following path:" \
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
        echo_success "Repo configured. Initialization complete."
    else
        echo_error "Something went wrong when adding include.path for workflow config to local repo."
        exit 1
    fi
}
