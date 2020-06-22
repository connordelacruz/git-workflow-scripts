#!/usr/bin/env bash
set -o errexit
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
# The will use the following environment variables if set:
#   INITIALS - Skip the prompt for user's initials and use the value of this
#   GIT_BASE_BRANCH - Use instead of master as the base git branch
#
# TODO Add optional args and explain here when implemented
#
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
# ==============================================================================

# TODO: consistent use of quotes, -z/-n vs = ''

# Constants --------------------------------------------------------------------

# Format for the date string (yyyymmdd)
readonly DATE_FMT="+%Y%m%d"
# Default base branch (master if $GIT_BASE_BRANCH not configured)
readonly BASE_BRANCH="${GIT_BASE_BRANCH:-master}"

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
    echo "$formatted"
}

# Verify that this is a git repo.
#
# Calls git status silently. Any error will be printed to STDERR and the script
# will exit.
verify_git_repo() {
    git status 1> /dev/null
}

# Create a new branch based off the configured base branch.
#
# Switches to specified base branch (master if unspecified), pulls changes
# (unless 3rd argument is set to 1), then creates a new branch with the
# specified name.
#
# Globals:
#   GIT_BASE_BRANCH
# Arguments:
#   New branch name
#   (Default: master or $GIT_BASE_BRANCH) Base branch name
#   (Optional) Set to 1 to skip git pull on base branch
create_branch() {
    local branch_name="$1"
    local base_branch="${2:-$BASE_BRANCH}"
    local no_pull="$3"
    git checkout "$base_branch"
    if [[ "$no_pull" > 0 ]]; then
        echo "(Skipped pulling updates to $base_branch)"
    else
        echo "Pulling updates to $base_branch..."
        git pull
    fi
    echo "Creating new branch $branch_name..."
    git checkout -b "$branch_name"
}

# Prompt -----------------------------------------------------------------------

# Prompts the user for info about the branch, validates and formats input, and
# creates the new branch.
#
# Globals:
#   INITIALS
# TODO update args doc
# Arguments:
#   None
main() {
    # Check that this is a git repo
    verify_git_repo

    local arg_client arg_no_client arg_desc arg_init arg_base_branch arg_timestamp arg_no_pull
    # TODO: Take args:
    # -c <client> OR -C (no client [overrides -c])
    # -d <description>
    # -i <initials> (OVERRIDE GLOBAL)
    # -b <base-branch> (OVERRIDE GLOBAL)
    # -t <yyyymmdd>
    # -P (don't pull base branch)
    while getopts 'c:d:i:b:t:PC' opt; do
        case ${opt} in
            c)
                arg_client="$(fmt_text "$OPTARG")"
                ;;
            C)
                arg_no_client=1
                ;;
            d)
                arg_desc="$(fmt_text "$OPTARG")"
                ;;
            i)
                arg_init="$(fmt_text "$OPTARG")"
                ;;
            b)
                arg_base_branch="$OPTARG"
                ;;
            t)
                arg_timestamp="$OPTARG"
                ;;
            P)
                arg_no_pull=1
                ;;
            ?)
                # TODO help message
                echo "TODO HELP MSG"
                exit 1
                ;;
        esac
    done
    shift $((OPTIND -1))

    # Client
    local client
    # Skip section if -C is passed
    if [[ $arg_no_client < 1 ]]; then
        # Use -c arg if specified and not blank after formatting
        if [[ -n "$arg_client" ]]; then
            client="$arg_client"
        # Otherwise prompt user
        else
            read -p "(Optional) Client name: " client
            client="$(fmt_text "$client")"
        fi
    fi
    # Append hyphen if not blank
    [[ $client != '' ]] && client="$client-"

    # Description
    local desc
    # Use -d if specified and not blank after formatting
    if [[ -n "$arg_desc" ]]; then
        desc="$arg_desc"
    fi
    while [[ $desc = '' ]]; do
        read -p "Brief description of ticket: " desc
        # Sanitize and verify not empty
        desc="$(fmt_text "$desc")"
        [[ $desc != '' ]] && break
        # Loop if improperly formatted
        echo "Error: description must not be blank."
    done

    # Initials
    local initials
    # Use -i arg if specified and not blank after formatting
    if [[ -n "$arg_init" ]]; then
        initials="$arg_init"
    # Else use environment variable INITIALS if set
    elif [[ -n "$INITIALS" ]]; then
        initials="$(fmt_text "$INITIALS")"
        [[ "$initials" != '' ]] && echo "Initials configured in \$INITIALS: $initials"
    fi
    # If initials is empty by now, we need to prompt user for them
    while [[ $initials = '' ]]; do
        read -p "Initials: " initials
        # Sanitize and verify not empty
        initials="$(fmt_text "$initials")"
        [[ $initials != '' ]] && break
        # Loop if improperly formatted
        echo "Error: must enter initials."
    done

    # Timestamp
    local timestamp="${arg_timestamp:-$(date "$DATE_FMT")}"
    # Format branch name
    local branch_name="$client$desc-$timestamp-$initials"
    # Create branch
    create_branch "$branch_name" "${arg_base_branch:-$BASE_BRANCH}" "$arg_no_pull"
}

# Run main, pass any command line options to it for parsing
main "$@"

