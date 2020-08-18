# Git Workflow Scripts

## Overview

**TODO: walk thru workflow**

### Create a New Branch with Commit Template

![new-branch.sh demo](../assets/0-new-branch.gif?raw=true)

### Commits Will Include Ticket Number

![commit-template.sh demo](../assets/1-commit-template.gif?raw=true)

### Use `unset-commit-template.sh` to Remove Commit Template

![unset-commit-template.sh demo](../assets/2-unset-template.gif?raw=true)

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

* [`new-branch.sh`](#new-branchsh)
    * [Usage](#usage)
    * [Git Configurations](#git-configurations)
* [`commit-template.sh`](#commit-templatesh)
    * [Usage](#usage-1)
        * [Remove and unconfigure local template](#remove-and-unconfigure-local-template)
    * [Configuration](#configuration)
        * [Configure git to ignore generated template files](#configure-git-to-ignore-generated-template-files)
            * [For individal repo:](#for-individal-repo)
            * [For all repos (RECOMMENDED):](#for-all-repos-recommended)
* [`unset-commit-template.sh`](#unset-commit-templatesh)
    * [Usage](#usage-2)
* [`workflow-init.sh`](#workflow-initsh)
    * [Details](#details)

<!-- vim-markdown-toc -->

## `new-branch.sh`

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
Usage: new-branch.sh [-c <client>|-C] [-d <description>] [-i <initials>]
                     [-b <base-branch>|-B] [-t <yyyymmdd>] [-s <ticket#>|-S]
                     [-P] [-N] [-h]
```

This script accepts optional arguments to skip input prompts and override
defaults and [git configurations](#git-configurations). For details on optional
arguments, run:

```
new-branch.sh -h
```

If no optional arguments are provided, you will be prompted for information used
in the branch name (client, description, etc). 

### Git Configurations

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
  [commit-template.sh](#commit-templatesh)). Set this to `0` to disable the
  ticket number prompt.


## `commit-template.sh`

Creates and configures a git commit template for the current branch that
includes a ticket number in brackets before the commit message. E.g. for ticket
number `12345`:

 ```
 [#12345] <commit message text goes here>
 ```

Templates generated with this script are created in the root of the git
repository with this name format:

 ```
 .gitmessage_local_<ticket>
 ```

Where `<ticket>` is the ticket number used in the template.

### Usage

```
commit-template.sh [<ticket number>]
```

If not arguments are passed, user will be prompted for the ticket number.

#### Remove and unconfigure local template

Use `unset-commit-template.sh` to quickly unset local `commit.template` config
and remote the template file.

(See [`unset-commit-template.sh`](#unset-commit-templatesh) for more
information.)

### Configuration

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


## `unset-commit-template.sh`

For use with [`commit-template.sh`](#commit-templatesh)

Unset current branch's git config for `commit.template`. Template file will be
deleted unless `-D` argument was specified.

### Usage

Running `unset-commit-template -h` will display details on usage and arguments:

```
Usage: unset-commit-template.sh [-D] [-h]
Options:
  -D  Don't delete commit template file.
  -h  Show this help message and exit.
```


## `workflow-init.sh`

Set up the git repository for use with workflow scripts.

**NOTE:** Scripts that depend on the workflow config set up should run this
script automagically if the current repo has not been initialized, so you
probably won't ever need to run this directly.

### Details

1. Create `.git/config_workflow`. Any configurations made by other workflow
   scripts will be set in this file.
2. Add `include.path=config_workflow` to local repo config. This will pull in
   any configurations from that file into the local repo.

