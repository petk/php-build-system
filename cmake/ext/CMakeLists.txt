#[=============================================================================[
Add subdirectories of PHP extensions.

## INTERFACE target

* `php_extensions` (alias `PHP::extensions`) is an INTERFACE library with all
  enabled extensions linked into for convenience.
#]=============================================================================]

include(PHP/Extensions)

message(STATUS "")
message(STATUS "")
message(STATUS "Configuring PHP extensions")
message(STATUS "==========================")
message(STATUS "")

define_property(
  GLOBAL
  PROPERTY PHP_ALL_EXTENSIONS
  BRIEF_DOCS "A list of all PHP extensions in the ext directory"
)

define_property(
  GLOBAL
  PROPERTY PHP_ALWAYS_ENABLED_EXTENSIONS
  BRIEF_DOCS "A list of always enabled PHP extensions"
)

set_property(
  GLOBAL
  PROPERTY
    PHP_ALWAYS_ENABLED_EXTENSIONS
      date
      hash
      json
      pcre
      random
      reflection
      spl
      standard
)

define_property(
  GLOBAL
  PROPERTY PHP_EXTENSIONS
  BRIEF_DOCS "A list of enabled PHP extensions"
)

list(APPEND CMAKE_MESSAGE_CONTEXT "ext")

# Get a list of all PHP extensions in the current directory.
file(GLOB extensions ${CMAKE_CURRENT_SOURCE_DIR}/*/CMakeLists.txt)
list(TRANSFORM extensions REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/|/CMakeLists.txt" "")
set_property(GLOBAL PROPERTY PHP_ALL_EXTENSIONS ${extensions})

# Sort and preconfigure extensions by their dependencies.
php_extensions_preprocess(extensions)

add_library(php_extensions INTERFACE)
add_library(PHP::extensions ALIAS php_extensions)

# Add subdirectories of extensions.
foreach(extension IN LISTS extensions)
  list(APPEND CMAKE_MESSAGE_CONTEXT "${extension}")

  message(CHECK_START "Configuring extension ${extension}")
  list(APPEND CMAKE_MESSAGE_INDENT "  ")
  add_subdirectory("${extension}")
  php_extensions_postconfigure("${extension}")
  list(POP_BACK CMAKE_MESSAGE_INDENT)

  if(NOT TARGET php_${extension})
    message(CHECK_FAIL "disabled")
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
    continue()
  endif()

  set_property(GLOBAL APPEND PROPERTY PHP_EXTENSIONS ${extension})

  add_dependencies(php_${extension} Zend::Zend)

  # Add extension's transitive compile and link properties to configuration.
  # The INTERFACE_SOURCES are propagated separately only to PHP::PHP.
  # See: https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html
  # TODO: Should PHP_CLI extensions pass properties only to PHP_CLI SAPIs?
  get_target_property(type php_${extension} TYPE)
  if(NOT type MATCHES "^(MODULE|SHARED)_LIBRARY$")
    target_compile_definitions(
      php_configuration
      INTERFACE
        $<TARGET_PROPERTY:PHP::${extension},INTERFACE_COMPILE_DEFINITIONS>
    )

    target_compile_options(
      php_configuration
      INTERFACE
        $<TARGET_PROPERTY:PHP::${extension},INTERFACE_COMPILE_OPTIONS>
    )

    target_compile_features(
      php_configuration
      INTERFACE
        $<TARGET_PROPERTY:PHP::${extension},INTERFACE_COMPILE_FEATURES>
    )

    target_include_directories(
      php_configuration
      INTERFACE
        $<TARGET_PROPERTY:PHP::${extension},INTERFACE_INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:PHP::${extension},INTERFACE_SYSTEM_INCLUDE_DIRECTORIES>
    )

    target_link_libraries(
      php_extensions
      INTERFACE
        $<IF:$<BOOL:$<TARGET_GENEX_EVAL:PHP::${extension},$<TARGET_PROPERTY:PHP::${extension},PHP_CLI>>>,$<$<BOOL:$<TARGET_PROPERTY:PHP_CLI>>:$<LINK_ONLY:PHP::${extension}>>,$<LINK_ONLY:PHP::${extension}>>
    )

    target_sources(
      php_extensions
      INTERFACE
        $<IF:$<BOOL:$<TARGET_GENEX_EVAL:PHP::${extension},$<TARGET_PROPERTY:PHP::${extension},PHP_CLI>>>,$<$<BOOL:$<TARGET_PROPERTY:PHP_CLI>>:$<TARGET_OBJECTS:PHP::${extension}>>,$<TARGET_OBJECTS:PHP::${extension}>>

        $<IF:$<BOOL:$<TARGET_GENEX_EVAL:PHP::${extension},$<TARGET_PROPERTY:PHP::${extension},PHP_CLI>>>,$<$<BOOL:$<TARGET_PROPERTY:PHP_CLI>>:$<TARGET_PROPERTY:PHP::${extension},INTERFACE_SOURCES>>,$<TARGET_PROPERTY:PHP::${extension},INTERFACE_SOURCES>>
    )
  endif()

  target_link_libraries(php_${extension} PRIVATE PHP::configuration)

  # Add configuration compile options before the extension compile options.
  target_compile_options(
    php_${extension}
    BEFORE PRIVATE
      $<TARGET_PROPERTY:php_configuration,INTERFACE_COMPILE_OPTIONS>
  )

  message(CHECK_PASS "enabled")
  list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endforeach()

get_property(extensions GLOBAL PROPERTY PHP_EXTENSIONS)
list(REVERSE extensions)
set_property(GLOBAL PROPERTY PHP_EXTENSIONS ${extensions})

# Reconfigure all enabled extensions at the end of the configuration phase.
cmake_language(DEFER DIRECTORY ${PHP_SOURCE_DIR} CALL php_extensions_configure_headers)
