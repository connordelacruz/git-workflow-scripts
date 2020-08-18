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
# Usage
# ------------------------------------------------------------------------------
# Usage: new-branch.sh [-c <client>|-C] [-d <description>] [-i <initials>]
#                      [-b <base-branch>|-B] [-t <yyyymmdd>] [-s <ticket#>|-S]
#                      [-P] [-N] [-h]
#
# This script accepts optional arguments to skip input prompts and override
# defaults and git configurations. For details on optional arguments, run:
#
#       new-branch.sh -h
#
# If no optional arguments are provided, you will be prompted for information
# used in the branch name (client, description, etc).
#
# ------------------------------------------------------------------------------
# Configurations
# ------------------------------------------------------------------------------
# This script will use the following git configs if set:
#
#   - workflow.initials: Skip the prompt for user's initials and use the value
#     of this. E.g. to automatically use "cd":
#
#       git config --global workflow.initials cd
#
#   - workflow.baseBranch: Use instead of master as the base git branch when
#     creating the new branch. E.g. to base branches off develop:
#
#       git config workflow.baseBranch develop
#
#   - workflow.badBranchNamePatterns: Set to a space-separated string of
#     patterns that should not appear in a standard branch name. Script will
#     check for these before attempting to create a branch. E.g. if branch
#     names shouldn't include the words "-web" or "-plugins":
#
#       git config workflow.badBranchNamePatterns "-web -plugins"
#
#   - workflow.enableCommitTemplate: By default, script will prompt for an
#     optional ticket number and create a commit message template with it (see
#     commit-template.sh). Set this to 0 to disable the ticket number prompt.
#
# ==============================================================================

# Imports ----------------------------------------------------------------------
readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly UTIL_DIR="$SCRIPT_DIR/util"
source "$UTIL_DIR/ALL.sh"

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
    # Parse string as an array
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
                  "(From git config workflow.badBranchNamePatterns)" \
                  "" \
                  "Use the -N argument to skip this check."
            exit 1
        fi
    done
}

# Create a new branch based off the specified base branch.
#
# Switches to specified base branch, pulls changes (unless 3rd argument is set
# to 1), then creates a new branch with the specified name.
#
# Arguments:
#   New branch name
#   Base branch name
#   (Optional) Set to 1 to skip git pull on base branch
create_branch() {
    local branch_name="$1"
    local base_branch="$2"
    local no_pull="$3"
    git checkout "$base_branch"
    if [[ $no_pull > 0 ]]; then
        info "-P argument was specified, not pulling updates to $base_branch."
    elif [[ -n "$(git_upstream)" ]]; then
        echo "Pulling updates to $base_branch..."
        git pull
    fi
    echo "Creating new branch $branch_name..."
    git checkout -b "$branch_name"
}

show_help() {
    # TODO pull from configs for default vals?
    echo 'Usage: new-branch.sh [-c <client>|-C] [-d <description>] [-i <initials>]'
    echo '                     [-b <base-branch>|-B] [-t <yyyymmdd>] [-s <ticket#>|-S]'
    echo '                     [-P] [-N] [-h]'
    echo 'Options:'
    echo '  -c <client>       Specify client name.'
    echo '  -C                No client name (overrides -c).'
    echo '  -d <description>  Specify branch description.'
    echo '  -i <initials>     Specify developer initials.'
    echo '  -b <base-branch>  Specify branch to use as base (default: master).'
    echo '  -B                Use current branch as base (default: master).'
    echo '  -t <yyyymmdd>     Specify timestamp (default: current date).'
    echo '  -s <ticket#>      Specify ticket number (will create commit template).'
    echo '  -S                No commit message template (overrides -s).'
    echo '  -P                Skip pulling changes to base branch.'
    echo '  -N                Skip check for bad branch names.'
    echo '  -h                Show this help message and exit.'
}

# Main -------------------------------------------------------------------------

# Prompts the user for info about the branch, validates and formats input, and
# creates the new branch.
#
# Globals:
#   INITIALS
#   BASE_BRANCH
#   BAD_BRANCH_NAME_PATTERNS
#   NEW_BRANCH_COMMIT_TEMPLATE
# Arguments:
#   Takes all optional arguments for script. For details on these arguments,
#   see show_help()
main() {
    # Parse arguments:
    # -c <client> OR -C no client [overrides -c]
    # -d <description>
    # -i <initials> (OVERRIDE GLOBAL)
    # -b <base-branch> OR -B base off current branch (OVERRIDE GLOBAL)
    # -t <yyyymmdd>
    # -P don't pull base branch
    # -N skip bad name check
    # -s <ticket#> OR -S no commit template
    local arg_client arg_no_client arg_desc arg_timestamp arg_init \
          arg_base_branch arg_no_pull arg_skip_name_check \
          arg_ticket arg_no_ticket
    while getopts 'c:Cd:i:b:Bt:PNs:Sh' opt; do
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
            B)
                arg_base_branch="$(git_current_branch)"
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
    # Commit template requires git 2.23+
    local skip_commit_template
    if [[ -n "$(verify_git_version)" ]]; then
        skip_commit_template=1
    fi

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
            echo ""
        fi
    fi
    # Append hyphen if not blank
    [[ -n "$client" ]] && client="$client-"

    local desc
    # Use -d if specified and not blank after formatting
    if [[ -n "$arg_desc" ]]; then
        desc="$arg_desc"
    fi
    while [[ -z "$desc" ]]; do
        echo "Enter a brief description for the branch."
        read -p "$(prompt "Description")" desc
        desc="$(fmt_text "$desc")"
        [[ -n "$desc" ]] && echo"" && break
        # Loop if improperly formatted
        error "Description must not be blank."
    done

    local initials
    # Use -i arg if specified and not blank after formatting
    if [[ -n "$arg_init" ]]; then
        initials="$arg_init"
    # Else use config workflow.initials if set
    elif [[ -n "$INITIALS" ]]; then
        initials="$(fmt_text "$INITIALS")"
        [[ -n "$initials" ]] && info "Initials configured in workflow.initials: $initials" && echo ""
    fi
    # If initials is empty by now, we need to prompt user for them
    while [[ -z "$initials" ]]; do
        echo "Enter your initials."
        read -p "$(prompt "Initials")" initials
        initials="$(fmt_text "$initials")"
        [[ -n "$initials" ]] && echo "" && break
        # Loop if improperly formatted
        error "Must enter initials."
    done

    local ticket
    # Skip section if git version check failed or if -S is passed
    if [[ $skip_commit_template < 1 ]] && [[ $arg_no_ticket < 1 ]]; then
        # Use -s arg if specified
        if [[ -n "$arg_ticket" ]]; then
            ticket="$arg_ticket"
        # Otherwise prompt user (unless feature is disabled)
        elif [[  $COMMIT_TEMPLATE > 0 ]]; then
            echo "(Optional) Enter ticket number to use in commit messages."
            echo "Leave blank if you don't want to create a commit template."
            read -p "$(prompt "Ticket Number")" ticket
            echo ""
        fi
    fi

    local timestamp="${arg_timestamp:-$(date "+%Y%m%d")}"
    local branch_name="$client$desc-$timestamp-$initials"
    # Check for bad branch name
    if [[ -n "$BAD_BRANCH_NAME_PATTERNS" ]]; then
        # Skip if -N arg is provided
        if [[ -n "$arg_skip_name_check" ]]; then
            warning "workflow.badBranchNamePatterns is configured but -N argument was specified." \
                    "Skipping bad branch name check."
        else
            echo "Validating branch name..."
            bad_branch_name_check "$branch_name" "$BAD_BRANCH_NAME_PATTERNS"
            success "Branch name OK."
        fi
    fi
    create_branch "$branch_name" "${arg_base_branch:-$BASE_BRANCH}" "$arg_no_pull"
    success "Branch created."
    # If specified, call commit-template.sh
    if [[ -n "$ticket" ]]; then
        "$SCRIPT_DIR/commit-template.sh" "$ticket"
    fi
}
main "$@"
