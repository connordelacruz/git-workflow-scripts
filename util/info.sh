# ==============================================================================
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
# ------------------------------------------------------------------------------
# Project Info
# ==============================================================================

readonly WORKFLOW_MAJOR=1
readonly WORKFLOW_MINOR=1
readonly WORKFLOW_PATCH=0
readonly WORKFLOW_VERSION="$WORKFLOW_MAJOR.$WORKFLOW_MINOR.$WORKFLOW_PATCH"

show_version() {
    echo "git-workflow-scripts $WORKFLOW_VERSION"
}

show_version_and_exit() {
    show_version
    exit
}

