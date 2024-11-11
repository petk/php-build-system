#[=============================================================================[
Add subdirectories of PHP extensions.

## INTERFACE target

* `PHP::extensions` (`php_extensions`) is an INTERFACE library with all enabled
  extensions linked.

## Custom CMake properties

* `PHP_ALL_EXTENSIONS`

  Global property with a list of all PHP extensions in the ext directory.

* `PHP_ALWAYS_ENABLED_EXTENSIONS`

  Global property with a list of always enabled PHP extensions which can be
  considered part of the core PHP engine.

* `PHP_EXTENSIONS`

  Global property with a list of all enabled PHP extensions for the current
  configuration. Extensions are sorted by their dependencies (extensions added
  with CMake command `add_dependencies()`).
#]=============================================================================]

include(PHP/Extensions)

message(STATUS "--------------------------")
message(STATUS "Configuring PHP extensions")
message(STATUS "--------------------------\n")

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
  if(TARGET php_${extension})
    set_property(GLOBAL APPEND PROPERTY PHP_EXTENSIONS ${extension})

    # Add extension's PUBLIC/INTERFACE compile options to configuration.
    # Cleaner COMPILE_ONLY generator expression is available in CMake >= 3.27.
    if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.27)
      target_link_libraries(
        php_configuration
        INTERFACE
          $<COMPILE_ONLY:PHP::${extension}>
      )
    else()
      target_include_directories(
        php_configuration
        INTERFACE
          $<TARGET_PROPERTY:PHP::${extension},INTERFACE_INCLUDE_DIRECTORIES>
      )
    endif()

    target_link_libraries(php_${extension} PRIVATE PHP::configuration)

    # Add configuration compile options before the extension compile options.
    target_compile_options(
      php_${extension}
      BEFORE PRIVATE
        $<TARGET_PROPERTY:php_configuration,INTERFACE_COMPILE_OPTIONS>
    )

    add_dependencies(php_${extension} zend)

    get_target_property(type php_${extension} TYPE)
    if(NOT type MATCHES "^(MODULE|SHARED)_LIBRARY$")
      target_link_libraries(php_extensions INTERFACE PHP::${extension})
    endif()

    message(CHECK_PASS "enabled")
  else()
    message(CHECK_FAIL "disabled")
  endif()
  list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endforeach()

get_cmake_property(extensions PHP_EXTENSIONS)
list(REVERSE extensions)
set_property(GLOBAL PROPERTY PHP_EXTENSIONS ${extensions})

# Reconfigure all enabled extensions at the end of the configuration phase.
cmake_language(DEFER DIRECTORY ${PHP_SOURCE_DIR} CALL php_extensions_configure_headers)
