#!/bin/sh
#
# CMake initialization helper script.

update=0
use_cmake=0
options=""
preset="default"
debug=0
branch="PHP-8.3"

# Go to project root.
cd $(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)

while test $# -gt 0; do
  if test "$1" = "-h" || test "$1" = "--help"; then
    cat << HELP
PHP CMake initialization helper

SYNOPSIS:
  init.sh [<options>]

OPTIONS:
  -u, --update           Clone and/or pull the php-src Git repository.
  -c, --cmake            Run cmake configuration and build commands.
  -o, --options VALUE    CMake options which are appended to the CMake command.
                           cmake -DOPTION .
  -p, --preset VALUE     Use CMake preset with name VALUE, otherwise "default"
                         is used (see CMakePresets.json).
  -b, --branch VALUE     PHP branch to checkout. Defaults to PHP-8.3.
  -d, --debug            Debug mode. Here CMake profiling is enabled and debug
                         info displayed.
  -h, --help             Display this help.
HELP
    exit 0
  fi

  if test "$1" = "-u" || test "$1" = "--update"; then
    update=1
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
cmake=$(which cmake 2>/dev/null)

if test -z "$cmake"; then
  echo "init.sh: cmake not found." >&2
  echo "         Install cmake:" >&2
  echo "         https://cmake.org/" >&2
  echo "" >&2

  if test "x$use_cmake" = "x1"; then
    exit 1
  fi
fi

# Clone a fresh latest php-src repository.
if test ! -d "php-src"; then
  git clone --depth 1 https://github.com/php/php-src ./php-src
fi

# Check if given branch is available.
cd php-src
git fetch origin ${branch}:${branch}
if test -z "$(git show-ref refs/heads/${branch})"; then
  echo "Branch ${branch} is missing." >&2
  exit 1
fi

# Reset php-src repository and fetch latest changes.
if test "$update" = "1"; then
  git reset --hard
  git clean -dffx
  git checkout ${branch}
  git pull --rebase
  echo
fi
cd ..

cp -r cmake/* php-src/

# Apply patches to php-src from the patches directory.
if test ${branch} = "master"; then
  php_version=8.4
else
  php_version=$(echo $branch | sed 's/PHP-\([0-9.]*\).*$/\1/')
fi

patches=$(find ./patches/${php_version} -maxdepth 1 -type f -name "*.patch" 2>/dev/null)

for file in $patches; do
  case $file in
    *.patch)
      patch -p1 -d php-src < $file
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

if test "${debug}" = "1"; then
  cmake_debug_options="--debug-trycompile --profiling-output ./profile.json --profiling-format google-trace"
  cmake_verbose="--verbose"
fi

# Run CMake preset configuration and build.
cd php-src
$cmake --preset ${preset} ${cmake_debug_options} ${options}
$cmake --build --preset ${preset} $cmake_verbose -- -j $(nproc)
