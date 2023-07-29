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
#   BRANCH  Overrides the branch name containing patches.
#           BRANCH=my-branch ./scripts/make-patches.sh
#   REPO    Overrides the location to the locally patched php-src repository.
#           REPO=php-src-repo ./scripts/make-patches.sh

REPO=php-src
BRANCH=patch-cmake

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
if test -z $(git rev-parse --verify ${BRANCH} 2>/dev/null); then
  echo "Branch ${BRANCH} is missing." >&2
fi

# A list of patched files.
files="
.editorconfig
.gitignore
"

if test ! -d ../${current_repo}/patches; then
  mkdir -p ../${current_repo}/patches
fi

for file in $files; do
  if test -f ${file}; then
    echo "Creating patch for ${file}"
    git diff master ${branch} -- ${file} > ../${current_repo}/patches/${file}.patch
  else
    echo "${file} is missing" >&2
  fi
done
