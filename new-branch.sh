#!/usr/bin/env bash
set -o errexit
# ==============================================================================
# new-branch.sh
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
# ------------------------------------------------------------------------------
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
# spaces/underscores, all lowercase).
#
# ------------------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------------------
# Script will use the following environment variables if set:
#
#   - INITIALS: Skip the prompt for user's initials and use the value of this.
#     E.g. to automatically use "cd":
#
#       export INITIALS=cd
#
#   - GIT_BASE_BRANCH: Use instead of master as the base git branch when
#     creating the new branch. E.g. to base branches off develop:
#
#       export GIT_BASE_BRANCH=develop
#
#   - GIT_BAD_BRANCH_NAMES: Set to a **space-separated string** of patterns
#     that should not appear in a branch name. Script will check for these
#     before attempting to create a branch. E.g. if branch names shouldn't
#     include the words "-web" or "-plugins":
#
#       export GIT_BAD_BRANCH_NAMES="-web -plugins"
#
#   - NEW_BRANCH_COMMIT_TEMPLATE: By default, script will prompt for an
#     optional ticket number and create a commit message template with it (see
#     commit-template.sh). Set this to 0 to disable the ticket number prompt.
#
# ------------------------------------------------------------------------------
# Optional Arguments
# ------------------------------------------------------------------------------
# This script accepts optional arguments to skip input prompts and override
# defaults and environment variables. Running new-branch.sh -h will display
# details on these arguments:
#
# Usage: new-branch.sh [-c <client>|-C] [-d <description>] [-i <initials>]
#                      [-b <base-branch>] [-t <yyyymmdd>] [-s <ticket#>|-S]
#                      [-P] [-N] [-h]
# Options:
#   -c <client>       Specify client name.
#   -C                No client name (overrides -c).
#   -d <description>  Specify branch description.
#   -i <initials>     Specify developer initials.
#   -b <base-branch>  Specify branch to use as base (default: master).
#   -t <yyyymmdd>     Specify timestamp (default: current date).
#   -s <ticket#>      Specify ticket number (will create commit template).
#   -S                No commit message template (overrides -s).
#   -P                Skip pulling changes to base branch.
#   -N                Skip check for bad branch names.
#   -h                Show this help message and exit.
#
# ==============================================================================

# Imports ----------------------------------------------------------------------
readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly UTIL_DIR="$SCRIPT_DIR/util"
source "$UTIL_DIR/output.sh"
source "$UTIL_DIR/git.sh"

# Constants --------------------------------------------------------------------

# Format for the date string (yyyymmdd)
readonly DATE_FMT="+%Y%m%d"
# Default base branch (master if $GIT_BASE_BRANCH not configured)
readonly BASE_BRANCH="${GIT_BASE_BRANCH:-master}"
# If NEW_BRANCH_COMMIT_TEMPLATE is unset, default to enabling feature
readonly COMMIT_TEMPLATE="${NEW_BRANCH_COMMIT_TEMPLATE:-1}"

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

# Takes branch name and a space-separated list of invalid patterns for branch.
# If one of the patterns is found, show error message and exit.
#
# Arguments:
#   Name of the branch to check
#   Space-separated string of invalid patterns to check for
bad_branch_name_check() {
    local branch_name="$1"
    local bad_pattern_list
    # Environment variables can't be set to arrays, so expect a space-separated
    # string and parse it as an array
    declare -a "bad_pattern_list=($2)"
    for pattern in "${bad_pattern_list[@]}"; do
        # Simple check for bad patterns in branch name
        if [[ "$branch_name" = *"$pattern"* ]]; then
            error "Branch name contains invalid pattern:" \
                "Desired Branch Name: $branch_name" \
                "Contains Invalid Pattern: $pattern" \
                "" \
                "Branch names should not include the following patterns:" \
                "$( IFS=$'\n'; echo "${bad_pattern_list[@]}" )" \
                "" \
                "(Configured in environment variable GIT_BAD_BRANCH_NAMES)" \
                "" \
                "Use the -N argument to skip this check." \
                "For more information on arguments and environment variables, run:" \
                "  new-branch.sh -h"
            exit 1
        fi
    done
}

# Create a new branch based off the configured base branch.
#
# Switches to specified base branch (master if unspecified), pulls changes
# (unless 3rd argument is set to 1), then creates a new branch with the
# specified name.
#
# Arguments:
#   New branch name
#   (Default: master or $GIT_BASE_BRANCH) Base branch name
#   (Optional) Set to 1 to skip git pull on base branch
create_branch() {
    local branch_name="$1"
    local base_branch="${2:-$BASE_BRANCH}"
    local no_pull="$3"
    git checkout "$base_branch"
    if [[ $no_pull > 0 ]]; then
        info "-P argument was specified, not pulling updates to $base_branch."
    else
        echo "Pulling updates to $base_branch..."
        git pull
    fi
    echo "Creating new branch $branch_name..."
    git checkout -b "$branch_name"
}

# Display help message for script
show_help() {
    echo 'Usage: new-branch.sh [-c <client>|-C] [-d <description>] [-i <initials>]'
    echo '                     [-b <base-branch>] [-t <yyyymmdd>] [-s <ticket#>|-S]'
    echo '                     [-P] [-N] [-h]'
    echo 'Options:'
    echo '  -c <client>       Specify client name.'
    echo '  -C                No client name (overrides -c).'
    echo '  -d <description>  Specify branch description.'
    echo '  -i <initials>     Specify developer initials.'
    echo '  -b <base-branch>  Specify branch to use as base (default: master).'
    echo '  -t <yyyymmdd>     Specify timestamp (default: current date).'
    echo '  -s <ticket#>      Specify ticket number (will create commit template).'
    echo '  -S                No commit message template (overrides -s).'
    echo '  -P                Skip pulling changes to base branch.'
    echo '  -N                Skip check for bad branch names.'
    echo '  -h                Show this help message and exit.'
    echo ''
    echo 'Environment Variables:'
    echo '  INITIALS                    If set, skip prompt for developer initials'
    echo '                              and use the value of this. Override with -i.'
    echo '  GIT_BASE_BRANCH             If set, use this branch as a base instead of'
    echo '                              master. Override with -b.'
    echo '  GIT_BAD_BRANCH_NAMES        Set to a space-separated string of patterns that'
    echo '                              should not appear in a branch name. Script will'
    echo '                              check for these before creating a new branch.'
    echo '                              Skip bad name check with -N.'
    echo '  NEW_BRANCH_COMMIT_TEMPLATE  If set to 0, script will not prompt for ticket'
    echo '                              number and not create a commit message template.'
    echo '                              Override with -s.'
}

# Prompt -----------------------------------------------------------------------

# Prompts the user for info about the branch, validates and formats input, and
# creates the new branch.
#
# Globals:
#   INITIALS
#   GIT_BASE_BRANCH
#   GIT_BAD_BRANCH_NAMES
#   NEW_BRANCH_COMMIT_TEMPLATE
# Arguments:
#   Takes all optional arguments for script. For details on these arguments,
#   see show_help()
main() {
    # Parse arguments:
    # -c <client> OR -C (no client [overrides -c])
    # -d <description>
    # -i <initials> (OVERRIDE GLOBAL)
    # -b <base-branch> (OVERRIDE GLOBAL)
    # -t <yyyymmdd>
    # -P (don't pull base branch)
    # -N (skip bad name check)
    # -s <ticket#> OR -S (no commit template)
    local arg_client arg_no_client arg_desc arg_timestamp arg_init \
          arg_base_branch arg_no_pull arg_skip_name_check \
          arg_ticket arg_no_ticket
    while getopts 'c:d:i:b:t:PCNs:Sh' opt; do
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
            N)
                arg_skip_name_check=1
                ;;
            s)
                arg_ticket="$OPTARG"
                ;;
            S)
                arg_no_ticket=1
                ;;
            h|?)
                show_help
                [[ "$opt" = "?" ]] && local exit_code=1 || local exit_code=0
                exit $exit_code
                ;;
        esac
    done
    shift $((OPTIND -1))

    # Check that this is a git repo before proceeding
    verify_git_repo

    local client
    # Skip section if -C is passed
    if [[ $arg_no_client < 1 ]]; then
        # Use -c arg if specified and not blank after formatting
        if [[ -n "$arg_client" ]]; then
            client="$arg_client"
        # Otherwise prompt user
        else
            echo "(Optional) Enter the name of the affected client."
            read -p "$(prompt "Client")" client
            client="$(fmt_text "$client")"
        fi
    fi
    # Append hyphen if not blank
    [[ -n "$client" ]] && client="$client-"
    echo ""

    local desc
    # Use -d if specified and not blank after formatting
    if [[ -n "$arg_desc" ]]; then
        desc="$arg_desc"
    fi
    while [[ -z "$desc" ]]; do
        echo "Enter a brief description for the branch."
        read -p "$(prompt "Description")" desc
        # Sanitize and verify not empty
        desc="$(fmt_text "$desc")"
        [[ -n "$desc" ]] && break
        # Loop if improperly formatted
        error "Description must not be blank."
    done
    echo ""

    local initials
    # Use -i arg if specified and not blank after formatting
    if [[ -n "$arg_init" ]]; then
        initials="$arg_init"
    # Else use environment variable INITIALS if set
    elif [[ -n "$INITIALS" ]]; then
        initials="$(fmt_text "$INITIALS")"
        [[ -n "$initials" ]] && info "Initials configured in \$INITIALS: $initials"
    fi
    # If initials is empty by now, we need to prompt user for them
    while [[ -z "$initials" ]]; do
        echo "Enter your initials."
        read -p "$(prompt "Initials")" initials
        # Sanitize and verify not empty
        initials="$(fmt_text "$initials")"
        [[ -n "$initials" ]] && break
        # Loop if improperly formatted
        error "Must enter initials."
    done
    echo ""

    local ticket
    # Skip section if -S is passed
    if [[ $arg_no_ticket < 1 ]]; then
        # Use -s arg if specified
        if [[ -n "$arg_ticket" ]]; then
            ticket="$arg_ticket"
        # Otherwise prompt user (unless feature is disabled)
        elif [[  $COMMIT_TEMPLATE > 0 ]]; then
            echo "(Optional) Enter ticket number to use in commit messages."
            echo "Leave blank if you don't want to create a commit template."
            read -p "$(prompt "Ticket Number")" ticket
        fi
    fi
    echo ""

    # Timestamp
    local timestamp="${arg_timestamp:-$(date "$DATE_FMT")}"
    # Format branch name
    local branch_name="$client$desc-$timestamp-$initials"
    # Check for bad branch name
    if [[ -n "$GIT_BAD_BRANCH_NAMES" ]]; then
        # Skip if -N arg is provided
        if [[ -n "$arg_skip_name_check" ]]; then
            warning "GIT_BAD_BRANCH_NAMES is set but -N argument was specified." \
                "Skipping bad branch name check."
        else
            echo "Validating branch name..."
            bad_branch_name_check "$branch_name" "$GIT_BAD_BRANCH_NAMES"
            success "Branch name OK."
        fi
    fi

    # Create branch
    create_branch "$branch_name" "${arg_base_branch:-$BASE_BRANCH}" "$arg_no_pull"
    success "Branch created."

    # If specified, call commit-template.sh
    if [[ -n "$ticket" ]]; then
        "$SCRIPT_DIR/commit-template.sh" "$ticket"
    fi
}

# Run main, pass any command line options to it for parsing
main "$@"

