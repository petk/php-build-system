#[=============================================================================[
Setting CMake defaults to manage how CMake works. These can be set before
calling the project().
#]=============================================================================]

# Set the module path to include the directory containing custom modules.
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules/")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/")

# Disable PIC for all targets. PIC should can be enabled for shared extensions
# manually.
set(CMAKE_POSITION_INDEPENDENT_CODE OFF)

# Set empty prefix for targets instead of default "lib".
set(CMAKE_SHARED_LIBRARY_PREFIX_C "")
set(CMAKE_STATIC_LIBRARY_PREFIX_C "")
set(CMAKE_SHARED_MODULE_PREFIX_C "")
set(CMAKE_SHARED_LIBRARY_PREFIX_CXX "")
set(CMAKE_SHARED_MODULE_PREFIX_CXX "")
set(CMAKE_STATIC_LIBRARY_PREFIX_CXX "")

# TODO: Set this in debug mode, maybe.
#set(CMAKE_VERBOSE_MAKEFILE ON)
