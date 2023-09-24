#!/bin/sh
#
# Helper script that runs some common checks on CMake files and runs the
# cmakelint tool for CMake code issues, cmake-format for formatting issues.
#
# Checks:
#   - For unused CMake find and utility modules in the cmake/modules folder
#   - CMakeLint issues
#   - cmake-lint issues
#   - cmake-format issues

exit_code=0

# Check requirements.
cmakelint=$(which cmakelint 2>/dev/null)
cmakelang_cmakelint=$(which cmake-lint 2>/dev/null)
cmakelang_cmakeformat=$(which cmake-format 2>/dev/null)

# Check if cmakelint is installed.
if test -z "$cmakelint"; then
  echo "check-cmake.sh: cmakelint tool not found." >&2
  echo "                Install cmakelint:" >&2
  echo "                https://github.com/cmake-lint/cmake-lint" >&2
  echo "" >&2
fi

# Check if cmakelang tools are installed.
if test -z "$cmakelang_cmakelint" \
  || test -z "$cmakelang_cmakeformat"
then
  echo "check-cmake.sh: cmakelang tools not found." >&2
  echo "                Install cmakelang:" >&2
  echo "                https://cmake-format.readthedocs.io" >&2
fi

if test -z "${cmakelint}" \
  || test -z "${cmakelang_cmakelint}" \
  || test -z "${cmakelang_cmakelint}"
then
  exit 1
fi

# Go to project root.
cd $(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)

# Check for unused utility modules.
echo "Checking for unused modules"

modules=$(find ./cmake/cmake/modules -maxdepth 2 -name "*.cmake" ! -name "Find*.cmake")
modules="${modules} "$(find ./cmake/cmake -maxdepth 1 -name "*.cmake")

for module in $modules; do
  module_name=$(basename $module | sed -e "s/.cmake$//")
  found=$(grep -Er "include\(.*${module_name}(\.cmake)?.?\)" cmake)

  if test -z "$found"; then
    echo "E: ${module} is not used" >&2
    exit_code=1
  fi
done

# Check for unused module artefacts.
module_items=$(find ./cmake/cmake/modules/PHP -mindepth 2)

for item in $module_items; do
  # Check if item is submodule.
  module_name=$(basename $item | sed -e "s/.cmake$//")
  found_included=$(grep -Er "include\(.*${module_name}(\.cmake)?.?\)" cmake)

  # Check if item is any other file.
  item_name=$(basename $item)
  found=$(grep -Er "${item_name}" cmake)

  if test -z "$found_included" && test -z "$found"; then
    echo "E: ${item} is not used" >&2
    exit_code=1
  fi
done

# Check for unused find modules.
find_modules=$(find ./cmake/cmake/modules -type f -name "Find*.cmake")

for module in $find_modules; do
  module_name=$(basename $module)
  package_name=$(echo ${module_name} | sed -e "s/Find\(.*\).cmake$/\1/")
  found=$(grep -Er "find_package\([[:space:]]*${package_name}.*" cmake)

  if test -z "$found"; then
    echo "E: ${module_name} is not used" >&2
    exit_code=1
  fi
done

test "$exit_code" = "0" && echo "OK"

# Get a list of all CMake files.
files=$(find ./cmake ./bin -type f -name "*.cmake" -o -name "CMakeLists.txt")

# Run cmakelint. Some options are disabled and cmake-format checks them instead.
echo
echo "Running cmakelint"
$cmakelint --filter=-linelength,-whitespace/indent $files
status=$?

test "$status" != "0" && exit_code=$status

# Run cmake-lint from the cmakelang project.
echo
echo "Running cmake-lint (cmakelang)"
$cmakelang_cmakelint --config-files cmake/cmake/cmake-format.json --suppress-decorations -- $files
status=$?

test "$status" != "0" && exit_code=$status

# Run cmake-format.
echo
echo "Running cmake-format (cmakelang)"
$cmakelang_cmakeformat --config-files cmake/cmake/cmake-format.json --check -- $files
#status=$?

#test "$status" != "0" && exit_code=$status

exit $exit_code
