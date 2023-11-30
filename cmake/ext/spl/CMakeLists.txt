add_library(php_spl STATIC
  php_spl.c
  spl_array.c
  spl_directory.c
  spl_dllist.c
  spl_exceptions.c
  spl_fixedarray.c
  spl_functions.c
  spl_heap.c
  spl_iterators.c
  spl_observer.c
)

target_compile_definitions(php_spl PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_sources(
  php_spl
  PUBLIC FILE_SET HEADERS
    BASE_DIRS "${PROJECT_SOURCE_DIR}"
    FILES
      php_spl.h
      spl_array.h
      spl_directory.h
      spl_dllist.h
      spl_engine.h
      spl_exceptions.h
      spl_fixedarray.h
      spl_functions.h
      spl_heap.h
      spl_iterators.h
      spl_observer.h
)

install(
  TARGETS php_spl
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
