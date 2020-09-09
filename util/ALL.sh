# ==============================================================================
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
# ------------------------------------------------------------------------------
# Sources all utility scripts. Add to top of script to include:
#
# readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# readonly UTIL_DIR="$SCRIPT_DIR/util"
# source "$UTIL_DIR/ALL.sh"
#
# ==============================================================================

# Project info
source "$UTIL_DIR/info.sh"
# Workflow script paths
source "$UTIL_DIR/scripts.sh"
# Configs
source "$UTIL_DIR/configs.sh"
# Output formatting
source "$UTIL_DIR/output.sh"
# Git utilities
source "$UTIL_DIR/git.sh"
# Initialize workflow
source "$UTIL_DIR/init.sh"
