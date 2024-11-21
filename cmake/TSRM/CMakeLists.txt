#[=============================================================================[
TSRM (Thread Safe Resource Manager) is a separate directory in php-src as it was
once a standalone project. Ideally, it should be moved into Zend Engine at some
point.
#]=============================================================================]

add_library(tsrm OBJECT)
add_library(TSRM::TSRM ALIAS tsrm)

target_sources(
  tsrm
  PRIVATE
    $<$<PLATFORM_ID:Windows>:tsrm_win32.c>
    TSRM.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        $<$<PLATFORM_ID:Windows>:tsrm_win32.h>
        TSRM.h
)

target_link_libraries(tsrm PRIVATE PHP::configuration)

target_include_directories(
  tsrm
  INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/TSRM>
)

target_compile_definitions(
  tsrm
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
  PUBLIC
    $<$<PLATFORM_ID:Windows>:TSRM_EXPORTS>
)

# Add TSRM PUBLIC/INTERFACE compile properties to configuration.
# Cleaner COMPILE_ONLY generator expression is available in CMake >= 3.27.
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.27)
  target_link_libraries(php_configuration INTERFACE $<COMPILE_ONLY:tsrm>)
else()
  target_include_directories(
    php_configuration
    INTERFACE
      $<TARGET_PROPERTY:tsrm,INTERFACE_INCLUDE_DIRECTORIES>
  )
  target_compile_definitions(
    php_configuration
    INTERFACE
      $<TARGET_PROPERTY:tsrm,INTERFACE_COMPILE_DEFINITIONS>
  )
endif()

install(
  TARGETS tsrm
  FILE_SET HEADERS
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/TSRM
)
