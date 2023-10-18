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

# Link only what is needed on executables and shared objects.
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

# TODO: Set this in debug mode, maybe.
#set(CMAKE_VERBOSE_MAKEFILE ON)

################################################################################
# CMake custom properties.
################################################################################

define_property(
  DIRECTORY
  PROPERTY PHP_PRIORITY
  BRIEF_DOCS "Controls when to add subdirectory in the configuration phase"
  FULL_DOCS "Priority number can be used to add the extension subdirectory "
            "prior (0..98) or later (>=100) to other extensions. Default is "
            "99. Due to CMake nature, directory added with add_subdirectory() "
            "won't be visible in the configuration phase for the extensions "
            "added before. This enables having extension variables visible in "
            "depending extensions."
)

define_property(
  TARGET
  PROPERTY PHP_EXT_DEPENDS
  BRIEF_DOCS "A list of depending PHP extensions targets"
  FULL_DOCS "This property enables the specification of dependencies for PHP "
            "extension targets. When defining PHP extension targets, these "
            "dependencies are automatically enabled if they haven't been "
            "explicitly configured. If any of the specified dependencies are "
            "built as SHARED, the PHP extension target itself must also be "
            "built as SHARED. Failing to do so will result in a fatal error "
            "during the configuration phase."
)
