#!/bin/sh
#
# Script for updating minimum required CMake version.
#
# Usage:
#
# * Update CMake minimum version, policy max version, CMake presets version
#   and presets schema URL in cmake/cmake/scripts/UpdateCMake.cmake script.
#
# * Run this script as: ./bin/update-cmake.sh

# Go to project root.
cd "$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd -P)" || exit

script=./cmake/cmake/scripts/UpdateCMake.cmake

# Get minimum required CMake version.
version_min=$(sed -n 's/^set(version_min \([0-9][0-9]*\.[0-9][0-9]*\)).*/\1/p' $script)

# Update versions in CMake files.
${script} -- CMakeLists.txt CMakePresets.json cmake

# Update CMake version in README.md file.
file="README.md"
echo "-- Updating $file"
sed -i.bak "s/CMake-[0-9][0-9]*\.[0-9][0-9]*-/CMake-${version_min}-/g" "${file}" && rm "$file.bak"
