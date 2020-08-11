# ==============================================================================
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
#
# Load git configs into variables.
# ==============================================================================

# Functions --------------------------------------------------------------------

# Return git config value w/ optional default if unset
#
# Usage: git_config_default <config.variable> [<default value>]
git_config_default() {
    local config="$1"
    local default="$2"
    local res="$(git config --get "$config")"
    echo "${res:-$default}"
}

# Globals ----------------------------------------------------------------------

# User initials
readonly INITIALS="$(git_config_default workflow.initials)"
# Base branch
# (DEFAULT: master)
readonly BASE_BRANCH="$(git_config_default workflow.baseBranch master)"
# Space-separated list of words that should not appear in a branch name
readonly BAD_BRANCH_NAME_PATTERNS="$(git_config_default workflow.badBranchNamePatterns)"
# If > 0, enable commit-template.sh integration with new-branch.sh
# (DEFAULT: 1)
readonly COMMIT_TEMPLATE="$(git_config_default workflow.enableCommitTemplate 1)"

