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

# TODO Custom error message
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

# Current Repo -----------------------------------------------------------------

# Returns the path to the root of this git repo
git_repo_root() {
    git rev-parse --show-toplevel
}

# Returns the name of the current branch
git_current_branch() {
    git symbolic-ref --short HEAD
}

