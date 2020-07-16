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

# Verify that this is a git repo.
#
# Calls git status silently. Any error will be printed to STDERR and the script
# will exit.
verify_git_repo() {
    git status 1> /dev/null
}

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

# Returns the path to the root of this git repo
git_repo_root() {
    git rev-parse --show-toplevel
}

# Returns the name of the current branch
git_current_branch() {
    git symbolic-ref --short HEAD
}

# TODO local fallback?
# Configure commit template for local repo
#
# Arguments:
#   Commit template file name
# git_set_local_template() {
#     local commit_template_file="$1"
#     git config --local commit.template "$commit_template_file"
# }

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
    git config -f .git/${config_file_name} commit.template "$commit_template_file"
    # Include the above file for the project branch
    git config --local includeIf.onbranch:${branch_name}.path "$config_file_name"
}

# Prompt -----------------------------------------------------------------------

# Prompts the user for a ticket number, validates and sanitizes input,
# then creates a commit template with the ticket number and configures
# the local git repo to use that template.
#
# Arguments:
#   (Optional) Ticket number, will be prompted if not provided or invalid
main() {
    # Check git version > 2.23 and that we're in a repo currently
    verify_git_version
    verify_git_repo

    local ticket
    # If a positional argument was provided, try using it as the ticket number
    if [[ $# > 0 ]]; then
        ticket="$(fmt_ticket_number "$1")"
    fi
    # If $ticket is empty, prompt for ticket number
    while [[ -z "$ticket" ]]; do
        read -p "Ticket number: " ticket
        # Sanitize and verify not empty
        ticket="$(fmt_ticket_number "$ticket")"
        [[ -n "$ticket" ]] && break
        # Loop if improperly formatted
        echo "Error: enter a valid ticket number."
    done

    # Create template
    local current_dir="$(pwd)"
    local repo_root_dir="$(git_repo_root)"
    # Append ticket number to filename on the off-chance a file
    # .gitmessage_local already exists
    local commit_template_file="${LOCAL_COMMIT_TEMPLATE_FILE}_${ticket}"
    echo "Creating commit template file..."
    # Go to root of current repo
    cd "$repo_root_dir"
    echo "[#$ticket] " > "$commit_template_file"
    # Verify that file was created
    if [[ ! -f "$commit_template_file" ]]; then
        echo "Error: something went wrong when attempting to create commit template."
        exit 1
    else
        echo "Template file created:"
        echo "$(pwd)/$commit_template_file"
    fi

    # Configure commit template
    local project_branch="$(git_current_branch)"
    # TODO local fallback?
    #  git_set_local_template "$commit_template_file"
    # echo "Configuring commit.template for this repo..."
    echo "Configuring commit.template for branch $project_branch..."
    git_set_branch_template "$commit_template_file" "$project_branch"
    echo "Template configured."

    # Return to previous directory before exiting
    cd "$current_dir"
}

# Run main, pass any command line options to it for parsing
main "$@"

