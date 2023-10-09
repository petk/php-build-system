include(CheckLibraryExists)
include(CMakeDependentOption)

option(EXT_GETTEXT "Whether to enable the gettext extension" OFF)

cmake_dependent_option(EXT_GETTEXT_SHARED "Whether to build the gettext extension as shared object" OFF "EXT_GETTEXT;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_GETTEXT)
  return()
endif()

if(EXT_GETTEXT_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "gettext" ${_library_type})

add_library(gettext ${_library_type}
  gettext.c
)

find_package(Intl REQUIRED)

if(Intl_IS_BUILT_IN)
  set(_intl_library "c")
else()
  set(_intl_library ${Intl_LIBRARIES})
endif()

set(HAVE_LIBINTL 1 CACHE INTERNAL "Whether gettext library is available")

check_library_exists(${_intl_library} ngettext "" HAVE_NGETTEXT)
check_library_exists(${_intl_library} dngettext "" HAVE_DNGETTEXT)
check_library_exists(${_intl_library} dcngettext "" HAVE_DCNGETTEXT)
check_library_exists(${_intl_library} bind_textdomain_codeset "" HAVE_BIND_TEXTDOMAIN_CODESET)

if(${Intl_LIBRARIES})
  target_link_libraries(gettext PRIVATE ${Intl_LIBRARIES})
endif()

if(${Intl_INCLUDE_DIRS})
  target_include_directories(gettext PRIVATE ${Intl_INCLUDE_DIRS})
endif()
