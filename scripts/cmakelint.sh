#!/bin/sh
#
# Helper script that runs cmakelint tool on CMake files for code style issues.

options="--filter=-linelength"

# Check if cmakelint is installed.
cmakelint=$(which cmakelint 2>/dev/null)
if test -z "$cmakelint"; then
  echo "cmakelint.sh: cmakelint tool not found." >&2
  exit 1
fi

# Go to project root.
cd $(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)

# Get a list of all CMake files.
files=$(find ./cmake -type f -name "*.cmake" -o -name "CMakeLists.txt")

# Run cmakelint.
$cmakelint $options $files
