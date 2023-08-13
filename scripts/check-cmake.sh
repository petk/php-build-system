#!/bin/sh
#
# Helper script that runs some common checks on CMake files and runs the
# cmakelint tool for CMake code issues, cmake-format for formatting issues.
#
# Checks:
#   - For unused CMake modules in the cmake/modules
#   - CMakeLint issues
#   - cmake-lint issues
#   - cmake-format issues

exit_code=0

# Check if cmakelint is installed.
cmakelint=$(which cmakelint 2>/dev/null)
if test -z "$cmakelint"; then
  echo "check-cmake.sh: cmakelint tool not found." >&2
  exit 1
fi

# Check if cmake-format is installed.
cmakeformat=$(which cmake-format 2>/dev/null)
if test -z "$cmakeformat"; then
  echo "check-cmake.sh: cmake-format tool not found." >&2
  exit 1
fi

# Go to project root.
cd $(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)

# Check for unused modules.
echo "Checking for unused modules"

modules=$(find ./cmake/cmake/modules -type f -name "PHP*.cmake")

for module in $modules; do
  module_name=$(basename $module | sed -e "s/.cmake$//")
  found=$(grep -Er "include\(${module_name}\)" cmake)
  if test -z "$found"; then
    echo "E: ${module_name} is not used" >&2
    exit_code=1
  fi
done

if test "$exit_code" = "0"; then
  echo "OK"
fi

echo

# Get a list of all CMake files.
files=$(find ./cmake -type f -name "*.cmake" -o -name "CMakeLists.txt")

# Run cmakelint. Some options are disabled and cmake-format checks them instead.
echo "Running cmakelint"
$cmakelint --filter=-linelength,-whitespace/indent $files
status=$?

if test "$status" != "0"; then
  exit_code=$status
fi

# Run cmake-lint from the cmakelang project.
cmake-lint $files
status=$?

if test "$status" != "0"; then
  exit_code=$status
fi

# Run cmake-format. Configuration file cmake-format.json is taken into account.
$cmakeformat --check $files
status=$?

if test "$status" != "0"; then
  exit_code=$status
fi

exit $exit_code
