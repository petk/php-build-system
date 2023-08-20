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

# Check if cmake-lint (cmakelang) is installed.
cmakelang_cmakelint=$(which cmake-lint 2>/dev/null)
if test -z "$cmakelang_cmakelint"; then
  echo "check-cmake.sh: cmake-lint from cmakelang not found." >&2
  exit 1
fi

# Check if cmake-format is installed.
cmakelang_cmakeformat=$(which cmake-format 2>/dev/null)
if test -z "$cmakelang_cmakeformat"; then
  echo "check-cmake.sh: cmake-format from cmakelang not found." >&2
  exit 1
fi

# Go to project root.
cd $(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)

# Check for unused modules.
echo "Checking for unused modules"

modules=$(find ./cmake/cmake/modules -type f -name "PHP*.cmake")

for module in $modules; do
  module_name=$(basename $module | sed -e "s/.cmake$//")
  found=$(grep -Er "include\(.*${module_name}(\.cmake)?.?\)" cmake)
  if test -z "$found"; then
    echo "E: ${module_name} is not used" >&2
    exit_code=1
  fi
done

test "$exit_code" = "0" && echo "OK"

# Get a list of all CMake files.
files=$(find ./cmake ./scripts -type f -name "*.cmake" -o -name "CMakeLists.txt")

# Run cmakelint. Some options are disabled and cmake-format checks them instead.
echo "\nRunning cmakelint"
$cmakelint --filter=-linelength,-whitespace/indent $files
status=$?

test "$status" != "0" && exit_code=$status

# Run cmake-lint from the cmakelang project.
echo "\nRunning cmake-lint (cmakelang)"
$cmakelang_cmakelint $files
status=$?

test "$status" != "0" && exit_code=$status

# Run cmake-format. Configuration file cmake-format.json is taken into account.
echo "\nRunning cmake-format (cmakelang)"
$cmakelang_cmakeformat --check $files
status=$?

test "$status" != "0" && exit_code=$status

exit $exit_code
