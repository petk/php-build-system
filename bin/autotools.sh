#!/bin/sh
#
# Helper script to check PHP Autotools-based build system.

branch="master"
exitCode=0

################################################################################
# Parse options and arguments.
################################################################################

while test $# -gt 0; do
  if test "$1" = "-h" || test "$1" = "--help"; then
    cat << HELP
Check and update PHP Autotools-based build system.

SYNOPSIS:
  $0 [<options>]

OPTIONS:
  -b, --branch BRANCH  Branch to checkout (default master branch).
  -h, --help           Display this help.

USAGE:
  Check and update all Autotools related files in the php-src repository:
    $0

  Specify a PHP branch:
    $0 -b PHP-8.3
HELP
    exit 0
  elif test "$1" = "-b" || test "$1" = "--branch"; then
    branch=$2

    check=$(echo "$branch" | grep -Eq ^master\|PHP-[0-9]+.[0-9.]+.*$)
    if test "x$?" != "x0"; then
      echo "Branch ${branch} is not valid name" >&2
      exit 1
    fi

    shift
  fi

  shift
done

################################################################################
# Check requirements.
################################################################################

downloadTool=$(which curl 2>/dev/null)
downloadToolOptions="--progress-bar --output"
autoreconf=$(which autoreconf 2>/dev/null)
git=$(which git 2>/dev/null)

if test -z "$downloadTool"; then
  downloadTool=$(which wget 2>/dev/null)
  downloadToolOptions="--no-verbose -O"
fi

if test -z "$downloadTool"; then
  echo "autotools.sh: Please install wget or curl." >&2
fi

if test -z "$autoreconf"; then
  echo "autotools.sh: Please install Autoconf:" >&2
  echo "              https://savannah.gnu.org/projects/autoconf" >&2
fi

if test -z "$git"; then
  echo "autotools.sh: Please install Git:" >&2
  echo "              https://git-scm.com" >&2
fi

if test -z "$downloadTool" \
  || test -z "$autoreconf" \
  || test -z "$git"
then
  exit 1
fi

################################################################################
# Go to project root.
################################################################################

cd "$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd -P)" || exit

################################################################################
# Prepare php-src Git repository.
################################################################################

# Clone a fresh latest php-src repository.
if test ! -d "php-src"; then
  echo "To use this tool you need php-src Git repository."
  printf "Do you want to clone it now (y/N)?"
  read answer

  if test "$answer" != "${answer#[Yy]}"; then
    echo "Cloning github.com/php/php-src. This will take a little while."
    $git clone https://github.com/php/php-src ./php-src
  else
    exit 1
  fi
fi

# Make sure we're in the php-src Git repository.
cd php-src
if test -f "main/php_version.h" && test -f "php.ini-development"; then
  # Check if given branch is available.
  if test -z "$($git show-ref refs/heads/${branch})"; then
    if test -z "$($git ls-remote --heads origin refs/heads/${branch})"; then
      echo "Branch ${branch} is missing." >&2
      exit 1
    fi

    $git checkout --track origin/${branch}
  fi

  # Reset php-src Git working directory and checkout branch.
  $git reset --hard
  $git clean -dffx
  $git checkout ${branch}
  $git pull --rebase
  echo
else
  echo "Git repository doesn't seem to be php-src." >&2
  exit 1
fi

################################################################################
# Generate configure script with warnings enabled to check for issues.
################################################################################

echo "Running autoreconf --warnings=all --verbose --force"
$autoreconf --warnings=all --verbose --force

################################################################################
# Run manual checks.
################################################################################

# Check there are no erroneous dnl strings attached in the generated configure
# script. The dnl is a M4 macro (Discard to Next Line) and shouldn't be there
# unless it is part of some string or word.
nodnl=$(grep dnl configure)
if test -n "$nodnl"; then
  echo "WARNING: Generated configure script contains dnl" >&2
  exitCode=1
fi

################################################################################
# Download bundled files from upstream sources.
################################################################################

# Download build/config.guess and build/config.sub. These two determine platform
# characteristics.
echo
echo "Updating build/config.guess"
$downloadTool $downloadToolOptions build/config.guess \
  https://git.savannah.gnu.org/cgit/config.git/plain/config.guess

echo
echo "Updating build/config.sub"
$downloadTool $downloadToolOptions build/config.sub \
  https://git.savannah.gnu.org/cgit/config.git/plain/config.sub

# Download pkg.m4.
echo
echo "Updating build/pkg.m4"
$downloadTool $downloadToolOptions build/pkg.m4 \
  https://raw.githubusercontent.com/pkgconf/pkgconf/master/pkg.m4

# Download GNU Autoconf Archive macros.
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

    $downloadTool $downloadToolOptions build/${file} \
      https://raw.githubusercontent.com/autoconf-archive/autoconf-archive/master/m4/${file}
  fi
done

################################################################################
# Run autoupdate on all M4 files.
################################################################################

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

exit $exitCode
