
message(STATUS "")
message(STATUS "")
message(STATUS "Configuring PHP extensions")
message(STATUS "==========================")
message(STATUS "")

include(PHP/Internal/Extensions)

################################################################################
# CMake custom properties.
################################################################################

define_property(
  TARGET
  PROPERTY PHP_ZEND_EXTENSION
  BRIEF_DOCS "Whether the PHP extension target is Zend extension"
)

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

################################################################################
# Configuration.
################################################################################

list(APPEND CMAKE_MESSAGE_CONTEXT "ext")

# Get a list of all PHP extensions in the current directory.
file(GLOB extensions ${CMAKE_CURRENT_SOURCE_DIR}/*/CMakeLists.txt)
list(TRANSFORM extensions REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/|/CMakeLists.txt" "")
set_property(GLOBAL PROPERTY PHP_ALL_EXTENSIONS ${extensions})

# Sort and preconfigure extensions by their dependencies.
php_extensions_preprocess(extensions)

# Add subdirectories of extensions.
foreach(extension IN LISTS extensions)
  list(APPEND CMAKE_MESSAGE_CONTEXT "${extension}")

  message(CHECK_START "Configuring extension ${extension}")
  list(APPEND CMAKE_MESSAGE_INDENT "  ")
  add_subdirectory("${extension}")
  php_extensions_postconfigure("${extension}")
  list(POP_BACK CMAKE_MESSAGE_INDENT)

  if(NOT TARGET php_ext_${extension})
    message(CHECK_FAIL "disabled")
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
    continue()
  endif()

  set_property(GLOBAL APPEND PROPERTY PHP_EXTENSIONS ${extension})

  add_dependencies(php_ext_${extension} PHP::Zend)

  # Add usage requirements to PHP interface targets.
  # TODO: Should PHP_CLI extensions pass properties only to PHP_CLI SAPIs?
  get_target_property(type PHP::ext::${extension} TYPE)
  if(NOT type MATCHES "^(MODULE|SHARED)_LIBRARY$")
    target_compile_definitions(
      php_config
      INTERFACE
        $<TARGET_PROPERTY:PHP::ext::${extension},INTERFACE_COMPILE_DEFINITIONS>
    )

    target_compile_options(
      php_config
      INTERFACE
        $<TARGET_PROPERTY:PHP::ext::${extension},INTERFACE_COMPILE_OPTIONS>
    )

    target_compile_features(
      php_config
      INTERFACE
        $<TARGET_PROPERTY:PHP::ext::${extension},INTERFACE_COMPILE_FEATURES>
    )

    target_include_directories(
      php_config
      INTERFACE
        $<TARGET_PROPERTY:PHP::ext::${extension},INTERFACE_INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:PHP::ext::${extension},INTERFACE_SYSTEM_INCLUDE_DIRECTORIES>
    )

    target_link_libraries(
      php_sapi
      INTERFACE
        $<IF:$<BOOL:$<TARGET_GENEX_EVAL:PHP::ext::${extension},$<TARGET_PROPERTY:PHP::ext::${extension},PHP_CLI>>>,$<$<BOOL:$<TARGET_PROPERTY:PHP_CLI>>:PHP::ext::${extension}>,PHP::ext::${extension}>
    )

    target_sources(
      php_sapi
      INTERFACE
        $<IF:$<BOOL:$<TARGET_GENEX_EVAL:PHP::ext::${extension},$<TARGET_PROPERTY:PHP::ext::${extension},PHP_CLI>>>,$<$<BOOL:$<TARGET_PROPERTY:PHP_CLI>>:$<TARGET_OBJECTS:PHP::ext::${extension}>>,$<TARGET_OBJECTS:PHP::ext::${extension}>>
    )
  endif()

  target_link_libraries(php_ext_${extension} PRIVATE PHP::config)

  # Add configuration compile options before the extension compile options.
  target_compile_options(
    php_ext_${extension}
    BEFORE PRIVATE
      $<TARGET_PROPERTY:PHP::config,INTERFACE_COMPILE_OPTIONS>
  )

  message(CHECK_PASS "enabled")
  list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endforeach()

get_property(extensions GLOBAL PROPERTY PHP_EXTENSIONS)
list(REVERSE extensions)
set_property(GLOBAL PROPERTY PHP_EXTENSIONS ${extensions})
