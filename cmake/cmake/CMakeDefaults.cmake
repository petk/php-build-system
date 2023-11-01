#[=============================================================================[
Setting CMake defaults to manage how CMake works. These can be set before
calling the project().
#]=============================================================================]

# Set CMake module paths where include() and find_package() look for modules.
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules/")

# Automatically include current source or build tree for the current target.
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Put the source or build tree include directories before other includes.
set(CMAKE_INCLUDE_DIRECTORIES_PROJECT_BEFORE ON)

# Link only what is needed on executables and shared libraries.
set(CMAKE_LINK_WHAT_YOU_USE ON)

# Disable PIC for all targets. PIC is enabled for shared extensions manually.
set(CMAKE_POSITION_INDEPENDENT_CODE OFF)

# Set empty prefix for targets instead of default "lib".
set(CMAKE_SHARED_LIBRARY_PREFIX_C "")
set(CMAKE_SHARED_MODULE_PREFIX_C "")
set(CMAKE_STATIC_LIBRARY_PREFIX_C "")
set(CMAKE_SHARED_LIBRARY_PREFIX_CXX "")
set(CMAKE_SHARED_MODULE_PREFIX_CXX "")
set(CMAKE_STATIC_LIBRARY_PREFIX_CXX "")

# Set location where to put all shared libraries (.so or .dll files).
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/modules")

# TODO: Set this in debug mode, maybe.
#set(CMAKE_VERBOSE_MAKEFILE ON)
