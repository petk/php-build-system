#!/bin/sh
#
# Check redundant and missing CMake include() commands.

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

Checks redundant and missing CMake module include() invocations. It follows
the philosophy of "include what you use" - each CMake file should include only
those modules of which commands are used in it. Transitive includes should be
avoided. For example, where a CMake module is included in one CMake file and it
is then transitively used in other files via nested includes or similar.

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
  CheckCCompilerFlag
  CheckCompilerFlag
  CheckCSourceCompiles
  CheckCSourceRuns
  CheckCXXCompilerFlag
  CheckCXXSourceCompiles
  CheckCXXSourceRuns
  CheckCXXSymbolExists
  CheckFunctionExists
  CheckIncludeFile
  CheckIncludeFileCXX
  CheckIncludeFiles
  CheckIPOSupported
  CheckLanguage
  CheckLibraryExists
  CheckLinkerFlag
  CheckPrototypeDefinition
  CheckSourceCompiles
  CheckSourceRuns
  CheckStructHasMember
  CheckSymbolExists
  CheckTypeSize
  CheckVariableExists
  CMakeDependentOption
  CMakePushCheckState
  ExternalProject
  FeatureSummary
  FetchContent
  FindPackageHandleStandardArgs
  FindPackageMessage
  ProcessorCount

  PHP/CheckAttribute
  PHP/PkgConfigGenerator
  PHP/SearchLibraries
  PHP/SystemExtensions
"

# Commands contained in CMake modules.
CheckCCompilerFlag="check_c_compiler_flag"
CheckCompilerFlag="check_compiler_flag"
CheckCSourceCompiles="check_c_source_compiles"
CheckCSourceRuns="check_c_source_runs"
CheckCXXCompilerFlag="check_cxx_compiler_flag"
CheckCXXSourceCompiles="check_cxx_source_compiles"
CheckCXXSourceRuns="check_cxx_source_runs"
CheckCXXSymbolExists="check_cxx_symbol_exists"
CheckFunctionExists="check_function_exists"
CheckIncludeFile="check_include_file"
CheckIncludeFileCXX="check_include_file_cxx"
CheckIncludeFiles="check_include_files"
CheckIPOSupported="check_ipo_supported"
CheckLanguage="check_language"
CheckLibraryExists="check_library_exists"
CheckLinkerFlag="check_linker_flag"
CheckPrototypeDefinition="check_prototype_definition"
CheckSourceCompiles="check_source_compiles"
CheckSourceRuns="check_source_runs"
CheckStructHasMember="check_struct_has_member"
CheckSymbolExists="check_symbol_exists"
CheckTypeSize="check_type_size"
CheckVariableExists="check_variable_exists"
CMakeDependentOption="cmake_dependent_option"
CMakePushCheckState="
  cmake_pop_check_state
  cmake_push_check_state
  cmake_reset_check_state
"
ExternalProject="
  ExternalProject_Add
  ExternalProject_Add_Step
  ExternalProject_Add_StepDependencies
  ExternalProject_Add_StepTargets
  ExternalProject_Get_Property
"
FeatureSummary="
  add_feature_info
  feature_summary
  set_package_properties
"
FetchContent="
  FetchContent_Declare
  FetchContent_GetProperties
  FetchContent_MakeAvailable
  FetchContent_Populate
  FetchContent_SetPopulated
"
FindPackageHandleStandardArgs="
  find_package_check_version
  find_package_handle_standard_args
"
FindPackageMessage="find_package_message"
ProcessorCount="processorcount"

PHP_CheckAttribute="
  php_check_function_attribute
  php_check_variable_attribute
"
PHP_PkgConfigGenerator="pkgconfig_generate_pc"
PHP_SearchLibraries="php_search_libraries"
PHP_SystemExtensions='PHP::SystemExtensions'

if test -n "$directories"; then
  filesFound=$(find $directories -type f \
    -name "CMakeLists.txt" -o -name "*.cmake")
  status=$?
  test "x$status" != "x0" && exitCode=$status
fi

files="$files $filesFound"

for file in $files; do
  # Get file content and remove single and multi-line comments. Hash characters
  # inside quotes are not supported until more advanced parsing is needed.
  content=$(sed '/\#\[\=/,/\=\]\#/ d' $file | grep -a -o '^[^#]*')

  filename=$(basename $file)

  for module in $modules; do
    # Replace slashes for PHP local modules to get variable name with commands.
    moduleKey=$(echo $module | tr '/' '_')

    # Skip if current file is the current module in this loop.
    if test "PHP_$filename" = "$moduleKey.cmake"; then
      test "x$debug" = "x1" && echo "Skipping $file for checking $module"
      continue
    fi

    # Prepare AWK regex.
    unset regex
    commands=$(eval echo "\${$moduleKey}")
    for command in $commands; do
      test -n "$regex" && regex="$regex || "
      case "$command" in
        # Targets with double-colon:
        *\:\:*)
          regex="$regex /[[:blank:]]*$command[[:space:]]*/"
          ;;
        # All commands ending with opening parentheses:
        *)
          regex="$regex /^[[:blank:]]*$command[[:space:]]*\(/"
          ;;
      esac
    done

    foundModules=$(echo "$content" | grep -a -E "include\($module\)")
    foundCommands=$(echo "$content" | awk "$regex")

    # Check for redundant module includes.
    if test -n "$foundModules" && test -z "$foundCommands"; then
      echo "E: redundant include($module) in $file" >&2
      exitCode=1
    fi

    # Check for missing includes.
    if test -n "$foundCommands" && test -z "$foundModules"; then
      echo "E: missing include($module) in $file" >&2
      exitCode=1
    fi
  done
done

exit $exitCode
