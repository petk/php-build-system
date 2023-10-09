php_extension(NAME "spl" STATIC)

add_library(spl STATIC
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

target_compile_definitions(spl PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_sources(
  spl
  PUBLIC FILE_SET spl_headers
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
  TARGETS spl
  FILE_SET spl_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/spl
)
