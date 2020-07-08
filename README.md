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

# Scripts

<!-- vim-markdown-toc GFM -->

* [new-branch.sh](#new-branchsh)
    * [Usage](#usage)
    * [Optional Arguments](#optional-arguments)
    * [Environment Variables](#environment-variables)
* [commit-template.sh](#commit-templatesh)
    * [Usage](#usage-1)
        * [Remove and unconfigure local template](#remove-and-unconfigure-local-template)
    * [Configuration](#configuration)
        * [Configure git to ignore generated template files](#configure-git-to-ignore-generated-template-files)
            * [For individal repo:](#for-individal-repo)
            * [For all repos (RECOMMENDED):](#for-all-repos-recommended)
* [unset-commit-template.sh](#unset-commit-templatesh)
    * [Usage](#usage-2)

<!-- vim-markdown-toc -->

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

### Usage

```
new-branch.sh [<optional arguments>]
```

You will be prompted for information used in the branch name (client,
description, etc). 

See below for details on [optional arguments](#optional-arguments).

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


## commit-template.sh

Creates and configures a local git commit template that includes a ticket number
in brackets before the commit message. E.g. for ticket number `12345`:

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

(See [unset-commit-template.sh](#unset-commit-templatesh) for more information.)

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


## unset-commit-template.sh

*For use with (commit-template.sh)[#commit-templatesh]*

Unset local git config for `commit.template` if configured. Template file will
be deleted unless `-D` argument was specified.

### Usage

Running `unset-commit-template -h` will display details on usage and arguments:

```
Usage: unset-commit-template.sh [-D] [-h]
Options:
  -D  Don't delete commit template file.
  -h  Show this help message and exit.
```

