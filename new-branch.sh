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
# TODO explain name format and args when implemented
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
main() {
    local client desc ts branch_name
    # TODO: move each input prompt to its own helper?
    # 1. Client
    read -p "(Optional) Client name: " client
    client="$(fmt_text "$client")"
    # Append hyphen if not blank
    [[ $client != '' ]] && client="$client-"
    # [ -n "$client" ] && client="$client-"

    # 2. Description
    while true; do
        read -p "Brief description of ticket: " desc
        # Sanitize and verify not empty
        desc="$(fmt_text "$desc")"
        [[ $desc != '' ]] && break
        # [ -n "$desc" ] && break
        # Loop if improperly formatted
        echo "Error: description must not be blank."
    done

    # 3. Date
    ts="$(date "$DATE_FMT")"

    # 4. Initials
    # TODO: configure via environment var or something, skip if set
    while true; do
        read -p "Initials: " initials
        # Sanitize and verify not empty
        initials="$(fmt_text "$initials")"
        [[ $initials != '' ]] && break
        # [ -n "$initials" ] && break
        # Loop if improperly formatted
        echo "Error: must enter initials."
    done

    branch_name="$client$desc-$ts-$initials"

    # TODO DEBUGGING
    echo "BRANCH: $branch_name"

    # TODO: git checkout master && git pull
    # TODO: git checkout -b [<client>-]<brief-description>-<yyyymmdd>-<initials>
}

main

