option(bcmath "Whether to enable bc style precision math functions extension" OFF)

if(NOT bcmath)
  return()
endif()

string(TOLOWER ${bcmath} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "bcmath" ${extension_library_type})

add_library(ext_bcmath ${extension_library_type}
  bcmath.c
  libbcmath/src/add.c
  libbcmath/src/div.c
  libbcmath/src/init.c
  libbcmath/src/neg.c
  libbcmath/src/raisemod.c
  libbcmath/src/sub.c
  libbcmath/src/compare.c
  libbcmath/src/divmod.c
  libbcmath/src/int2num.c
  libbcmath/src/num2long.c
  libbcmath/src/output.c
  libbcmath/src/recmul.c
  libbcmath/src/sqrt.c
  libbcmath/src/zero.c
  libbcmath/src/debug.c
  libbcmath/src/doaddsub.c
  libbcmath/src/nearzero.c
  libbcmath/src/num2str.c
  libbcmath/src/raise.c
  libbcmath/src/rmzero.c
  libbcmath/src/str2num.c
)

target_include_directories(
  ext_bcmath
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
  PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/libbcmath/src"
)

target_compile_definitions(ext_bcmath PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
