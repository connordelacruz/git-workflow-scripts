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
# Switches to specified base branch (master if unspecified) and pulls changes.
# Then creates a new branch with the specified name.
#
# Globals:
#   GIT_BASE_BRANCH
# Arguments:
#   New branch name
#   (Default: master or $GIT_BASE_BRANCH) Base branch name
create_branch() {
    local branch_name="$1"
    local base_branch="${2:-$BASE_BRANCH}"
    # Checkout and update master
    echo "Pulling updates to $base_branch..."
    git checkout "$base_branch" > /dev/null 2>&1 && git pull
    echo "Creating new branch $branch_name..."
    git checkout -b "$branch_name"
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
    # Check that this is a git repo
    verify_git_repo

    local arg_client arg_no_client arg_desc arg_init arg_base_branch arg_no_pull
    # TODO: Take args:
    # -c <client> OR -C (no client [overrides -c])
    # -d <description>
    # -i <initials> (OVERRIDE GLOBAL)
    # -b <base-branch> (OVERRIDE GLOBAL)
    # -P (don't pull base branch)
    while getopts 'c:d:i:b:PC' opt; do
        case ${opt} in
            c)
                arg_client="$OPTARG"
                ;;
            C)
                arg_no_client=1
                ;;
            d)
                arg_desc=${OPTARG}
                ;;
            i)
                arg_init="$OPTARG"
                ;;
            b)
                arg_base_branch="$OPTARG"
                ;;
            P)
                arg_no_pull=1
                ;;
            ?)
                echo "TODO HELP MSG"
                exit 1
                ;;
        esac
    done
    shift $((OPTIND -1))

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
    create_branch "$branch_name"
}

# Run main, pass any command line options to it for parsing
main "$@"

