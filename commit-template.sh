#!/usr/bin/env bash
set -o errexit
# ==============================================================================
# commit-template.sh
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
#
# TODO DOCUMENT
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

# Prompt -----------------------------------------------------------------------

# Prompts the user for a ticket number, validates and sanitizes input,
# then creates a commit template with the ticket number and configures
# the local git repo to use that template.
#
# Arguments:
# TODO
main() {
    # Check that this is a git repo
    verify_git_repo

    # TODO take ticket number as argument
    local ticket
    while [[ -z "$ticket" ]]; do
        read -p "Ticket number: " ticket
        # Sanitize and verify not empty
        ticket="$(fmt_ticket_number "$ticket")"
        [[ -n "$ticket" ]] && break
        # Loop if improperly formatted
        echo "Error: enter a valid ticket number."
    done

    # Create template
    # TODO (unless already exists or -f specified)
    # Go to root of current repo
    local current_dir="$(pwd)"
    local repo_root_dir="$(git rev-parse --show-toplevel)"
    cd "$repo_root_dir"
    echo "Creating commit template file..."
    echo "[#$ticket] " > "$LOCAL_COMMIT_TEMPLATE_FILE"
    # Verify that file was created
    if [[ ! -f "$LOCAL_COMMIT_TEMPLATE_FILE" ]]; then
        echo "Error: something went wrong when attempting to create commit template."
        exit 1
    else
        echo "Template file created:"
        echo "$(pwd)/$LOCAL_COMMIT_TEMPLATE_FILE"
    fi

    # Configure commit template
    # TODO unless flag to skip configuration was specified?
    echo "Configuring commit.template for this repo..."
    git config --local commit.template "$LOCAL_COMMIT_TEMPLATE_FILE"
    # TODO verify?
    echo "Template configured."

    # Return to previous directory before exiting
    cd "$current_dir"

    # TODO Flag for cleaning up and un-configuring template?
}

# Run main, pass any command line options to it for parsing
main "$@"

