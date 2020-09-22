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
# Format of commit template body. Placeholders:
#   %%ticket%% - Replaced with ticket number
# (Default: "[%%ticket%%] ")
readonly COMMIT_TEMPLATE_FORMAT="$(git_config_default workflow.commitTemplateFormat "[%%ticket%%] ")"
# Regex used to validate ticket number format.
# (Default: '[a-zA-Z]+-[0-9]+')
readonly TICKET_NUMBER_FORMAT_REGEX="$(git_config_default workflow.ticketNumberFormatRegex '[a-zA-Z]+-[0-9]+')"
