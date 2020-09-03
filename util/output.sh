# ==============================================================================
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
#
# Helpers for output formatting
# ==============================================================================

# Constants --------------------------------------------------------------------
# Text Colors
readonly FG_RED="$(tput setaf 1)"
readonly FG_GREEN="$(tput setaf 2)"
readonly FG_YELLOW="$(tput setaf 3)"
readonly FG_MAGENTA="$(tput setaf 5)"
readonly FG_CYAN="$(tput setaf 6)"
# Formatting
readonly TXT_BOLD="$(tput bold)"
readonly TXT_RESET="$(tput sgr0)"
# Misc
readonly INDENT="    "

# Print Functions --------------------------------------------------------------

echo_indented() {
    for line in "$@"; do
        echo "${INDENT}${line}"
    done
}

echo_error() {
    echo "${TXT_BOLD}${FG_RED}Error: ${1}${TXT_RESET}"
    if [[ $# > 1 ]]; then
        shift
        for line in "$@"; do
            echo "${INDENT}${FG_RED}${line}${TXT_RESET}"
        done
    fi
}

echo_warning() {
    echo "${FG_YELLOW}Warning: ${1}${TXT_RESET}"
    if [[ $# > 1 ]]; then
        shift
        for line in "$@"; do
            echo "${INDENT}${FG_YELLOW}${line}${TXT_RESET}"
        done
    fi
}

echo_success() {
    echo "${FG_GREEN}${1}${TXT_RESET}"
    if [[ $# > 1 ]]; then
        shift
        for line in "$@"; do
            echo "${INDENT}${FG_GREEN}${line}${TXT_RESET}"
        done
    fi
}

echo_info() {
    echo "${FG_CYAN}Info: ${1}${TXT_RESET}"
    if [[ $# > 1 ]]; then
        shift
        for line in "$@"; do
            echo "${INDENT}${FG_CYAN}${line}${TXT_RESET}"
        done
    fi
}

echo_prompt() {
    echo "${FG_MAGENTA}> ${1}: ${TXT_RESET}"
}

