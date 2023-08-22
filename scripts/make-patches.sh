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

REPO="php-src"
MAIN_BRANCH="patch-cmake"
EXTRA_BRANCHES="
patch-aspell
"

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
for branch in $MAIN_BRANCH $EXTRA_BRANCHES; do
  if test -z $(git rev-parse --verify ${branch} 2>/dev/null); then
    echo "Branch ${branch} is missing." >&2
    exit 1
  fi
done

if test -d ../${current_repo}/patches; then
  # Clean existing patches.
  rm ../${current_repo}/patches/*.patch
  rm ../${current_repo}/patches/.*.patch
else
  mkdir -p ../${current_repo}/patches
fi

# Get a list of patched files in the main CMake branch.
files=$(git --no-pager show --format= ${MAIN_BRANCH} --name-only)

for file in $files; do
  if test -f ${file}; then
    echo "Creating patch for ${file}"
    git --no-pager show --format= ${MAIN_BRANCH} -- ${file} > ../${current_repo}/patches/${file}.patch
  else
    echo "${file} is missing" >&2
  fi
done

# Additional patches.
for branch in $EXTRA_BRANCHES; do
  patch="$(echo $branch | sed 's/patch-\(.*\)/\1/').patch"
  patch_path="../${current_repo}/patches/${patch}"

  if test -f $patch_path; then
    echo "Patch ${patch} already exists. Rename the branch." >&2
    exit 1
  fi

  echo "Creating patch $patch"
  git --no-pager show --format= ${branch} > ${patch_path}
done
