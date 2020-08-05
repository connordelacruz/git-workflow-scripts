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
readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly UTIL_DIR="$SCRIPT_DIR/util"
source "$UTIL_DIR/output.sh"
source "$UTIL_DIR/git.sh"

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

    local repo_root_dir="$(git_repo_root)"
    # Initialize repo if not already
    if [[ "$(is_workflow_configured "$repo_root_dir")" < 1 ]]; then
        echo "Repo hasn't been initialized. Running workflow-init.sh..."
        "$SCRIPT_DIR/workflow-init.sh"
    fi
    local workflow_config_path="$repo_root_dir/.git/config_workflow"
    local commit_template_file=".gitmessage_local_${ticket}"
    local commit_template_path="$repo_root_dir/$commit_template_file"
    local branch_name="$(git_current_branch)"

    echo "Creating commit template file..."
    echo "[#$ticket] " > "$commit_template_path"
    if [[ ! -f "$commit_template_path" ]]; then
        error "Something went wrong when attempting to create commit template."
        exit 1
    else
        success "Template file created:" \
                "$commit_template_path"
    fi

    # Add 'config_' prefix and remove any slashes for filename
    local branch_config_file="config_${branch_name//[\/]/}"
    local branch_config_path="$repo_root_dir/.git/$branch_config_file"
    echo "Creating git config for branch $branch_name..."
    git config -f "$branch_config_path" commit.template "$commit_template_file"
    success "Config created:" \
            "$branch_config_path"
    echo "Configuring local repo..."
    git config -f "$workflow_config_path" includeIf.onbranch:${branch_name}.path "$branch_config_file"
    success "Local repo configured." \
            "Will include configs from .git/$branch_config_file" \
            "when on branch $branch_name."
}
main "$@"
