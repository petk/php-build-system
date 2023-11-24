#[=============================================================================[
Project-wide configuration options and variables that can be configured during
the configuration phase via GUI or command line:

  cmake -D PHP_OPTION=... -D ZEND_OPTION=... -D EXT_... -S <path-to-source> ...

To see the list of customizable configuration variables with help texts:
  cmake -LH <path-to-source>

For the preferred configuration customization, opt for CMake presets:
  cmake --preset <preset>
#]=============================================================================]

include(FeatureSummary)

################################################################################
# Customizable variables.
################################################################################

set(PHP_UNAME "" CACHE STRING "Build system uname")

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

set(PHP_BUILD_PROVIDER "" CACHE STRING "Build provider")

set(PHP_BUILD_COMPILER "" CACHE STRING "Compiler used for build")

set(PHP_BUILD_ARCH "" CACHE STRING "Build architecture")

set(
  PHP_LAYOUT "PHP"
  CACHE STRING
  "Set how installed files will be laid out. Type can be PHP (default) or GNU"
)
set_property(CACHE PHP_LAYOUT PROPERTY STRINGS "GNU" "PHP")

if(NOT PHP_LAYOUT STREQUAL "GNU")
  # TODO: DATAROOTDIR should be "php" instead of default "share".
endif()

set(
  PHP_EXTENSION_DIR ""
  CACHE PATH "The extension_dir PHP INI directive absolute path"
)

set(
  PHP_CONFIG_FILE_SCAN_DIR ""
  CACHE PATH "The path where to scan for additional INI configuration files"
)

set(
  PHP_CONFIG_FILE_PATH ""
  CACHE FILEPATH "The path in which to look for php.ini."
)

################################################################################
# General options.
################################################################################

option(PHP_RE2C_CGOTO "Enable computed goto GCC extension with re2c" OFF)

option(PHP_DEBUG_ASSERTIONS "Enable debug assertions in release mode" OFF)

option(PHP_THREAD_SAFETY "Enable thread safety (ZTS)" OFF)

option(PHP_USE_RTLD_NOW "Use dlopen with RTLD_NOW instead of RTLD_LAZY for extensions" OFF)

option(PHP_SIGCHILD "Enable PHP's own SIGCHLD handler" OFF)

option(PHP_SHORT_TAGS "Enable the short-form <? start tag by default" ON)

option(PHP_IPV6 "Enable IPv6 support" ON)

option(PHP_DMALLOC "Enable the Dmalloc memory debugger library" OFF)

option(PHP_DTRACE "Enable DTrace support" OFF)

set(PHP_FD_SETSIZE "" CACHE STRING "Size of descriptor sets")

option(PHP_VALGRIND "Enable the Valgrind support" OFF)

option(PHP_WERROR "Enable the -Werror compiler option" OFF)

option(PHP_MEMORY_SANITIZER "Enable the memory sanitizer compiler options (clang only)" OFF)

option(PHP_ADDRESS_SANITIZER "Enable the address sanitizer compiler option" OFF)

option(PHP_UNDEFINED_SANITIZER "Enable the undefined sanitizer compiler option" OFF)

option(PHP_GCOV "Enable GCOV code coverage and include GCOV symbols" OFF)

if(PHP_SHORT_TAGS)
  set(DEFAULT_SHORT_OPEN_TAG "1")
else()
  set(DEFAULT_SHORT_OPEN_TAG "0")
endif()

################################################################################
# Various global internal configuration.
################################################################################

# Minimum required version for the libxml2 dependency.
set(PHP_LIBXML2_MIN_VERSION 2.9.0)

# Minimum required version for the OpenSSL dependency.
set(PHP_OPENSSL_MIN_VERSION 1.0.2)

# Additional metadata for external packages to avoid duplication.
set_package_properties(BISON PROPERTIES
  URL "https://www.gnu.org/software/bison/"
  DESCRIPTION "General-purpose parser generator"
)

set_package_properties(BZip2 PROPERTIES
  URL "https://sourceware.org/bzip2/"
  DESCRIPTION "Block-sorting file compressor library"
)

set_package_properties(CURL PROPERTIES
  URL "https://curl.se/"
  DESCRIPTION "Library for transferring data with URLs"
)

set_package_properties(EXPAT PROPERTIES
  URL "https://libexpat.github.io/"
  DESCRIPTION "Stream-oriented XML parser library"
)

set_package_properties(Iconv PROPERTIES
  DESCRIPTION "Internationalization conversion library"
)

set_package_properties(ICU PROPERTIES
  URL "https://icu.unicode.org/"
  DESCRIPTION "International Components for Unicode"
)

set_package_properties(LibXml2 PROPERTIES
  URL "https://gitlab.gnome.org/GNOME/libxml2"
  DESCRIPTION "XML parser and toolkit"
)

set_package_properties(LibXslt PROPERTIES
  URL "https://gitlab.gnome.org/GNOME/libxslt"
  DESCRIPTION "XSLT processor library"
)

set_package_properties(OpenSSL PROPERTIES
  URL "https://www.openssl.org/"
  DESCRIPTION "General-purpose cryptography and secure communication"
)

set_package_properties(PostgreSQL PROPERTIES
  URL "https://www.postgresql.org/"
  DESCRIPTION "PostgreSQL database library"
)

set_package_properties(SQLite3 PROPERTIES
  URL "https://www.sqlite.org/"
  DESCRIPTION "SQL database engine library"
)

set_package_properties(ZLIB PROPERTIES
  URL "https://zlib.net/"
  DESCRIPTION "Compression library"
)
