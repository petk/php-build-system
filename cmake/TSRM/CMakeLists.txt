#[=============================================================================[
TSRM (Thread Safe Resource Manager) is a separate directory in php-src as it was
once a standalone project. Ideally, it should be integrated into Zend Engine.

The `TSRM::TSRM` target is used to transitively pass the TSRM object(s) and
compile options to Zend Engine, which propagates it further as needed.
#]=============================================================================]

add_library(tsrm OBJECT)
add_library(tsrm_interface INTERFACE)
add_library(TSRM::TSRM ALIAS tsrm_interface)
target_link_libraries(
  tsrm_interface
  INTERFACE
    tsrm
    $<TARGET_OBJECTS:tsrm>
)

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

install(
  TARGETS tsrm
  FILE_SET HEADERS
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/TSRM
)
