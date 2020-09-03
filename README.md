# Git Workflow Scripts

## Overview

**TODO: walk thru workflow**

### Create a New Branch with Commit Template

![workflow-branch demo](../assets/0-new-branch.gif?raw=true)

### Commits Will Include Ticket Number

![workflow-commit-template demo](../assets/1-commit-template.gif?raw=true)

### Use `workflow-unset-commit-template` to Remove Commit Template

![workflow-unset-commit-template demo](../assets/2-unset-template.gif?raw=true)

### Commit Templates are Configured Separately for Each Branch

![multiple branch demo](../assets/3-multi-branch.gif?raw=true)


## Setup

### Prerequisites

These scripts use features that require **git 2.23 or greater**. To install an
updated version of `git` on macOS using [Homebrew](https://brew.sh/):

```
brew install git
```

Make sure `/usr/local/bin` is added to your `PATH` e.g.:

```
export PATH="/usr/local/bin:$PATH"
```


### Installation

Clone this repo and update your `.bashrc` to include it in your `PATH`. E.g. if
you cloned it into `~/bin/git-workflow-scripts`:

```bash
export PATH="$HOME/bin/git-workflow-scripts:$PATH"
```


# Scripts

<!-- vim-markdown-toc GFM -->

* [`workflow-branch`](#workflow-branch)
    * [Usage](#usage)
    * [Configurations](#configurations)
* [`workflow-commit-template`](#workflow-commit-template)
    * [Usage](#usage-1)
        * [Remove and unconfigure local template](#remove-and-unconfigure-local-template)
    * [Configuring Git](#configuring-git)
        * [Configure git to ignore generated template files](#configure-git-to-ignore-generated-template-files)
            * [For individal repo:](#for-individal-repo)
            * [For all repos (RECOMMENDED):](#for-all-repos-recommended)
* [`workflow-unset-commit-template`](#workflow-unset-commit-template)
    * [Usage](#usage-2)
* [`workflow-finish-branch`](#workflow-finish-branch)
    * [Usage](#usage-3)
* [`workflow-tidy-up`](#workflow-tidy-up)
    * [Usage](#usage-4)
* [`workflow-init`](#workflow-init)
    * [Details](#details)

<!-- vim-markdown-toc -->

## `workflow-branch`

Create a new git branch with the following name format:

```
[<client>-]<brief-description>-<yyyymmdd>-<initials>
```

Where:

  - `<client>` - (Optional) Client's name
  - `<brief-description>` - Description of the work
  - `<yyyymmdd>` - Today's date
  - `<initials>` - Engineer's initials

Script will prompt for details and format appropriately (i.e. no
spaces/underscores, all lowercase).

### Usage

```
Usage: workflow-branch [-c <client>|-C] [-d <description>] [-i <initials>]
                       [-b <base-branch>|-B] [-t <yyyymmdd>] [-s <ticket#>|-S]
                       [-P] [-N] [-h]
```

This script accepts optional arguments to skip input prompts and override
defaults and [git configurations](#configurations). For details on optional
arguments, run:

```
workflow-branch -h
```

If no optional arguments are provided, you will be prompted for information used
in the branch name (client, description, etc). 

### Configurations

Script will use the following git configs if set:

- `workflow.initials`: Skip the prompt for user's initials and use the value
  of this. E.g. to automatically use "cd":

    ```bash
    git config --global workflow.initials cd
    ```

- `workflow.baseBranch`: Use instead of `master` as the base git branch when
  creating the new branch. E.g. to base branches off `develop`:

    ```bash
    git config workflow.baseBranch develop
    ```
- `workflow.badBranchNamePatterns`: Set to a **space-separated** string of
  patterns that should not appear in a standard branch name. Script will
  check for these before attempting to create a branch. E.g. if branch
  names shouldn't include the words `-web` or `-plugins`:

    ```bash
    git config workflow.badBranchNamePatterns "-web -plugins"
    ```

- `workflow.enableCommitTemplate`: By default, script will prompt for an
  optional ticket number and create a commit message template with it (see
  [`workflow-commit-template`](#workflow-commit-template)). Set this to `0` to
  disable the ticket number prompt.


## `workflow-commit-template`

Creates and configures a git commit template for the current branch that
includes a ticket number in brackets before the commit message. E.g. for ticket
number `12345`:

 ```
 [#12345] <commit message text goes here>
 ```

Templates generated with this script are created in the root of the git
repository with this name format:

 ```
 .gitmessage_local_<ticket>_<branch>
 ```

Where `<ticket>` is the ticket number used in the template and `<branch>` is the
branch that will use this template.

### Usage

```
workflow-commit-template [<ticket number>]
```

If not arguments are passed, user will be prompted for the ticket number.

#### Remove and unconfigure local template

Use `workflow-unset-commit-template` to quickly unset local `commit.template`
config and remote the template file.

(See [`workflow-unset-commit-template`](#workflow-unset-commit-template) for
more information.)

### Configuring Git

#### Configure git to ignore generated template files

##### For individal repo:

To ignore generated templates in a single repository, add the following to the
`.gitignore`:

```
# Commit message templates
.gitmessage_local*
```

##### For all repos (RECOMMENDED):

To have git always ignore generated templates:

1. Create a global gitignore file, e.g. `~/.gitignore_global`
2. Set the global git config for `core.excludesfile` to the path to the global
   gitignore, e.g.:

    ```
    git config --global core.excludesfile ~/.gitignore_global
    ```

3. Add the following to your global gitignore:

    ```
    # Commit message templates
    .gitmessage_local*
    ```

See the following articles for more information on `core.excludesfile`:

- [GitHub - Ignoring files](https://docs.github.com/en/github/using-git/ignoring-files#configuring-ignored-files-for-all-repositories-on-your-computer)
- [Git Configuration - core.excludesfile](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration#_core_excludesfile)


## `workflow-unset-commit-template`

For use with [`workflow-commit-template`](#workflow-commit-template).

Unset branch's git config for `commit.template`. Template file will be deleted
unless `-D` argument was specified.

### Usage

```
Usage: workflow-unset-commit-template [-b <branch>] [-D] [-h]
```

This script accepts optional arguments to override defaults. For details on
optional arguments, run:

```
workflow-unset-commit-template -h
```


## `workflow-finish-branch`

Finish a project branch. 

Will prompt for confirmation before executing (unless `-f` is specified), then
performs the following:

  - Call [`workflow-unset-commit-template`](#workflow-unset-commit-template) for
    the target branch
  - Checkout base branch (see [git configurations](#configurations) for details)
    and pull latest updates
  - Attempt to delete target branch using `git branch -d`, which may fail if
    target branch has not been fully merged upstream or in `HEAD`

### Usage

```
Usage: workflow-finish-branch [-b <branch>] [-f] [-h]
```

This script accepts optional arguments to override defaults. For details on
optional arguments, run:

```
workflow-finish-branch -h
```


## `workflow-tidy-up`

Tidy up workflow-related files and configs.

Will list affected branches and files and prompt for confirmation before
executing (unless `-f` is specified), then perform the following:

  - Call [`workflow-unset-commit-template`](#workflow-unset-commit-template) for
    each branch with a commit template configured
  - Remove each orphan commit template with no associated project branch

By default, the current branch will be omitted from cleanup.

### Usage

```
Usage: workflow-tidy-up [-f] [-B] [-o] [-h]
```

This script accepts optional arguments to override defaults. For details on
optional arguments, run:

```
workflow-tidy-up -h
```


## `workflow-init`

Set up the git repository for use with workflow scripts.

**NOTE:** Scripts that depend on the workflow config set up should run this
script automagically if the current repo has not been initialized, so you
probably won't ever need to run this directly.

### Details

1. Create `.git/config_workflow`. Any configurations made by other workflow
   scripts will be set in this file.
2. Add `include.path=config_workflow` to local repo config. This will pull in
   any configurations from that file into the local repo.

