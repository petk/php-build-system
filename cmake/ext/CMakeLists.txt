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

  # Add extension's PUBLIC/INTERFACE compile properties to configuration.
  # Cleaner COMPILE_ONLY generator expression is available in CMake >= 3.27.
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.27)
    target_link_libraries(
      php_configuration
      INTERFACE
        $<COMPILE_ONLY:PHP::${extension}>
    )
  else()
    # TODO: Fix this better. Either require 3.27, or limit/adjust compile
    # properties propagated globally. Also, shared extensions shouldn't
    # propagate globally.
    # https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#id36
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

  get_target_property(type php_${extension} TYPE)
  get_target_property(isCli php_${extension} PHP_CLI)
  if(NOT type MATCHES "^(MODULE|SHARED)_LIBRARY$")
    # If extension is STATIC library link as whole archive, otherwise link
    # normally. CLI-based extensions are linked only to CLI-based SAPIs.
    if(NOT isCli)
      target_link_libraries(
        php_extensions
        INTERFACE
          $<IF:$<STREQUAL:$<TARGET_PROPERTY:PHP::${extension},TYPE>,STATIC_LIBRARY>,$<LINK_LIBRARY:WHOLE_ARCHIVE,PHP::${extension}>,PHP::${extension}>
      )

      target_sources(
        php_extensions
        INTERFACE
          # If extension is OBJECT library:
          $<$<STREQUAL:$<TARGET_PROPERTY:PHP::${extension},TYPE>,OBJECT_LIBRARY>:$<TARGET_OBJECTS:PHP::${extension}>>
          # If extension and linked target (SAPI) are both STATIC libraries:
          $<$<AND:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,STATIC_LIBRARY>,$<STREQUAL:$<TARGET_PROPERTY:PHP::${extension},TYPE>,STATIC_LIBRARY>>:$<TARGET_OBJECTS:PHP::${extension}>>
      )
    else()
      target_link_libraries(
        php_extensions
        INTERFACE
          $<$<BOOL:$<TARGET_PROPERTY:PHP_CLI>>:$<IF:$<STREQUAL:$<TARGET_PROPERTY:PHP::${extension},TYPE>,STATIC_LIBRARY>,$<LINK_LIBRARY:WHOLE_ARCHIVE,PHP::${extension}>,PHP::${extension}>>
      )

      target_sources(
        php_extensions
        INTERFACE
          # If extension is OBJECT library:
          $<$<BOOL:$<TARGET_PROPERTY:PHP_CLI>>:$<$<STREQUAL:$<TARGET_PROPERTY:PHP::${extension},TYPE>,OBJECT_LIBRARY>:$<TARGET_OBJECTS:PHP::${extension}>>>
          # If extension and linked target (SAPI) are both STATIC libraries:
          $<$<BOOL:$<TARGET_PROPERTY:PHP_CLI>>:$<$<AND:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,STATIC_LIBRARY>,$<STREQUAL:$<TARGET_PROPERTY:PHP::${extension},TYPE>,STATIC_LIBRARY>>:$<TARGET_OBJECTS:PHP::${extension}>>>
      )
    endif()
  endif()

  message(CHECK_PASS "enabled")
  list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endforeach()

get_property(extensions GLOBAL PROPERTY PHP_EXTENSIONS)
list(REVERSE extensions)
set_property(GLOBAL PROPERTY PHP_EXTENSIONS ${extensions})

# Reconfigure all enabled extensions at the end of the configuration phase.
cmake_language(DEFER DIRECTORY ${PHP_SOURCE_DIR} CALL php_extensions_configure_headers)
