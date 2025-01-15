include_guard(GLOBAL)

if(NOT PROJECT_NAME STREQUAL "PHP")
  message(
    AUTHOR_WARNING
    "${CMAKE_CURRENT_LIST_FILE} should be used in the project(PHP) scope."
  )
  return()
endif()

include(CMakePackageConfigHelpers)

write_basic_package_version_file(
  PHPConfigVersion.cmake
  COMPATIBILITY AnyNewerVersion
)

set(INSTALL_INCLUDE_DIR ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX})

configure_package_config_file(
  cmake/installation/PHPConfig.cmake.in
  PHPConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/PHP
  PATH_VARS
    INSTALL_INCLUDE_DIR
)

add_library(php_development INTERFACE)
add_library(PHP::Development ALIAS php_development)
set_target_properties(php_development PROPERTIES EXPORT_NAME Development)
target_include_directories(
  php_development
  INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/main>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Zend>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/TSRM>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/main>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/Zend>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/TSRM>
)
set_target_properties(php_development PROPERTIES EXPORT_NAME Development)

install(
  TARGETS php_development
  EXPORT PHP::Development
)

install(
  EXPORT PHP::Development
  FILE PHP_Development.cmake
  NAMESPACE PHP::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/PHP
  COMPONENT PHP::Development
)

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/PHPConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/PHPConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/PHP
  COMPONENT PHP::Development
)
