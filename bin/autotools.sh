#!/bin/sh
#
# Helper script to check Autotools build system.

force=0
debug=0

# Go to project root.
cd $(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)

while test $# -gt 0; do
  if test "$1" = "-h" || test "$1" = "--help"; then
    cat << HELP
Checker for Autotools build system of PHP.

SYNOPSIS:
  autotools.sh [<options>]

OPTIONS:
  -b, --branch [BRANCH] Branch to checkout. Default is master branch.
  -f, --force           Regenerate php-src repository.
  --debug               Display warnings.
  -h, --help            Display this help.

ENVIRONMENT:
  The following optional variables are supported:

USAGE:

To update and check all Autotools files:
  ./bin/autotools.sh

To update and check all Autotools files on specific branch:
  ./bin/autotools.sh -b PHP-8.3

To reset the cloned php-src repository:
  ./bin/autotools.sh -f
HELP
    exit 0
  fi

  if test "$1" = "-b" || test "$1" = "--branch"; then
    branch=$2

    check=$(echo "$branch" | grep -Eq ^master\|PHP-[0-9]+.[0-9.]+.*$)
    if test "x$?" != "x0"; then
      echo "${branch} is not valid branch name"
      exit 1
    fi

    shift
  fi

  if test "$1" = "-f" || test "$1" = "--force"; then
    force=1
  fi

  if test "$1" = "--debug"; then
    debug=1
  fi

  shift
done

# Clone a fresh latest php-src repo.
if test ! -d "php-src"; then
  git clone --depth 1 https://github.com/php/php-src ./php-src
fi

if test -z "$branch"; then
  branch="master"
fi

cd php-src

if test -z $(git rev-parse --verify ${branch} 2>/dev/null); then
  echo "Branch ${branch} is missing." >&2
  exit 1
fi

cd ..

if test "$force" = "1"; then
  cd php-src
  git reset --hard
  git clean -dffx
  git checkout master
  git pull --rebase
  cd ..
  echo
fi

cd php-src

# Generate configure script with warnings enabled to check for issues.
echo "Running autoreconf --warnings=all -v"
autoreconf --warnings=all -v

echo
echo "Updating build/config.guess"
wget -nv -O build/config.guess https://git.savannah.gnu.org/cgit/config.git/plain/config.guess

echo
echo "Updating build/config.sub"
wget -nv -O build/config.sub https://git.savannah.gnu.org/cgit/config.git/plain/config.sub

# Update GNU Autoconf Archive macros.
m4="
ax_check_compile_flag.m4
ax_func_which_gethostbyname_r.m4
ax_gcc_func_attribute.m4
"

for file in $m4; do
  if test -f build/${file}; then
    echo
    echo "Updating build/${file}"

    wget -nv -O build/${file} https://raw.githubusercontent.com/autoconf-archive/autoconf-archive/master/m4/${file}
  fi
done

echo
echo "Running autoupdate"

files=$(find . -type f -name "*.m4")
files="configure.ac $files"

for file in $files; do
  autoupdate -f $file
done

echo
echo "Finished."
