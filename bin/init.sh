#!/bin/sh
#
# CMake initialization helper script.

update=1
use_cmake=0
options=""
preset="default"
generator=""
branch=""
debug=0

# The PHP MAJOR.MINOR version currently in development (the master branch).
phpVersionDev="8.6"

# Go to project root.
cd "$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd -P)" || exit

while test $# -gt 0; do
  if test "$1" = "-h" || test "$1" = "--help"; then
    cat << HELP
PHP CMake initialization helper

SYNOPSIS:
  $0 [<options>]

OPTIONS:
  -n, --no-update      Don't pull branches in the php-src Git repository.
  -c, --cmake          Run cmake configuration and build commands.
  -o, --options VALUE  CMake options which are appended to the CMake command.
                         cmake -DOPTION .
  -p, --preset VALUE   Use CMake preset with name VALUE, otherwise "default" is
                       used (see CMakePresets.json).
  -G <generator-name>  Specify a CMake build system generator.
  -b, --branch VALUE   By default, the php-src Git repository branch to checkout
                       is automatically determined from the current
                       php-build-system Git repository branch name (e.g.
                       PHP-8.3). Defaults to "master", if can't be determined.
                       This option overrides the php-src branch name.
  -d, --debug          Debug mode. Here CMake profiling is enabled and debug
                       info displayed.
  -h, --help           Display this help and exit.
HELP
    exit 0
  fi

  if test "$1" = "-n" || test "$1" = "--no-update"; then
    update=0
  fi

  if test "$1" = "-c" || test "$1" = "--cmake"; then
    use_cmake=1
  fi

  if test "$1" = "-o" || test "$1" = "--options"; then
    options=$2
    shift
  fi

  if test "$1" = "-p" || test "$1" = "--preset"; then
    preset=$2
    shift
  fi

  if test "$1" = "-G"; then
    generator="$2"
    shift
  fi

  if test "$1" = "-b" || test "$1" = "--branch"; then
    branch=$2
    shift
  fi

  if test "$1" = "-d" || test "$1" = "--debug"; then
    debug=1
  fi

  shift
done

# Check requirements.
which=$(which which 2>/dev/null)
cmake=$(which cmake 2>/dev/null)
git=$(which git 2>/dev/null)
patch=$(which patch 2>/dev/null)

if test -z "$which"; then
  echo "init.sh: The 'which' command not found." >&2
  echo "         Please install coreutils." >&2
  exit 1
fi

if test -z "$cmake"; then
  echo "init.sh: The 'cmake' command not found." >&2
  echo "         Please install cmake:" >&2
  echo "         https://cmake.org" >&2
  echo "" >&2
fi

if test -z "$git"; then
  echo "init.sh: The 'git' command not found." >&2
  echo "         Please install Git:" >&2
  echo "         https://git-scm.com" >&2
  echo "" >&2
fi

if test -z "$patch"; then
  echo "init.sh: The 'patch' command not found." >&2
  echo "         Instead, the 'git' command will be used to apply patches." >&2
  echo "         Optionally install patch utilities:" >&2
  echo "         http://savannah.gnu.org/projects/patch" >&2
  echo "" >&2
fi

if test -z "${cmake}" \
  || test -z "${git}"
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
    $git clone https://github.com/php/php-src ./php-src
  else
    exit 1
  fi
fi

# Determine PHP branch from the current php-build-system repository branch.
if test -z "$branch"; then
  branch=$(git rev-parse --abbrev-ref HEAD)
  case $branch in
    PHP-[0-9]\.[0-9]*)
      ;;
    master)
      branch=master
      ;;
    *)
      echo "Unknown php-src branch $branch. Branch can be adjusted with:" >&2
      echo "'--branch PHP-X.Y' option" >&2
      exit 1
      ;;
  esac
fi

# Make sure we're in the php-src repository.
cd php-src

if test ! -f "main/php_version.h" \
  || test ! -f "php.ini-development"
then
  echo "Git repository doesn't seem to be php-src." >&2
  exit 1
fi

# Check if given branch is available.
if test -z "`"$git" show-ref refs/heads/${branch}`"; then
  if test -z "`"$git" ls-remote --heads origin refs/heads/${branch}`"; then
    echo "PHP branch ${branch} is missing." >&2
    exit 1
  fi

  "$git" checkout --track origin/${branch}
fi

# Reset php-src repository and fetch latest changes.
if test "$update" = "1"; then
  "$git" reset --hard
  "$git" clean -dffx
  "$git" checkout ${branch}
  "$git" pull --rebase
  echo
fi

cd ..

cp -r cmake/* php-src/

# Apply patches to php-src from the patches directory.
if test ${branch} = "master"; then
  php_version=$phpVersionDev
else
  php_version=$(echo $branch | sed 's/PHP-\([0-9.]*\).*$/\1/')
fi

patches=$(find ./patches/${php_version} -type f -name "*.patch" -prune 2>/dev/null)

if test -z "$patches"; then
  echo "No patches found."
else
  echo "Applying patches"
fi

for file in $patches; do
  case $file in
    *.patch)
      if test -n "$patch"; then
        "$patch" -p1 -d php-src < $file
      else
        "$git" apply $file --directory php-src
      fi
    ;;
  esac
done

# Only copy CMake files.
if test "x$use_cmake" = "x0"; then
  echo
  echo "PHP sources are ready to be built. Inside php-src, you can now run:
    cmake .
    cmake --build .
  "
  exit
fi

if test "$debug" = "1"; then
  cmake_debug_options="--debug-trycompile --profiling-output ./profile.json --profiling-format google-trace"
  cmake_verbose="--verbose"
fi

if test -n "$generator"; then
  generator_option="-G \"$generator\""
fi

# Check if make -j requires argument (Berkeley-based make implementations).
if make -h 2>&1 | grep -q "\[-j max_jobs\]" \
  || make -h 2>&1 | grep -q "\-j dmake_max_jobs"; then
  # Linux, illumos has nproc, macOS and some BSD-based systems have sysctl.
  if command -v nproc > /dev/null; then
    jobs=$(nproc)
  elif command -v sysctl > /dev/null; then
    jobs=$(sysctl -n hw.ncpu)
  fi
fi

if test -n "$jobs"; then
  jobs="-j $jobs"
else
  case $generator in
    Ninja*);;
    *) jobs=-j;;
  esac
fi

cd php-src

# Run CMake preset configuration.
eval "'$cmake' --preset $preset $cmake_debug_options $options $generator_option"

# Run build step using preset and jobs arguments passed after the arguments for
# exotic make implementations, such as dmake on illumos.
eval "'$cmake' --build --preset $preset $cmake_verbose -- $jobs"
