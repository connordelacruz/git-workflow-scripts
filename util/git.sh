# ==============================================================================
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
#
# Git-related helper methods.
# ==============================================================================

# Verification -----------------------------------------------------------------

# Verify that this is a git repo.
#
# Calls git status silently. Any error will be printed to STDERR and the script
# will exit.
verify_git_repo() {
    git status 1> /dev/null
}

# Check for git 2.23+ (required for per-branch configs).
#
# If version is fine, then outputs nothing. If version is too low, echos error
# message.
verify_git_version() {
    local expr="git version ([0-9]+)\.([0-9]*)\.[0-9]*.*"
    local version="$(git --version)"
    if [[ $version =~ $expr ]]; then
        local major="${BASH_REMATCH[1]}"
        local minor="${BASH_REMATCH[2]}"
        if (( $major < 2 )) || (( $minor < 23 )); then
            echo "Requires git version 2.23 or greater (installed: $version)"
        fi
    # else
    #     # TODO something went wrong?
    fi
}

# Current Repo -----------------------------------------------------------------

# Returns the path to the root of this git repo
git_repo_root() {
    git rev-parse --show-toplevel
}

# Returns the name of the current branch
git_current_branch() {
    git symbolic-ref --short HEAD
}

# Framework Checks -------------------------------------------------------------

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

