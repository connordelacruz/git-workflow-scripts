# Git Workflow Scripts

## TODO

- explain scripts
- environment variables w/ examples
- global gitignore example

## Setup

Clone this repo and update your `.bashrc` to include it in your `PATH`. E.g. if
you cloned it into `~/bin/scripts`:

```bash
export PATH="$HOME/bin/scripts:$PATH"
```

<!-- vim-markdown-toc GFM -->

* [Scripts](#scripts)
    * [new-branch.sh](#new-branchsh)
        * [Environment Variables](#environment-variables)
        * [Optional Arguments](#optional-arguments)

<!-- vim-markdown-toc -->

# Scripts

## new-branch.sh

Create a new git branch with the following name format:

```
[<client>-]<brief-description>-<yyyymmdd>-<initials>
```

Where:
  `<client>` - (Optional) Client's name
  `<brief-description>` - Description of the work
  `<yyyymmdd>` - Today's date
  `<initials>` - Engineer's initials

Script will prompt for details and format appropriately (i.e. no
spaces/underscores, all lowercase).

### Environment Variables

Script will use the following environment variables if set:

- `INITIALS`: Skip the prompt for user's initials and use the value of this.
  E.g. to automatically use "cd":

    ```bash
    export INITIALS=cd
    ```

- `GIT_BASE_BRANCH`: Use instead of `master` as the base git branch when
  creating the new branch. E.g. to base branches off `develop`:

    ```bash
    export GIT_BASE_BRANCH=develop    
    ```

- `GIT_BAD_BRANCH_NAMES`: Set to a **space-separated string** of patterns that
  should not appear in a branch name. Script will check for these before
  attempting to create a branch. E.g. if branch names shouldn't include the
  words `-web` or `-plugins`:

    ```bash
    export GIT_BAD_BRANCH_NAMES="-web -plugins"
    ```

### Optional Arguments

This script accepts optional arguments to skip input prompts and override
defaults and environment variables. Running `new-branch.sh -h` will display
details on these arguments:

```
Usage: new-branch.sh [-c <client>|-C] [-d <description>] [-i <initials>]
                     [-b <base-branch>] [-t <yyyymmdd>] [-P] [-N] [-h]
Options:
  -c <client>       Specify client name.
  -C                No client name (overrides -c).
  -d <description>  Specify branch description.
  -i <initials>     Specify developer initials.
  -b <base-branch>  Specify branch to use as base (default: master).
  -t <yyyymmdd>     Specify timestamp (default: current date).
  -P                Skip pulling changes to base branch.
  -N                Skip check for bad branch names.
  -h                Show this help message and exit.
```
