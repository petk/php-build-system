#!/bin/sh
#
# Helper script that runs a set of common checks on CMake files.

enableCMakeLint=0
enableCMakeLang=0
exitCode=0

################################################################################
# Parse options and arguments.
################################################################################

while test $# -gt 0; do
  if test "$1" = "-h" || test "$1" = "--help"; then
    cat << HELP
CMake code checker

SYNOPSIS:
  $0 [<options>]

OPTIONS:
  -d, --debug    Output additional debug mode information.
  -h, --help     Display this help and exit.
  --cmakelint    Run CMake cmakelint tool.
  --cmakelang    Run CMake-lang project tools (cmake-lint and cmake-format).

Checks:
  - Unused CMake find and utility module files
  - Missing and redundant CMake module includes
  - CMakeLint for CMake code issues
  - cmake-lint for CMake code issues
  - cmake-format for CMake code style issues
  - codespell for common misspelling issues
  - Basic Git repository and code style issues with github.com/petk/normalizator

USAGE:
  $0 [<options>]
HELP
    exit 0
  elif test "$1" = "-d" || test "$1" = "--debug"; then
    debug=1
  elif test "$1" = "--cmakelint"; then
    enableCMakeLint=1
  elif test "$1" = "--cmakelang"; then
    enableCMakeLang=1
  fi

  shift
done

################################################################################
# Check requirements.
################################################################################

cmakelint=$(which cmakelint 2>/dev/null)
cmakelang_cmakelint=$(which cmake-lint 2>/dev/null)
cmakelang_cmakeformat=$(which cmake-format 2>/dev/null)
codespell=$(which codespell 2>/dev/null)
normalizator=$(which normalizator 2>/dev/null)

# Check if cmakelint is installed.
if test "x$enableCMakeLint" = "x1" && test -z "$cmakelint"; then
  echo "check-cmake.sh: The 'cmakelint' tool not found." >&2
  echo "                Please install cmakelint:" >&2
  echo "                https://github.com/cmake-lint/cmake-lint" >&2
  echo "" >&2
fi

# Check if cmakelang tools are installed.
if test "x$enableCMakeLang" = "x1" \
  && (test -z "$cmakelang_cmakelint" \
  || test -z "$cmakelang_cmakeformat")
then
  echo "check-cmake.sh: The 'cmakelang' tools not found." >&2
  echo "                Please install cmakelang:" >&2
  echo "                https://cmake-format.readthedocs.io" >&2
fi

# Check if codespell is installed.
if test -z "${codespell}"; then
  echo "check-cmake.sh: The 'codespell' tool not found." >&2
  echo "                Please install codespell:" >&2
  echo "                https://github.com/codespell-project/codespell" >&2
fi

# Check if find -maxdepth option works (for example, Solaris doesn't have it).
findMaxdepthOptionWorks=$(find ./cmake/cmake -maxdepth 1 -name "*.cmake" 2>/dev/null)
test "x$?" != "x0" && findMaxdepthOptionWorks=
if test -z "$findMaxdepthOptionWorks"; then
  echo "check-cmake.sh: Unsupported system. The 'find' command doesn't have" >&2
  echo "                the '-maxdepth' option. Please use another system." >&2
fi

if (test "x$enableCMakeLint" = "x1" && test -z "${cmakelint}") \
  || (test "x$enableCMakeLang" = "x1" && \
     (test -z "${cmakelang_cmakelint}" || test -z "${cmakelang_cmakeformat}")) \
  || test -z "${codespell}" \
  || test -z "${findMaxdepthOptionWorks}"
then
  exit 1
fi

# Go to project root.
cd $(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)

################################################################################
# Check for unused CMake module files.
################################################################################

echo "Checking for unused CMake module files"

modules=$(find ./cmake/cmake/modules -maxdepth 2 -name "*.cmake" ! -name "Find*.cmake")
modules="${modules} "$(find ./cmake/cmake -maxdepth 1 -name "*.cmake")

for module in $modules; do
  moduleName=$(basename $module | sed -e "s/.cmake$//")
  found=$(grep -Er "include\(.*${moduleName}(\.cmake)?.?\)" cmake)

  if test -z "$found"; then
    echo "E: ${module} is not used" >&2
    exitCode=1
  fi
done

# Check for unused module artifacts.
moduleItems=$(find ./cmake/cmake/modules/PHP -mindepth 2)

for item in $moduleItems; do
  # Check if item is submodule.
  moduleName=$(basename $item | sed -e "s/.cmake$//")
  foundIncluded=$(grep -Er "include\(.*${moduleName}(\.cmake)?.?\)" cmake)

  # Check if item is any other file.
  itemName=$(basename $item)
  found=$(grep -Er "${itemName}" cmake)

  if test -z "$foundIncluded" && test -z "$found"; then
    echo "E: ${item} is not used" >&2
    exitCode=1
  fi
done

# Check for unused find modules.
find_modules=$(find ./cmake/cmake/modules -type f -name "Find*.cmake")

for module in $find_modules; do
  moduleName=$(basename $module)
  packageName=$(echo ${moduleName} | sed -e "s/Find\(.*\).cmake$/\1/")
  found=$(grep -Er "find_package\([[:space:]]*${packageName}.*" cmake)

  if test -z "$found"; then
    echo "E: ${moduleName} is not used" >&2
    exitCode=1
  fi
done

test "x$exitCode" = "x0" && echo "OK"

################################################################################
# Check CMake includes.
################################################################################

echo
echo "Checking CMake includes"
./bin/check-cmake/cmake-includes.sh cmake
status=$?
test "x$status" != "x0" && exitCode=$status || echo "OK"

################################################################################
# Run codespell.
################################################################################

echo
echo "Running codespell"
$codespell \
  --config bin/check-cmake/.codespellrc \
  .github \
  bin \
  cmake \
  docs \
  .editorconfig \
  .gitignore \
  README.md

status=$?
test "x$status" != "x0" && exitCode=$status || echo "OK"

################################################################################
# Run cmakelint, cmake-lint, and cmake-format tools.
################################################################################

# Get a list of all CMake files.
files=$(find ./cmake ./bin -type f -name "*.cmake" -o -name "CMakeLists.txt")

# Run cmakelint. Some options are disabled and cmake-format checks them instead.
if test "x$enableCMakeLint" != "x0"; then
  echo
  echo "Running cmakelint"
  $cmakelint \
    --filter=-linelength,-whitespace/indent,-convention/filename,-package/stdargs \
    $files
  status=$?
  test "x$status" != "x0" && exitCode=$status
fi

# Run cmake-lint and cmake-format from the cmakelang project.
if test "x$enableCMakeLang" != "x0"; then
  # cmake-lint
  echo
  echo "Running cmake-lint (cmakelang)"
  $cmakelang_cmakelint \
    --config-files bin/check-cmake/cmake-format.json \
    --suppress-decorations \
    -- $files
  status=$?
  test "x$status" != "x0" && exitCode=$status

  # cmake-format.
  echo
  echo "Running cmake-format (cmakelang)"
  $cmakelang_cmakeformat \
    --config-files bin/check-cmake/cmake-format.json \
    --check \
    -- $files
  status=$?
  test "x$status" != "x0" && exitCode=$status
fi

################################################################################
# Run normalizator.phar.
################################################################################

if test -n "$normalizator"; then
  echo
  echo "Running normalizator.phar"
  paths=$(find . -maxdepth 1 -name "*" -not -path "./php-src" -a -not -path ".")
  $normalizator check $paths
  status=$?
  test "x$status" != "x0" && exitCode=$status
fi

exit $exitCode
