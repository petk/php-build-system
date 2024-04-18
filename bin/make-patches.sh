#!/bin/sh
#
# Script for making php-src patches.

if test -z "$REPO"; then
  REPO="php-src"
fi

# A list of branches with CMake related patches.
branches="patch-cmake-8.3
patch-cmake-8.3-asm
patch-cmake-8.3-aspell
patch-cmake-8.3-dmalloc
patch-cmake-8.3-fopencookie
patch-cmake-8.3-hash
patch-cmake-8.3-php-config
patch-cmake-8.3-phpdbg-local-console
patch-cmake-8.4
patch-cmake-8.4-asm
patch-cmake-8.4-dmalloc
patch-cmake-8.4-docs
patch-cmake-8.4-php-config
patch-cmake-8.4-phpdbg-local-console
patch-cmake-8.4-typedef-warnings
"

# A list of supported PHP versions.
php_versions="8.3 8.4"

# The PHP MAJOR.MINOR version currently in development
php_version_dev="8.4"

# Whether to rebase the patch branches against their tracked origins.
refresh=0

# Go to script root directory.
cd $(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)

while test $# -gt 0; do
  if test "$1" = "-h" || test "$1" = "--help"; then
    cat << HELP
Make php-src patches

A simple helper that creates patches needed to use CMake with php-src source
code. There needs to be a php-src repository clone locally one directory above
with patched branch.

SYNOPSIS:
   $0 [<options>]

OPTIONS:
  -r, --refresh    Iterate over php-src branches with CMake patches and rebase
                   them against upstream origins.
  -h, --help       Display this help and exit.

ENVIRONMENT VARIABLES:
   The following optional variables are supported:

   REPO    Overrides the location to the locally patched php-src repository.
           REPO=php-src-repo $0
HELP
    exit 0
  fi

  if test "$1" = "-r" || test "$1" = "--refresh"; then
    refresh=1
  fi

  shift
done

cd ../
current_repo=$(basename "$PWD")
cd ../

# Check if there is local patched php-src repository available.
if test ! -d ${REPO}; then
  echo "Patched php-src Git repository is missing." >&2
  exit 1
fi

cd ${REPO}

# Check if local branch with patches is available in the php-src repository.
for branch in $branches; do
  if test -z "$(git show-ref refs/heads/${branch})"; then
    echo "Branch ${branch} is missing." >&2
    exit 1
  fi
done

for php in $php_versions; do
  # Refresh php-src branches with patches and rebase with origin latest changes.
  if test "$refresh" = "1"; then
    if test "$php" = "$php_version_dev"; then
      git checkout master
    else
      git checkout PHP-${php}
    fi

    if test "x$?" != "x0"; then
      echo "ERROR: The branch couldn't be checked out." >&2
      echo "       You have unstaged changes. Please stash or commit them." >&2
      exit 1
    fi

    git pull --rebase
  fi

  if test -d ../${current_repo}/patches/${php}; then
    # Clean existing patches.
    rm -rf ../${current_repo}/patches/${php}
  fi

  mkdir -p ../${current_repo}/patches/${php}
done

# Create patch files.
for branch in $branches; do
  php_version=$(echo $branch | sed 's/patch-cmake-\([0-9.]*\).*$/\1/')

  if test "$refresh" = "1"; then
    git checkout ${branch}

    if test "$php_version" = "$php_version_dev"; then
      echo "Rebasing ${branch} on top of master"
      git rebase master
    else
      echo "Rebasing ${branch} on top of PHP-${php_version}"
      git rebase PHP-${php_version}
    fi

    if test "x$?" != "x0"; then
      echo "ERROR: The branch ${branch} couldn't be rebased." >&2
      echo "       Go to php-src and resolve conflicts manually." >&2
      exit 1
    fi
  fi

  patch_filename="$(echo $branch | sed 's/patch-cmake-[0-9.]*-*\(.*\)$/\1/')"
  if test -z "${patch_filename}"; then
    patch_filename="cmake"
  fi
  patch_filename="${patch_filename}.patch"

  patch="../${current_repo}/patches/${php_version}/${patch_filename}"

  if test -f $patch; then
    echo "Patch ${patch_filename} already exists. Rename the branch ${branch}." >&2
    exit 1
  fi

  echo "Creating patches/${php_version}/${patch_filename}"

  git --no-pager format-patch -1 ${branch} \
    --stdout \
    --no-signature \
    --subject-prefix="" \
    > ${patch}

  # Remove redundant patch header information.
  sed -i '/^From /d' ${patch}
  sed -i '/^From: /d' ${patch}
  sed -i '/^Date: /d' ${patch}
done
