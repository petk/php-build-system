#!/bin/sh
#
# A simple helper that creates patches needed to use CMake with php-src source
# code. There needs to be a php-src repository clone locally one directory
# above with patched branch.
#
# SYNOPSIS:
#   make-patches.sh
#
# ENVIRONMENT VARIABLES:
#   The following optional variables are supported:
#
#   REPO    Overrides the location to the locally patched php-src repository.
#           REPO=php-src-repo ./bin/make-patches.sh

if test -z "$REPO"; then
  REPO="php-src"
fi
branches="patch-cmake-8.3
patch-cmake-8.3-aspell
patch-cmake-8.3-dmalloc
patch-cmake-8.3-fopencookie
patch-cmake-8.4
patch-cmake-8.4-dmalloc
"
php_versions="8.3 8.4"

# Go to script root directory.
cd $(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)

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
  if test -d ../${current_repo}/patches/${php}; then
    # Clean existing patches.
    rm -rf ../${current_repo}/patches/${php}
  fi

  mkdir -p ../${current_repo}/patches/${php}
done

# Create patch files.
for branch in $branches; do
  php_version=$(echo $branch | sed 's/patch-cmake-\([0-9.]*\).*$/\1/')
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
  git --no-pager show --format= ${branch} > ${patch}
done
