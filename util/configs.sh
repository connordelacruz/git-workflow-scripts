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
    echo "$(git config --default "$default" --get "$config")"
}

# Globals ----------------------------------------------------------------------

# User initials
readonly INITIALS="$(git_config_default workflow.initials)"
# Base branch
# (DEFAULT: master)
readonly BASE_BRANCH="$(git_config_default workflow.baseBranch master)"
# Space-separated list of words that should not appear in a branch name
readonly BAD_BRANCH_NAME_PATTERNS="$(git_config_default workflow.badBranchNamePatterns)"
# If > 0, enable workflow-commit-template integration with workflow-branch
# (DEFAULT: 1)
readonly COMMIT_TEMPLATE="$(git_config_default workflow.enableCommitTemplate 1)"

