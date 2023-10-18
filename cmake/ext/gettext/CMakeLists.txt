include(CheckLibraryExists)
include(CMakeDependentOption)

option(EXT_GETTEXT "Whether to enable the gettext extension" OFF)

cmake_dependent_option(
  EXT_GETTEXT_SHARED
  "Whether to build the gettext extension as shared object"
  OFF
  "EXT_GETTEXT;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_GETTEXT)
  return()
endif()

if(EXT_GETTEXT_SHARED)
  set(_type "SHARED")
endif()

add_library(php_gettext ${_type}
  gettext.c
)

find_package(Intl REQUIRED)

target_link_libraries(php_gettext PRIVATE Intl::Intl)

set(HAVE_LIBINTL 1 CACHE INTERNAL "Whether gettext library is available")

check_library_exists(Intl::Intl ngettext "" HAVE_NGETTEXT)
check_library_exists(Intl::Intl dngettext "" HAVE_DNGETTEXT)
check_library_exists(Intl::Intl dcngettext "" HAVE_DCNGETTEXT)
check_library_exists(Intl::Intl bind_textdomain_codeset "" HAVE_BIND_TEXTDOMAIN_CODESET)
