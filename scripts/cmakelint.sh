#!/bin/sh
#
# Helper script that runs some common checks on CMake files and runs the
# cmakelint tool for code style issues.
#
# Checks:
#   - For unused CMake modules in the cmake/modules.
#   - All CMakeLint options except the line length limits.

options="--filter=-linelength"
exit_code=0

# Check if cmakelint is installed.
cmakelint=$(which cmakelint 2>/dev/null)
if test -z "$cmakelint"; then
  echo "cmakelint.sh: cmakelint tool not found." >&2
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

# Run cmakelint.
echo "Running cmakelint"
$cmakelint $options $files
cmakelint_status=$?

if test "$cmakelint_status" != "0"; then
  exit_code=$cmakelint_status
fi

exit $exit_code
