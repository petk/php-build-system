#!/bin/sh
#
# Helper for checking redundant and missing CMake module includes. Module
# follows philosophy of "include what you use" - each CMake file should have
# those include() calls of which modules are used in them.

# Initial values.
debug=0
directories=
exitCode=0
files=
paths=

while test $# -gt 0; do
  if test "$1" = "-h" || test "$1" = "--help"; then
    cat << HELP
CMake module includes checker

SYNOPSIS:
  $0 [<options>] <path...>

OPTIONS:
  -d, --debug          Output additional debug mode information.
  -h, --help           Display this help and exit.
HELP
    exit 0
  elif test "$1" = "-d" || test "$1" = "--debug"; then
    debug=1
  elif test "x$1" != "x"; then
    paths="$paths $1"
  fi

  shift
done

if test -z "$paths"; then
  echo "Usage: $0 [options] <path...>" >&2
  echo "See $0 --help for more information" >&2
  exit 1
fi

for path in $paths; do
  if test -d "$path"; then
    directories="$directories $path"
  elif test -f "$path"; then
    files="$files $path"
  else
    echo "E: Given path $path not found" >&2
    exitCode=1
  fi
done

# CMake modules.
modules="
  CheckCompilerFlag
  CheckFunctionExists
  CheckIncludeFile
  CheckIncludeFiles
  CheckLibraryExists
  CheckLinkerFlag
  CheckSourceCompiles
  CheckSourceRuns
  CheckStructHasMember
  CheckSymbolExists
  CheckTypeSize
  CMakeDependentOption
  CMakePushCheckState
  FeatureSummary
  FindPackageHandleStandardArgs
  ProcessorCount

  PHP/SearchLibraries
"

# Commands contained in CMake modules.
CheckCompilerFlag="check_compiler_flag"
CheckFunctionExists="check_function_exists"
CheckIncludeFile="check_include_file"
CheckIncludeFiles="check_include_files"
CheckLibraryExists="check_library_exists"
CheckLinkerFlag="check_linker_flag"
CheckSourceCompiles="check_source_compiles"
CheckSourceRuns="check_source_runs"
CheckStructHasMember="check_struct_has_member"
CheckSymbolExists="check_symbol_exists"
CheckTypeSize="check_type_size"
CMakeDependentOption="cmake_dependent_option"
CMakePushCheckState="
  cmake_pop_check_state
  cmake_push_check_state
  cmake_reset_check_state
"
FeatureSummary="
  feature_summary
  set_package_properties
  add_feature_info
"
FindPackageHandleStandardArgs="
  find_package_handle_standard_args
  find_package_check_version
"
ProcessorCount="processorcount"

PHP_SearchLibraries="php_search_libraries"

if test -n "$directories"; then
  filesFound=$(find $directories -type f \
    -name "CMakeLists.txt" -o -name "*.cmake")
  status=$?
  test "x$status" != "x0" && exitCode=$status
fi

files="$files $filesFound"

for module in $modules; do
  # Replace slashes for PHP local modules to get variable name with commands.
  moduleKey=$(echo $module | tr '/' '_')

  commands=$(eval echo "\${$moduleKey}")

  # Prepare AWK regex.
  unset regex
  for command in $commands; do
    test -n "$regex" && regex="$regex || "
    regex="$regex /^[[:blank:]]*$command[[:space:]]*\(/"
  done

  for file in $files; do
    # Remove all single-line comments. Hash characters inside quotes and bracket
    # arguments are not supported until more advanced parsing is needed.
    content=$(grep -o '^[^#]*' $file)

    # Check for redundant module includes.
    found=$(echo "$content" | grep -a -E "include\($module\)")
    if test -n "$found"; then
      found=$(echo "$content" | awk "$regex")
      if test -z "$found"; then
        echo "E: redundant include($module) in $file" >&2
        exitCode=1
      fi
    fi

    # Skip if current file is the current module in this loop.
    filename=$(basename $file)
    if test "PHP_$filename" = "$moduleKey.cmake"; then
      test "x$debug" = "x1" && echo "Skipping $file for checking $command"
      continue
    fi

    # Check for missing includes.
    found=$(echo $content | awk "$regex")
    if test -n "$found"; then
      found=$(echo $content | grep -a -E "include\($module\)")
      if test -z "$found"; then
        echo "E: missing include($module) in $file" >&2
        exitCode=1
      fi
    fi
  done
done

exit $exitCode
