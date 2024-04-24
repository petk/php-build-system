add_library(php_spl STATIC)

target_sources(
  php_spl
  PRIVATE
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
  PUBLIC
    FILE_SET HEADERS
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

target_compile_definitions(php_spl PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

add_dependencies(php_spl php_json php_pcre php_standard)
