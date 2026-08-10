#[=============================================================================[
Add subdirectories of PHP SAPIs.
#]=============================================================================]

message(STATUS "")
message(STATUS "")
message(STATUS "Configuring PHP SAPI modules")
message(STATUS "============================")
message(STATUS "")

define_property(
  GLOBAL
  PROPERTY PHP_ALL_SAPIS
  BRIEF_DOCS "A list of all PHP SAPIs in the sapi directory"
)

define_property(
  GLOBAL
  PROPERTY PHP_ENABLED_SAPIS
  BRIEF_DOCS "A list of all enabled PHP SAPIs"
)

list(APPEND CMAKE_MESSAGE_CONTEXT "sapi")

# Enable symbols exporting for executable and shared SAPIs.
set(CMAKE_EXECUTABLE_ENABLE_EXPORTS TRUE)
set(CMAKE_SHARED_LIBRARY_ENABLE_EXPORTS TRUE)

# Traverse CMakeLists.txt files of PHP SAPIs.
file(GLOB sapis ${CMAKE_CURRENT_SOURCE_DIR}/*/CMakeLists.txt)
list(TRANSFORM sapis REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/|/CMakeLists.txt" "")
set_property(GLOBAL PROPERTY PHP_ALL_SAPIS ${sapis})

# Add subdirectories of SAPIs.
foreach(sapi IN LISTS sapis)
  list(APPEND CMAKE_MESSAGE_CONTEXT "${sapi}")
  message(CHECK_START "Configuring SAPI ${sapi}")
  list(APPEND CMAKE_MESSAGE_INDENT "  ")

  add_subdirectory("${sapi}")

  list(POP_BACK CMAKE_MESSAGE_INDENT)
  if(TARGET php_sapi_${sapi})
    set_property(GLOBAL APPEND PROPERTY PHP_ENABLED_SAPIS ${sapi})
    message(CHECK_PASS "enabled")
  else()
    message(CHECK_FAIL "disabled")
  endif()
  list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endforeach()

# Add FastCGI target with objects for use in PHP SAPIs such as CGI and FPM.
add_library(php_sapi_common_fastcgi OBJECT ../main/fastcgi.c)
target_compile_definitions(
  php_sapi_common_fastcgi
  PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE
)
target_link_libraries(php_sapi_common_fastcgi PRIVATE PHP::config)
set_target_properties(php_sapi_common_fastcgi PROPERTIES EXCLUDE_FROM_ALL TRUE)

# Check if at least one SAPI is enabled.
get_property(sapis GLOBAL PROPERTY PHP_ENABLED_SAPIS)
if(NOT sapis)
  message(
    WARNING
    "None of the PHP SAPIs have been enabled. If this is intentional, you can "
    "disregard this warning."
  )
endif()
