#[=============================================================================[
Project-wide configuration options and variables that can be configured during
the configuration phase via GUI or command line:

  cmake -DPHP_<SOME_OPTION>=[ON|OFF] ... -S <source-dir> -B <build-dir> ...

To see the list of customizable configuration variables with help texts:
  cmake -LH <path-to-source>

For the preferred configuration customization, opt for CMake presets:
  cmake --preset <preset>
#]=============================================================================]

include_guard(GLOBAL)

include(CMakeDependentOption)
include(FeatureSummary)

set(PHP_UNAME "" CACHE STRING "Build system uname")
mark_as_advanced(PHP_UNAME)

if(CMAKE_UNAME AND NOT PHP_UNAME)
  execute_process(
    COMMAND ${CMAKE_UNAME} -a
    OUTPUT_VARIABLE PHP_UNAME
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
elseif(NOT PHP_UNAME AND CMAKE_HOST_SYSTEM)
  set_property(CACHE PHP_UNAME PROPERTY VALUE "${CMAKE_HOST_SYSTEM}")
endif()

set(PHP_BUILD_SYSTEM "${PHP_UNAME}" CACHE STRING "Build system uname")
mark_as_advanced(PHP_BUILD_SYSTEM)

set(
  PHP_BUILD_ARCH "${CMAKE_SYSTEM_PROCESSOR}"
  CACHE STRING "Build target architecture displayed in phpinfo"
)
mark_as_advanced(PHP_BUILD_ARCH)

set(
  PHP_BUILD_COMPILER "${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION}"
  CACHE STRING "Compiler used for build displayed in phpinfo"
)
mark_as_advanced(PHP_BUILD_COMPILER)

set(PHP_BUILD_PROVIDER "" CACHE STRING "Build provider displayed in phpinfo")
mark_as_advanced(PHP_BUILD_PROVIDER)

set(
  PHP_INCLUDE_PREFIX "php"
  CACHE STRING
  "The relative directory inside the CMAKE_INSTALL_INCLUDEDIR, where to install\
  PHP headers. For example, 'php/${PHP_VERSION}' to specify version or other\
  build-related characteristics and have multiple PHP versions installed.\
  Absolute paths are treated as relative; set CMAKE_INSTALL_INCLUDEDIR if\
  absolute path needs to be set."
)
mark_as_advanced(PHP_INCLUDE_PREFIX)

set(
  PHP_CONFIG_FILE_SCAN_DIR ""
  CACHE PATH "The path where to scan for additional INI configuration files; By\
  default it is empty value; Pass it as a relative path inside the install\
  prefix, which will be automatically prepended; If given as an absolute path,\
  install prefix is not prepended."
)
mark_as_advanced(PHP_CONFIG_FILE_SCAN_DIR)

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(
    PHP_CONFIG_FILE_PATH ""
    CACHE FILEPATH "The path in which to look for php.ini; By default, it is\
    set to SYSCONFDIR (etc); Relative path gets the CMAKE_INSTALL_PREFIX\
    automatically prepended; If given as an absolute path, install prefix is\
    not appended."
  )
  mark_as_advanced(PHP_CONFIG_FILE_PATH)
  if(NOT PHP_CONFIG_FILE_PATH)
    # TODO: Fix this for the 'cmake --install ... --prefix' case.
    set_property(
      CACHE PHP_CONFIG_FILE_PATH
      PROPERTY VALUE "${CMAKE_INSTALL_FULL_SYSCONFDIR}"
    )
  endif()
endif()

set(PHP_PROGRAM_PREFIX "" CACHE STRING "Prepend prefix to the program names")
mark_as_advanced(PHP_PROGRAM_PREFIX)

set(PHP_PROGRAM_SUFFIX "" CACHE STRING "Append suffix to the program names")
mark_as_advanced(PHP_PROGRAM_SUFFIX)

option(PHP_THREAD_SAFETY "Enable thread safety (ZTS)")

cmake_dependent_option(
  PHP_USE_RTLD_NOW
  "Use dlopen with the RTLD_NOW mode flag instead of RTLD_LAZY when loading\
  shared extensions"
  OFF
  [[NOT CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  OFF
)
mark_as_advanced(PHP_USE_RTLD_NOW)

cmake_dependent_option(
  PHP_SIGCHILD
  "Enable PHP's own SIGCHLD handler"
  OFF
  [[NOT CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  OFF
)
mark_as_advanced(PHP_SIGCHILD)

option(
  PHP_DEFAULT_SHORT_OPEN_TAG
  "Set the default value of 'short_open_tag' php.ini directive to 'On' to\
  enable short-form of opening PHP tags '<?'."
  ON
)
mark_as_advanced(PHP_DEFAULT_SHORT_OPEN_TAG)

option(PHP_IPV6 "Enable IPv6 support" ON)
mark_as_advanced(PHP_IPV6)

option(PHP_DMALLOC "Enable the Dmalloc memory debugger library")
mark_as_advanced(PHP_DMALLOC)

option(PHP_DTRACE "Enable DTrace support")
mark_as_advanced(PHP_DTRACE)

set(PHP_FD_SETSIZE "" CACHE STRING "Size of file descriptor sets")
if(CMAKE_SYSTEM_NAME STREQUAL "Windows" AND PHP_FD_SETSIZE STREQUAL "")
  set_property(CACHE PHP_FD_SETSIZE PROPERTY VALUE "256")
endif()
mark_as_advanced(PHP_FD_SETSIZE)

option(PHP_VALGRIND "Enable the Valgrind support")
mark_as_advanced(PHP_VALGRIND)

option(
  PHP_MEMORY_SANITIZER
  "Enable the memory sanitizer compiler options (Clang only)"
)
mark_as_advanced(PHP_MEMORY_SANITIZER)

option(PHP_ADDRESS_SANITIZER "Enable the address sanitizer compiler option")
mark_as_advanced(PHP_ADDRESS_SANITIZER)

option(PHP_UNDEFINED_SANITIZER "Enable the undefined sanitizer compiler option")
mark_as_advanced(PHP_UNDEFINED_SANITIZER)

option(PHP_GCOV "Enable GCOV code coverage and include GCOV symbols")
mark_as_advanced(PHP_GCOV)

option(PHP_LIBGCC "Explicitly link against libgcc")
mark_as_advanced(PHP_LIBGCC)

option(PHP_CCACHE "Use ccache if available on the system" ON)
mark_as_advanced(PHP_CCACHE)

################################################################################
# Set PHP_EXTENSION_DIR.
################################################################################

set(
  PHP_EXTENSION_DIR ""
  CACHE PATH
  "Default directory for dynamically loadable PHP extensions. If left empty, it\
  is determined automatically. Can be overridden using the PHP 'extension_dir'\
  INI directive."
)
mark_as_advanced(PHP_EXTENSION_DIR)

# Assemble the PHP_EXTENSION_DIR default value.
block()
  if(NOT PHP_EXTENSION_DIR)
    set(
      extensionDir
      "${CMAKE_INSTALL_LIBDIR}/php/$<TARGET_PROPERTY:Zend::Zend,ZEND_MODULE_API_NO>$<$<BOOL:$<TARGET_PROPERTY:PHP::config,PHP_THREAD_SAFETY>>:-zts>$<$<BOOL:$<CONFIG>>:-$<CONFIG>>"
    )

    # This would resemble the PHP Autotools --with-layout=GNU:
    #set(extensionDir "${CMAKE_INSTALL_LIBDIR}/php/$<TARGET_PROPERTY:Zend::Zend,ZEND_MODULE_API_NO>$<$<BOOL:$<TARGET_PROPERTY:PHP::config,PHP_THREAD_SAFETY>>:-zts>$<$<CONFIG:Debug,DebugAssertions>:-debug>")
    # This would resemble the PHP Autotools --with-layout=PHP (default):
    #set(extensionDir "${CMAKE_INSTALL_LIBDIR}/php/extensions/$<IF:$<CONFIG:Debug,DebugAssertions>,debug,no-debug>$<IF:$<BOOL:$<TARGET_PROPERTY:PHP::config,PHP_THREAD_SAFETY>>,-zts,-non-zts>-$<TARGET_PROPERTY:Zend::Zend,ZEND_MODULE_API_NO>")

    set_property(CACHE PHP_EXTENSION_DIR PROPERTY VALUE "${extensionDir}")
  endif()
endblock()

################################################################################
# Various global internal configuration.
################################################################################

# Minimum required version for the OpenSSL dependency.
set(PHP_OPENSSL_MIN_VERSION 1.0.2)

# Minimum required version for the SQLite dependency.
set(PHP_SQLITE_MIN_VERSION 3.7.7)

# Minimum required version for the PostgreSQL dependency.
set(PHP_POSTGRESQL_MIN_VERSION 9.1)

# Minimum required version for the zlib dependency.
set(PHP_ZLIB_MIN_VERSION 1.2.0.4)

# Minimum required version for the BZip2 dependency.
set(PHP_BZIP2_MIN_VERSION 1.0.0)

# Additional metadata for external packages to avoid duplication.
set_package_properties(
  BZip2
  PROPERTIES
    URL "https://sourceware.org/bzip2/"
    DESCRIPTION "Block-sorting file compressor library"
)

set_package_properties(
  CURL
  PROPERTIES
    URL "https://curl.se/"
    DESCRIPTION "Library for transferring data with URLs"
)

set_package_properties(
  EXPAT
  PROPERTIES
    URL "https://libexpat.github.io/"
    DESCRIPTION "Stream-oriented XML parser library"
)

set_package_properties(
  OpenSSL
  PROPERTIES
    URL "https://www.openssl.org/"
    DESCRIPTION "General-purpose cryptography and secure communication"
)

set_package_properties(
  PostgreSQL
  PROPERTIES
    URL "https://www.postgresql.org/"
    DESCRIPTION "PostgreSQL database library"
)

set_package_properties(
  SQLite3
  PROPERTIES
    URL "https://www.sqlite.org/"
    DESCRIPTION "SQL database engine library"
)

set_package_properties(
  ZLIB
  PROPERTIES
    URL "https://zlib.net/"
    DESCRIPTION "Compression library"
)

# Set base directory for ExternalProject CMake module.
set_directory_properties(
  PROPERTIES EP_BASE ${PHP_BINARY_DIR}/CMakeFiles/PHP/ExternalProject
)
