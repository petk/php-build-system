#[=============================================================================[
Configure CMake build types.
#]=============================================================================]

include_guard(GLOBAL)

block()
  if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

    if(isMultiConfig)
      if(NOT "DebugAssertions" IN_LIST CMAKE_CONFIGURATION_TYPES)
        list(APPEND CMAKE_CONFIGURATION_TYPES DebugAssertions)
      endif()
    else()
      set(
        allowedBuildTypes
        Debug
        MinSizeRel
        Release
        RelWithDebInfo
        DebugAssertions # Custom build type with debug assertions enabled in
                        # release mode.
      )

      set_property(
        CACHE CMAKE_BUILD_TYPE
        PROPERTY STRINGS "${allowedBuildTypes}"
      )

      if(NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE Debug CACHE STRING "" FORCE)
      elseif(NOT CMAKE_BUILD_TYPE IN_LIST allowedBuildTypes)
        message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}")
      endif()
    endif()
  endif()
endblock()

# TODO: Remove this in favor of generator expressions. Multi configuration
# generators are otherwise not checked here like this.
if(CMAKE_BUILD_TYPE MATCHES "^(Debug|DebugAssertions)$")
  set(PHP_DEBUG TRUE)
  set(ZEND_DEBUG 1 CACHE INTERNAL "Whether to enable debugging")
endif()

target_compile_definitions(
  php_configuration
  INTERFACE
    $<IF:$<CONFIG:Debug,DebugAssertions>,ZEND_DEBUG=1,ZEND_DEBUG=0>
)
