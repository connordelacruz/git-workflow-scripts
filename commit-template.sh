#!/usr/bin/env bash
set -o errexit
# ==============================================================================
# commit-template.sh
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
#
# TODO DOCUMENT:
#   - usage
#   - adding .gitmessage_local* to global gitignore
#   - see unset-commit-template.sh
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

# Returns the path to the root of this git repo
git_repo_root() {
    git rev-parse --show-toplevel
}

# Prompt -----------------------------------------------------------------------

# Prompts the user for a ticket number, validates and sanitizes input,
# then creates a commit template with the ticket number and configures
# the local git repo to use that template.
#
# Arguments:
#   (Optional) Ticket number, will be prompted if not provided or invalid
main() {
    # Check that this is a git repo
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
    echo "Configuring commit.template for this repo..."
    git config --local commit.template "$commit_template_file"
    echo "Template configured."

    # Return to previous directory before exiting
    cd "$current_dir"
}

# Run main, pass any command line options to it for parsing
main "$@"

