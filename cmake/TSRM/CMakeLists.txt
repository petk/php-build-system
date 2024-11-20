#[=============================================================================[
TSRM (Thread Safe Resource Manager) is a separate directory in php-src as it was
once a standalone project. Ideally, it should be integrated into Zend Engine.

The TSRM::TSRM target is used to transitively pass the TSRM object(s) and
compile options to Zend Engine, which propagates it further as needed.
#]=============================================================================]

add_library(tsrm_object OBJECT)
add_library(tsrm INTERFACE)
add_library(TSRM::TSRM ALIAS tsrm)

target_link_libraries(
  tsrm
  INTERFACE
    tsrm_object
    $<TARGET_OBJECTS:tsrm_object>
)

target_sources(
  tsrm_object
  PRIVATE
    $<$<PLATFORM_ID:Windows>:tsrm_win32.c>
    TSRM.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        $<$<PLATFORM_ID:Windows>:tsrm_win32.h>
        TSRM.h
)

target_link_libraries(tsrm_object PRIVATE PHP::configuration)

target_include_directories(
  tsrm_object
  INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/TSRM>
)

target_compile_definitions(
  tsrm_object
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
  PUBLIC
    $<$<PLATFORM_ID:Windows>:TSRM_EXPORTS>
)

install(
  TARGETS tsrm_object
  FILE_SET HEADERS
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/TSRM
)
