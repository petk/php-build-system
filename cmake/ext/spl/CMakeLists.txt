php_extension(NAME "spl" STATIC)

add_library(ext_spl STATIC
  php_spl.c
  spl_functions.c
  spl_iterators.c
  spl_array.c
  spl_directory.c
  spl_exceptions.c
  spl_observer.c
  spl_dllist.c
  spl_heap.c
  spl_fixedarray.c
)

target_include_directories(
  ext_spl
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(ext_spl PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# TODO: check if this is really needed.
target_link_libraries(ext_spl PUBLIC ext_pcre ext_standard ext_json)

target_sources(
  ext_spl
  PUBLIC FILE_SET ext_spl_headers
  TYPE HEADERS
  FILES
    php_spl.h
    spl_array.h
    spl_directory.h
    spl_engine.h
    spl_exceptions.h
    spl_functions.h
    spl_iterators.h
    spl_observer.h
    spl_dllist.h
    spl_heap.h
    spl_fixedarray.h
)

install(
  TARGETS ext_spl
  FILE_SET ext_spl_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/spl
)
