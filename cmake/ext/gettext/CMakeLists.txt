include(CheckLibraryExists)

option(gettext "Whether to enable the gettext extension" OFF)

if(NOT gettext)
  return()
endif()

find_package(Intl)

if(NOT Intl_FOUND)
  message(FATAL_ERROR "libintl not found")
endif()

if(Intl_IS_BUILT_IN)
  set(intl_library "c")
else()
  set(intl_library ${Intl_LIBRARIES})
endif()

set(HAVE_LIBINTL 1 CACHE INTERNAL "Whether gettext library is available")

check_library_exists(${intl_library} ngettext "" HAVE_NGETTEXT)
check_library_exists(${intl_library} dngettext "" HAVE_DNGETTEXT)
check_library_exists(${intl_library} dcngettext "" HAVE_DCNGETTEXT)
check_library_exists(${intl_library} bind_textdomain_codeset "" HAVE_BIND_TEXTDOMAIN_CODESET)

string(TOLOWER ${fileinfo} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "gettext" ${extension_library_type})

add_library(ext_gettext ${extension_library_type}
  gettext.c
)

if(${Intl_LIBRARIES})
  target_link_libraries(ext_gettext ${Intl_LIBRARIES})
endif()

if(${Intl_INCLUDE_DIRS})
  target_include_directories(ext_gettext PRIVATE ${Intl_INCLUDE_DIRS})
endif()
