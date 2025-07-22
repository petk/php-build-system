include_guard(GLOBAL)

option(PHP_USE_FETCHCONTENT "Use FetchContent for build-time dependencies." ON)
mark_as_advanced(PHP_USE_FETCHCONTENT)

option(PHP_DOWNLOAD_FORCE "Whether to download dependencies regardless if found on the system")

# Move package to PACKAGES_FOUND.
function(php_package_mark_as_found)
  set(package "${ARGV0}")
  get_property(packagesNotFound GLOBAL PROPERTY PACKAGES_NOT_FOUND)
  list(REMOVE_ITEM packagesNotFound ${package})
  set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND ${packagesNotFound})
  get_property(packagesFound GLOBAL PROPERTY PACKAGES_FOUND)
  list(FIND packagesFound ${package} found)
  if(found EQUAL -1)
    set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND ${package})
  endif()
endfunction()
