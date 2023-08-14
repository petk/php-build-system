option(pdo "Whether to enable the PDO extension" ON)

if(NOT pdo)
  return()
endif()

re2c_target(
  NAME pdo_sql_parser.c
  INPUT "${CMAKE_CURRENT_SOURCE_DIR}/pdo_sql_parser.re"
  OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/pdo_sql_parser.c"
  OPTIONS "--no-generation-date"
)

string(TOLOWER ${pdo} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "pdo" ${extension_library_type})

add_library(ext_pdo ${extension_library_type}
  pdo.c
  pdo_dbh.c
  pdo_stmt.c
  pdo_sql_parser.c
  pdo_sqlstate.c
)

set_target_properties(ext_pdo PROPERTIES PUBLIC_HEADER "php_pdo.h;php_pdo_driver.h;php_pdo_error.h")
