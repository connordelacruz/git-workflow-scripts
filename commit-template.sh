#!/usr/bin/env bash
set -o errexit
# ==============================================================================
# commit-template.sh
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
# ------------------------------------------------------------------------------
# Creates and configures a git commit template for the current branch that
# includes a ticket number in brackets before the commit message. E.g. for
# ticket number 12345:
#
#   [#12345] <commit message text goes here>
#
# Usage: commit-template.sh [<ticket number>]
#
# If not arguments are passed, user will be prompted for the ticket number.
#
# ------------------------------------------------------------------------------
# Remove local template
# ------------------------------------------------------------------------------
# Use unset-commit-template.sh to quickly unset local commit.template config
# and remove template file.
#
# (See comments in unset-commit-template.sh for more information)
#
# ------------------------------------------------------------------------------
# Generated template files
# ------------------------------------------------------------------------------
# Templates generated with this script are created in the root of the git
# repository with this name format:
#
#   .gitmessage_local_<ticket>
#
# Where <ticket> is the ticket number used in the template.
#
# ------------------------------------------------------------------------------
# Configure git to ignore generated template files
# ------------------------------------------------------------------------------
# FOR INDIVIDUAL REPO:
#
# To ignore generated templates in a single repository, add the following to
# the .gitignore:
#
#   # Commit message templates
#   .gitmessage_local*
#
# FOR ALL REPOS (RECOMMENDED):
#
# To have git always ignore generated templates,
#
#   1. Create a global gitignore file, e.g. ~/.gitignore_global
#   2. Set the global git config for core.excludesfile to the path to the
#      global gitignore, e.g.:
#
#      git config --global core.excludesfile ~/.gitignore_global
#
#   3. Add the following to your global gitignore:
#
#      .gitmessage_local*
#
# For more information on core.excludesfile:
# https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration#_core_excludesfile
# ==============================================================================

# Imports ----------------------------------------------------------------------
readonly UTIL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/util"
source "$UTIL_DIR/output.sh"
source "$UTIL_DIR/git.sh"

# Constants --------------------------------------------------------------------
# Name of local commit.template file
readonly LOCAL_COMMIT_TEMPLATE_FILE='.gitmessage_local'

# Functions --------------------------------------------------------------------

# Sanitize and format input for ticket number.
# Removes any non-numeric characters.
#
# Arguments:
#   Text to sanitize and format
# Outputs:
#   Formatted text
fmt_ticket_number() {
    # Remove all non-numeric characters
    local formatted="${1//[^0-9]}"
    echo "$formatted"
}

# Configure commit template for a specified branch (requires git 2.23+)
#
# Arguments:
#   Commit template file name
#   Name of the branch to configure template for
git_set_branch_template() {
    local commit_template_file="$1"
    local branch_name="$2"
    # Add 'config_' prefix and remove any slashes for filename
    local config_file_name="config_${branch_name//[\/]/}"
    # Create this branch's config file and set commit template
    echo "Creating git config for branch $branch_name..."
    git config -f .git/${config_file_name} commit.template "$commit_template_file"
    success "Config created:" \
            "$(pwd)/.git/$config_file_name"
    echo "Configuring local repo..."
    git config --local includeIf.onbranch:${branch_name}.path "$config_file_name"
    success "Local repo configured." \
            "Will include configs from .git/$config_file_name" \
            "when on branch $branch_name."
}

# Main -------------------------------------------------------------------------

# Prompts the user for a ticket number, validates and sanitizes input,
# then creates a commit template with the ticket number and configures
# the local git repo to use that template.
#
# Arguments:
#   (Optional) Ticket number, will be prompted if not provided or invalid
main() {
    # Check git version > 2.23 and that we're in a repo currently
    local version_check="$(verify_git_version)"
    [[ -n "$version_check" ]] && error "$version_check" && exit 1
    verify_git_repo

    local ticket
    # If a positional argument was provided, try using it as the ticket number
    if [[ $# > 0 ]]; then
        ticket="$(fmt_ticket_number "$1")"
    fi
    # If $ticket is empty, prompt for ticket number
    while [[ -z "$ticket" ]]; do
        echo "Enter ticket number to use in commit messages."
        read -p "$(prompt "Ticket Number")" ticket
        ticket="$(fmt_ticket_number "$ticket")"
        [[ -n "$ticket" ]] && echo "" && break
        # Loop if improperly formatted
        error "Enter a valid ticket number."
    done

    # Create template
    local current_dir="$(pwd)"
    local repo_root_dir="$(git_repo_root)"
    local commit_template_file="${LOCAL_COMMIT_TEMPLATE_FILE}_${ticket}"
    echo "Creating commit template file..."
    cd "$repo_root_dir"
    echo "[#$ticket] " > "$commit_template_file"
    if [[ ! -f "$commit_template_file" ]]; then
        error "Something went wrong when attempting to create commit template."
        exit 1
    else
        success "Template file created:" \
                "$(pwd)/$commit_template_file"
    fi
    # Configure commit template
    local project_branch="$(git_current_branch)"
    git_set_branch_template "$commit_template_file" "$project_branch"
    # Return to previous directory before exiting
    cd "$current_dir"
}
main "$@"
