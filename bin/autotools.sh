#!/bin/sh
#
# Helper script to check PHP Autotools build system.

update=1
branch="master"

# Go to project root.
cd $(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)

while test $# -gt 0; do
  if test "$1" = "-h" || test "$1" = "--help"; then
    cat << HELP
Check and update PHP Autotools build system.

SYNOPSIS:
  autotools.sh [<options>]

OPTIONS:
  -b, --branch BRANCH  Branch to checkout (default master branch).
  -n, --no-update      Don't reset and pull the php-src Git repository.
  -h, --help           Display this help.

USAGE:
  Update and check all Autotools files in the cloned php-src repository:
    ./bin/autotools.sh

  Update and check all Autotools files on specific branch:
    ./bin/autotools.sh -b PHP-8.3

  Check all Autotools files without resetting the php-src repository:
    ./bin/autotools.sh -n
HELP
    exit 0
  fi

  if test "$1" = "-b" || test "$1" = "--branch"; then
    branch=$2

    check=$(echo "$branch" | grep -Eq ^master\|PHP-[0-9]+.[0-9.]+.*$)
    if test "x$?" != "x0"; then
      echo "Branch ${branch} is not valid name"
      exit 1
    fi

    shift
  fi

  if test "$1" = "-n" || test "$1" = "--no-update"; then
    update=0
  fi

  shift
done

# Check requirements.
download_tool=$(which curl 2>/dev/null)
download_tool_options="--progress-bar --output"
autoreconf=$(which autoreconf 2>/dev/null)

if test -z "$download_tool"; then
  download_tool=$(which wget 2>/dev/null)
  download_tool_options="--no-verbose -O"
fi

if test -z "$download_tool"; then
  echo "autotools.sh: Please install wget or curl." >&2
fi

if test -z "$autoreconf"; then
  echo "autotools.sh: Please install Autoconf." >&2
fi

if test -z "$download_tool" \
  || test -z "$autoreconf"
then
  exit 1
fi

# Clone a fresh latest php-src repository.
if test ! -d "php-src"; then
  echo "To use this tool you need php-src Git repository."
  printf "Do you want to clone it now (y/N)?"
  read answer

  if test "$answer" != "${answer#[Yy]}"; then
    echo "Cloning github.com/php/php-src. This will take a little while."
    git clone https://github.com/php/php-src ./php-src
  else
    exit 1
  fi
fi

# Make sure we're in the php-src Git repository.
cd php-src

if test ! -f "main/php_version.h" \
  || test ! -f "php.ini-development"
then
  echo "Git repository doesn't seem to be php-src." >&2
  exit 1
fi

# Check if given branch is available.
if test -z "$(git show-ref refs/heads/${branch})"; then
  if test -z "$(git ls-remote --heads origin refs/heads/${branch})"; then
    echo "Branch ${branch} is missing." >&2
    exit 1
  fi

  git checkout --track origin/${branch}
fi

# Reset php-src Git working directory and checkout branch.
if test "x$update" = "x1"; then
  git reset --hard
  git clean -dffx
  git checkout ${branch}
  git pull --rebase
  echo
fi

# Generate configure script with warnings enabled to check for issues.
echo "Running autoreconf --warnings=all --verbose --force"
$autoreconf --warnings=all --verbose --force

# Download latest build/config.guess and build/config.sub files. These two
# determine the platform characteristics and are bundled in PHP from upstream.
echo
echo "Updating build/config.guess"
$download_tool $download_tool_options build/config.guess \
  https://git.savannah.gnu.org/cgit/config.git/plain/config.guess

echo
echo "Updating build/config.sub"
$download_tool $download_tool_options build/config.sub \
  https://git.savannah.gnu.org/cgit/config.git/plain/config.sub

echo
echo "Updating build/pkg.m4"
$download_tool $download_tool_options build/pkg.m4 \
  https://raw.githubusercontent.com/pkgconf/pkgconf/master/pkg.m4

# Update GNU Autoconf Archive macros.
# https://github.com/autoconf-archive/autoconf-archive/
m4="
ax_check_compile_flag.m4
ax_func_which_gethostbyname_r.m4
ax_gcc_func_attribute.m4
"

for file in $m4; do
  if test -f build/${file}; then
    echo
    echo "Updating build/${file}"

    $download_tool $download_tool_options build/${file} \
      https://raw.githubusercontent.com/autoconf-archive/autoconf-archive/master/m4/${file}
  fi
done

# Run autoupdate script on all M4 files for using newest Autoconf.
echo
echo "Running autoupdate"
echo

files=$(find . -type f -name "*.m4")
files="configure.ac $files"

for file in $files; do
  autoupdate --force $file
  printf "\e[2K"
  printf "Updating $file\r"
done

# Clear last line with file update info.
printf "\e[2K"

echo
echo "Finished."
