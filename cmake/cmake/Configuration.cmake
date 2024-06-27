#[=============================================================================[
Project-wide configuration options and variables that can be configured during
the configuration phase via GUI or command line:

  cmake -D PHP_OPTION=... -D ZEND_OPTION=... -D EXT_... -S <path-to-source> ...

To see the list of customizable configuration variables with help texts:
  cmake -LH <path-to-source>

For the preferred configuration customization, opt for CMake presets:
  cmake --preset <preset>
#]=============================================================================]

include_guard(GLOBAL)

include(CMakeDependentOption)
include(FeatureSummary)

################################################################################
# Customizable variables.
################################################################################

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
  PHP_LAYOUT "PHP"
  CACHE STRING
  "Set how installed files will be laid out. Type can be PHP (default) or GNU"
)
set_property(CACHE PHP_LAYOUT PROPERTY STRINGS "GNU" "PHP")
mark_as_advanced(PHP_LAYOUT)

if(NOT PHP_LAYOUT STREQUAL "GNU")
  # TODO: DATAROOTDIR should be "php" instead of default "share".
endif()

set(
  PHP_EXTENSION_DIR ""
  CACHE PATH "The extension_dir PHP INI directive absolute path"
)
mark_as_advanced(PHP_EXTENSION_DIR)

set(
  PHP_CONFIG_FILE_SCAN_DIR ""
  CACHE PATH "The path where to scan for additional INI configuration files"
)
mark_as_advanced(PHP_CONFIG_FILE_SCAN_DIR)

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(
    PHP_CONFIG_FILE_PATH ""
    CACHE FILEPATH "The path in which to look for php.ini."
  )
  mark_as_advanced(PHP_CONFIG_FILE_PATH)

  if(NOT PHP_CONFIG_FILE_PATH)
    if(PHP_LAYOUT STREQUAL "GNU")
      set_property(
        CACHE PHP_CONFIG_FILE_PATH
        PROPERTY VALUE "${CMAKE_INSTALL_FULL_SYSCONFDIR}"
      )
    else()
      set_property(
        CACHE PHP_CONFIG_FILE_PATH
        PROPERTY VALUE "${CMAKE_INSTALL_FULL_LIBDIR}"
      )
    endif()
  endif()
endif()

set(PHP_PROGRAM_PREFIX "" CACHE STRING "Prepend prefix to the program names")
mark_as_advanced(PHP_PROGRAM_PREFIX)

set(PHP_PROGRAM_SUFFIX "" CACHE STRING "Append suffix to the program names")
mark_as_advanced(PHP_PROGRAM_SUFFIX)

################################################################################
# General options.
################################################################################

option(PHP_RE2C_CGOTO "Enable computed goto GCC extension with re2c" OFF)
mark_as_advanced(PHP_RE2C_CGOTO)

option(PHP_THREAD_SAFETY "Enable thread safety (ZTS)" OFF)

option(PHP_USE_RTLD_NOW "Use dlopen with RTLD_NOW instead of RTLD_LAZY for extensions" OFF)
mark_as_advanced(PHP_USE_RTLD_NOW)

cmake_dependent_option(
  PHP_SIGCHILD
  "Enable PHP's own SIGCHLD handler"
  OFF
  [[NOT CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  OFF
)
mark_as_advanced(PHP_SIGCHILD)

option(PHP_SHORT_TAGS "Enable the short-form <? start tag by default" ON)
mark_as_advanced(PHP_SHORT_TAGS)

option(PHP_IPV6 "Enable IPv6 support" ON)
mark_as_advanced(PHP_IPV6)

option(PHP_DMALLOC "Enable the Dmalloc memory debugger library" OFF)
mark_as_advanced(PHP_DMALLOC)

option(PHP_DTRACE "Enable DTrace support" OFF)
mark_as_advanced(PHP_DTRACE)

set(PHP_FD_SETSIZE "" CACHE STRING "Size of descriptor sets")
mark_as_advanced(PHP_FD_SETSIZE)

option(PHP_VALGRIND "Enable the Valgrind support" OFF)
mark_as_advanced(PHP_VALGRIND)

option(PHP_MEMORY_SANITIZER "Enable the memory sanitizer compiler options (clang only)" OFF)
mark_as_advanced(PHP_MEMORY_SANITIZER)

option(PHP_ADDRESS_SANITIZER "Enable the address sanitizer compiler option" OFF)
mark_as_advanced(PHP_ADDRESS_SANITIZER)

option(PHP_UNDEFINED_SANITIZER "Enable the undefined sanitizer compiler option" OFF)
mark_as_advanced(PHP_UNDEFINED_SANITIZER)

option(PHP_GCOV "Enable GCOV code coverage and include GCOV symbols" OFF)
mark_as_advanced(PHP_GCOV)

option(PHP_LIBGCC "Explicitly link against libgcc" OFF)
mark_as_advanced(PHP_LIBGCC)

option(PHP_CCACHE "Use ccache if available on the system" ON)
mark_as_advanced(PHP_CCACHE)

################################################################################
# Various global internal configuration.
################################################################################

# Minimum required version for the OpenSSL dependency.
set(PHP_OPENSSL_MIN_VERSION 1.1.1)

# Minimum required version for the SQLite dependency.
set(PHP_SQLITE_MIN_VERSION 3.7.7)

# Minimum required version for the PostgreSQL dependency.
set(PHP_POSTGRESQL_MIN_VERSION 10.0)

# Minimum required version for the zlib dependency.
set(PHP_ZLIB_MIN_VERSION 1.2.11)

# Minimum required version for the BZip2 dependency.
set(PHP_BZIP2_MIN_VERSION 1.0.0)

# Additional metadata for external packages to avoid duplication.
set_package_properties(
  BISON
  PROPERTIES
    URL "https://www.gnu.org/software/bison/"
    DESCRIPTION "General-purpose parser generator"
)

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

################################################################################
# Adjust configuration.
################################################################################

if(PHP_SHORT_TAGS)
  set(DEFAULT_SHORT_OPEN_TAG "1")
else()
  set(DEFAULT_SHORT_OPEN_TAG "0")
endif()

# Set default PHP_EXTENSION_DIR based on the layout used.
block()
  if(NOT PHP_EXTENSION_DIR)
    file(READ ${PHP_SOURCE_DIR}/Zend/zend_modules.h content)
    string(REGEX MATCH "#define ZEND_MODULE_API_NO ([0-9]*)" _ "${content}")
    set(zend_module_api_no ${CMAKE_MATCH_1})

    set(extension_dir "${CMAKE_INSTALL_FULL_LIBDIR}/php")

    if(PHP_LAYOUT STREQUAL "GNU")
      set(extension_dir "${extension_dir}/${zend_module_api_no}")

      # TODO: When apache2handler SAPI enforces the thread safe build (as done
      # in the Autotools), the PHP_THREAD_SAFETY variable isn't yet available.
      if(PHP_THREAD_SAFETY)
        set(extension_dir "${extension_dir}-zts")
      endif()

      if(PHP_DEBUG)
        set(extension_dir "${extension_dir}-debug")
      endif()
    else()
      set(extension_dir "${extension_dir}/extensions")

      if(PHP_DEBUG)
        set(extension_dir "${extension_dir}/debug")
      else()
        set(extension_dir "${extension_dir}/no-debug")
      endif()

      if(PHP_THREAD_SAFETY)
        set(extension_dir "${extension_dir}-zts")
      else()
        set(extension_dir "${extension_dir}-non-zts")
      endif()

      set(extension_dir "${extension_dir}-${zend_module_api_no}")
    endif()

    set_property(CACHE PHP_EXTENSION_DIR PROPERTY VALUE "${extension_dir}")
  endif()
endblock()
