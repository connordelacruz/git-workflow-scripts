# Git Workflow Scripts

## Contents

<!-- vim-markdown-toc GFM -->

* [Overview](#overview)
    * [Create a New Branch with Commit Template](#create-a-new-branch-with-commit-template)
    * [Finish Up a Branch](#finish-up-a-branch)
    * [Remove a Branch's Commit Template](#remove-a-branchs-commit-template)
    * [Tidy Up Entire Local Repo](#tidy-up-entire-local-repo)
* [Setup](#setup)
    * [Prerequisites](#prerequisites)
    * [Installation](#installation)
    * [Configuring Git to Ignore Script-Related Files](#configuring-git-to-ignore-script-related-files)
        * [Configure Global .gitignore (RECOMMENDED)](#configure-global-gitignore-recommended)
        * [Ignore for Single Repo](#ignore-for-single-repo)
* [Configurations](#configurations)
    * [`workflow.initials`](#workflowinitials)
    * [`workflow.baseBranch`](#workflowbasebranch)
    * [`workflow.badBranchNamePatterns`](#workflowbadbranchnamepatterns)
    * [`workflow.enableCommitTemplate`](#workflowenablecommittemplate)
    * [`workflow.commitTemplateFormat`](#workflowcommittemplateformat)
    * [`workflow.ticketInputFormatRegex`](#workflowticketinputformatregex)
    * [`workflow.ticketFormatCapitalize`](#workflowticketformatcapitalize)
* [Scripts](#scripts)
    * [`workflow-branch`](#workflow-branch)
        * [Usage](#usage)
    * [`workflow-finish-branch`](#workflow-finish-branch)
        * [Usage](#usage-1)
    * [`workflow-commit-template`](#workflow-commit-template)
        * [Usage](#usage-2)
            * [Remove and unconfigure local template](#remove-and-unconfigure-local-template)
    * [`workflow-unset-commit-template`](#workflow-unset-commit-template)
        * [Usage](#usage-3)
    * [`workflow-tidy-up`](#workflow-tidy-up)
        * [Usage](#usage-4)

<!-- vim-markdown-toc -->

# Overview

This repo contains some scripts to speed up common tasks in our git workflow.

## Create a New Branch with Commit Template

Run `workflow-branch` to create a new project branch with the name format:

```
[<client>-]<brief-description>-<yyyymmdd>-<initials>
```

If you provide a ticket number, this will use `workflow-commit-template` to
create a commit template for the branch, so all your commit messages will begin
with:

```
[#<ticket>]
```

**Demos:**

Creating a project branch:

![workflow-branch demo](../assets/demos/branch.gif?raw=true)

Commit messages will include ticket number:

![commit message template demo](../assets/demos/commit-message.gif?raw=true)

Different branches can use different commit templates:

![per-branch commit templates demo](../assets/demos/per-branch-commit-templates.gif?raw=true)

(:point_up: Also, workflow scripts have a variety of command line options)

## Finish Up a Branch

When you're finished with a project branch and have pushed up all your changes
to a remote, run `workflow-finish-branch` to clean up configs, remove the commit
template, and delete the branch.

**Demo:**

![workflow-finish-branch demo](../assets/demos/finish-branch.gif?raw=true)

## Remove a Branch's Commit Template

If you just want to remove the commit template from a branch, run
`workflow-unset-commit-template`.

**Demo:**

![workflow-unset-commit-template demo](../assets/demos/unset-commit-template.gif?raw=true)

## Tidy Up Entire Local Repo

If you have a bunch of lingering commit templates, you can run
`workflow-tidy-up` to clean up configs and commit template files.

**Demo:**

![workflow-tidy-up demo](../assets/demos/tidy-up.gif?raw=true)

--------------------------------------------------------------------------------


# Setup

## Prerequisites

These scripts use features that require **git 2.23 or greater**. To install an
updated version of `git` on macOS using [Homebrew](https://brew.sh/):

```
brew install git
```

Make sure `/usr/local/bin` is added to your `PATH` e.g.:

```
export PATH="/usr/local/bin:$PATH"
```

> **Note:** These scripts were developed using GNU bash 5.0.17 on macOS. While I
> don't believe this uses any features that aren't supported by the builtin
> version of bash on macOS, it's definitely not impossible. [Here's instructions
> on upgrading bash on macOS using
> Homebrew](https://itnext.io/upgrading-bash-on-macos-7138bd1066ba) just in
> case.

## Installation

Clone this repo and update your `.bashrc` to include it in your `PATH`. E.g. if
you cloned it into `~/bin/git-workflow-scripts`:

```bash
export PATH="$HOME/bin/git-workflow-scripts:$PATH"
```

## Configuring Git to Ignore Script-Related Files

These scripts generate files for commit templates, which you probably don't want
to track in your repos.

### Configure Global .gitignore (RECOMMENDED)

To have git ignore generated template files in all repos:

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

> For more information on `core.excludesfile`:
> 
> - [GitHub - Ignoring files](https://docs.github.com/en/github/using-git/ignoring-files#configuring-ignored-files-for-all-repositories-on-your-computer)
> - [Git Configuration - core.excludesfile](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration#_core_excludesfile)

### Ignore for Single Repo

To ignore generated template files in a single repo, add the following to the
`.gitignore`:

```
# Commit message templates
.gitmessage_local*
```

--------------------------------------------------------------------------------


# Configurations

Scripts will use the following git configs if set:

## `workflow.initials` 

**Used in:** [`workflow-branch`](#workflow-branch)

When running [`workflow-branch`](#workflow-branch), skip the prompt for user's
initials and use the value of this.

E.g. to automatically use "cd":

```bash
git config --global workflow.initials cd
```

## `workflow.baseBranch`

**Used in:** [`workflow-branch`](#workflow-branch),
[`workflow-finish-branch`](#workflow-finish-branch)

**Default:** `master`

Branch to use as a base when creating a new branch.

E.g. to base branches off `develop`:

```bash
git config workflow.baseBranch develop
```

## `workflow.badBranchNamePatterns` 

**Used in:** [`workflow-branch`](#workflow-branch)

Set to a **space-separated** string of patterns that should not appear in a
standard branch name. Script will check for these before attempting to create a
branch. 

E.g. if branch names shouldn't include the words `-web` or `-plugins`:

```bash
git config workflow.badBranchNamePatterns "-web -plugins"
```

## `workflow.enableCommitTemplate` 

**Used in:** [`workflow-branch`](#workflow-branch)

**Default:** `1`

By default, script will prompt for an optional ticket number and create a commit
message template with it (see
[`workflow-commit-template`](#workflow-commit-template)). Set this to `0` to
disable the ticket number prompt.


## `workflow.commitTemplateFormat`

**Used in:** [`workflow-commit-template`](#workflow-commit-template)

**Default:** `"[%%ticket%%] "`

Format of the commit template body. The following placeholders are supported and
will be replaced with their corresponding value:

- `%%ticket%%`: Replaced with ticket number


## `workflow.ticketInputFormatRegex`

**Used in:** [`workflow-commit-template`](#workflow-commit-template)

**Default:** `'[a-zA-Z]+-[0-9]+'`

Regex used to validate format of input for ticket number. By default, a valid
ticket number is 1 or more letters, followed by a hyphen, followed by 1 or more
numbers.


## `workflow.ticketFormatCapitalize`

**Used in:** [`workflow-commit-template`](#workflow-commit-template)

**Default:** `1`

By default, lowercase letters in ticket number will be capitalized in result.
E.g. if the ticket number input is:

```
ht-12345
```

The ticket number in the resulting commit template will be:

```
HT-12345
```

Set this to `0` to disable automatic capitalization.


--------------------------------------------------------------------------------

# Scripts

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
                       [-P] [-N] [-V] [-h]
```

This script accepts optional arguments to skip input prompts and override
defaults and [git configurations](#configurations). For details on optional
arguments, run:

```
workflow-branch -h
```

If no optional arguments are provided, you will be prompted for information used
in the branch name (client, description, etc). 


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
Usage: workflow-finish-branch [-b <branch>] [-f] [-V] [-h]
```

This script accepts optional arguments to override defaults. For details on
optional arguments, run:

```
workflow-finish-branch -h
```


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

> To configure git to ignore these template files, see [Configuring Git to
> Ignore Script-Related Files](#configuring-git-to-ignore-script-related-files)

### Usage

```
workflow-commit-template [<ticket number>] [-V] [-h]
```

If not arguments are passed, user will be prompted for the ticket number.

#### Remove and unconfigure local template

Use `workflow-unset-commit-template` to quickly unset local `commit.template`
config and remote the template file.

(See [`workflow-unset-commit-template`](#workflow-unset-commit-template) for
more information.)


## `workflow-unset-commit-template`

For use with [`workflow-commit-template`](#workflow-commit-template).

Unset branch's git config for `commit.template`. Template file will be deleted
unless `-D` argument was specified.

### Usage

```
Usage: workflow-unset-commit-template [-b <branch>] [-D] [-V] [-h]
```

This script accepts optional arguments to override defaults. For details on
optional arguments, run:

```
workflow-unset-commit-template -h
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
Usage: workflow-tidy-up [-f] [-B] [-o] [-V] [-h]
```

This script accepts optional arguments to override defaults. For details on
optional arguments, run:

```
workflow-tidy-up -h
```

