# ==============================================================================
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
#
# Load git configs into variables.
# ==============================================================================

# Return git config value w/ optional default if unset
#
# Usage: git_config_default <config.variable> [<default value>]
git_config_default() {
    local config="$1"
    local default="$2"
    echo "$(git config --default "$default" --get "$config")"
}

# User Details -----------------------------------------------------------------
# User initials
readonly INITIALS="$(git_config_default workflow.initials)"

# Branches ---------------------------------------------------------------------
# Base branch
# (DEFAULT: master)
readonly BASE_BRANCH="$(git_config_default workflow.baseBranch master)"
# Space-separated list of words that should not appear in a branch name
readonly BAD_BRANCH_NAME_PATTERNS="$(git_config_default workflow.badBranchNamePatterns)"

# Commit Templates -------------------------------------------------------------
# If > 0, enable workflow-commit-template integration with workflow-branch
# (DEFAULT: 1)
readonly COMMIT_TEMPLATE="$(git_config_default workflow.enableCommitTemplate 1)"
# Format of commit template body. Placeholders:
#   %%ticket%% - Replaced with ticket number
# (DEFAULT: "[%%ticket%%] ")
readonly COMMIT_TEMPLATE_FORMAT="$(git_config_default workflow.commitTemplateFormat "[%%ticket%%] ")"

# Ticket Numbers ---------------------------------------------------------------
# Regex used to validate ticket number format.
# (DEFAULT: '[a-zA-Z]+-[0-9]+')
readonly TICKET_INPUT_FORMAT_REGEX="$(git_config_default workflow.ticketInputFormatRegex '[a-zA-Z]+-[0-9]+')"
# If > 0, lowercase letters in ticket will be capitalized in result.
# (DEFAULT: 1)
readonly TICKET_FORMAT_CAPITALIZE="$(git_config_default workflow.ticketFormatCapitalize 1)"
