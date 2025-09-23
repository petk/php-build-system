#!/bin/sh
#
# Script for updating php-src patches.

if test -z "$REPO"; then
  REPO="php-src"
fi

# A list of supported PHP versions.
phpVersions="8.3 8.4 8.5 8.6"

# The PHP MAJOR.MINOR version currently in development (the master branch).
phpVersionDev="8.6"

# Temporary Git branch for applying patches and rebasing the branch.
temporaryBranch=cmake-patching

# Go to project root.
cd "$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd -P)" || exit

while test $# -gt 0; do
  if test "$1" = "-h" || test "$1" = "--help"; then
    cat << HELP
Update php-src patches

A simple helper that updates patches needed to use CMake with php-src source
code.

SYNOPSIS:
   $0 [<options>]

OPTIONS:
  -h, --help       Display this help and exit.

ENVIRONMENT VARIABLES:
   The following optional variables are supported:

   REPO    Overrides the location to the locally cloned php-src repository.
           REPO=php-src-repo $0
HELP
    exit 0
  fi

  shift
done

# Check requirements.
which=$(which which 2>/dev/null)
git=$(which git 2>/dev/null)

if test -z "$which"; then
  echo "update-patches.sh: The 'which' command not found." >&2
  echo "                   Please install coreutils." >&2
  exit 1
fi

if test -z "$git"; then
  echo "update-patches.sh: The 'git' command not found." >&2
  echo "                   Please install Git:" >&2
  echo "                   https://git-scm.com" >&2
  exit 1
fi

# Clone a fresh latest php-src repository.
if test ! -d "${REPO}"; then
  echo "To use this tool you need php-src Git repository."
  printf "Do you want to clone it now (y/N)?"
  read answer

  if test "$answer" != "${answer#[Yy]}"; then
    echo "Cloning github.com/php/php-src. This will take a little while."
    "$git" clone https://github.com/php/php-src ${REPO}
  else
    exit 1
  fi
fi

# Make sure we're in the php-src repository.
cd ${REPO}
if test ! -f "main/php_version.h" \
  || test ! -f "php.ini-development"
then
  echo "Git repository doesn't seem to be php-src." >&2
  exit 1
fi

# Check if there is existing temporary Git branch to not override.
if test -n "$(git show-ref refs/heads/${temporaryBranch})"; then
  echo "E: There is existing ${temporaryBranch} branch." >&2
  echo "E: Remove or rename ${temporaryBranch} branch." >&2
  exit 1
fi

for php in $phpVersions; do
  if test "$php" = "$phpVersionDev"; then
    branch=master
  else
    branch=PHP-$php
  fi

  # Check if php-src branch exists.
  if test -z "$(git show-ref refs/heads/${branch})"; then
    echo "E: Branch ${branch} is missing." >&2
    exit 1
  fi

  "$git" reset --hard
  "$git" clean -dffx
  "$git" checkout ${branch}
  "$git" pull --rebase

  for patch in "$PWD/../patches/$php"/*.patch; do
    fileName=patches/$php/$(basename "$patch")
    echo "-> Updating $fileName"

    "$git" checkout -b ${temporaryBranch}
    "$git" am -3 $patch

    if test "x$?" != "x0"; then
      echo "E: Patch ${patch} needs manual resolution." >&2
      echo "   Go to php-src and resolve conflicts manually." >&2
      exit 1
    fi

    "$git" --no-pager format-patch -1 ${temporaryBranch} \
      --stdout \
      --no-signature \
      --subject-prefix="" \
    > ${patch}

    # Remove redundant patch header information.
    sed -i '/^From /d' ${patch}
    sed -i '/^Date: /d' ${patch}

    # Replace email if needed.
    #sed -i 's/^From: .*/From: ElePHPant <elephpant@example.com>/' ${patch}

    "$git" checkout ${branch}
    "$git" branch -D ${temporaryBranch}
  done
done
