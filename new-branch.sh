#!/usr/bin/env bash
# ==============================================================================
# Create a new git branch with the following name format:
#
#   [<client>-]<brief-description>-<yyyymmdd>-<initials>
#
# Where:
#   <client> - (Optional) Client's name
#   <brief-description> - Description of the work
#   <yyyymmdd> - Today's date
#   <initials> - Engineer's initials
#
# Script will prompt for details and format appropriately (i.e. no
# spaces/underscores, all lowercase)
#
# If the environment variable $INITIALS is set, the value of that will be used
# for <initials> and the user will not be prompted to type them.
#
# TODO Add optional args and explain here when implemented
#
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
# ==============================================================================

# Constants --------------------------------------------------------------------

# Format for the date string (yyyymmdd)
readonly DATE_FMT="+%Y%m%d"

# Functions --------------------------------------------------------------------

# Sanitize and format input for use in branch name.
# Converts to lowercase, trims leading/trailing spaces, and replaces spaces and
# undderscores with hyphens.
#
# Arguments:
#   Text to sanitize and format
# Outputs:
#   Formatted text
fmt_text() {
    # to lower case
    local formatted="${1,,}"
    # Trim leading and trailing spaces
    formatted="${formatted##*( )}"
    formatted="${formatted%%*( )}"
    # replace spaces and underscores with hyphens
    formatted="${formatted//[ _]/-}"
    echo $formatted
}

# Prompt -----------------------------------------------------------------------

# Prompts the user for info about the branch, validates and formats input, and
# creates the new branch.
#
# Globals:
#   INITIALS
# Arguments:
#   None
main() {
    # Client
    read -p "(Optional) Client name: " client
    local client="$(fmt_text "$client")"
    # Append hyphen if not blank
    [[ $client != '' ]] && client="$client-"

    # Description
    while true; do
        read -p "Brief description of ticket: " desc
        # Sanitize and verify not empty
        local desc="$(fmt_text "$desc")"
        [[ $desc != '' ]] && break
        # Loop if improperly formatted
        echo "Error: description must not be blank."
    done

    # Initials
    local initials
    if [[ -z "$INITIALS" ]]; then
        while true; do
            read -p "Initials: " initials
            # Sanitize and verify not empty
            initials="$(fmt_text "$initials")"
            [[ $initials != '' ]] && break
            # Loop if improperly formatted
            echo "Error: must enter initials."
        done
    else
        initials="$(fmt_text "$INITIALS")"
        echo "Initials configured in \$INITIALS: $initials"
    fi

    # Format branch name
    local branch_name="$client$desc-$(date "$DATE_FMT")-$initials"
    # TODO DEBUGGING
    echo "BRANCH: $branch_name"

    # TODO: git checkout master && git pull
    # TODO: git checkout -b [<client>-]<brief-description>-<yyyymmdd>-<initials>
}

# Run main
main

