#[=============================================================================[
Configure CMake build types.
#]=============================================================================]

include_guard(GLOBAL)

block()
  get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

  # Set default build type for single-config generators.
  if(NOT isMultiConfig AND NOT CMAKE_BUILD_TYPE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY VALUE "Debug")
  endif()

  if(PROJECT_IS_TOP_LEVEL)
    if(isMultiConfig)
      if(NOT "DebugAssertions" IN_LIST CMAKE_CONFIGURATION_TYPES)
        list(APPEND CMAKE_CONFIGURATION_TYPES DebugAssertions)
      endif()
    else()
      set(
        allowedBuildTypes
          Debug           # Not optimized, debug info, assertions.
          DebugAssertions # Custom PHP debug build type based on RelWithDebInfo:
                          # optimized, debug info, assertions.
          MinSizeRel      # Same as Release but optimized for size rather than
                          # speed.
          Release         # Optimized, no debug info, no assertions.
          RelWithDebInfo  # Optimized, debug info, no assertions.
      )

      set_property(
        CACHE CMAKE_BUILD_TYPE
        PROPERTY STRINGS "${allowedBuildTypes}"
      )

      set_property(
        CACHE CMAKE_BUILD_TYPE
        PROPERTY HELPSTRING
        "Choose the type of build, options are: ${allowedBuildTypes}"
      )

      if(NOT CMAKE_BUILD_TYPE IN_LIST allowedBuildTypes)
        message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}")
      endif()
    endif()
  endif()
endblock()

# Set CMAKE_<LANG>_FLAGS_<CONFIG> variables for the DebugAssertions build type.
# These should ideally be set for all languages needed for the project scope
# before adding binary targets that need these flags (for example, PHP
# extensions or SAPIs).
foreach(lang C CXX ASM)
  string(
    REGEX REPLACE
    "(-DNDEBUG|/DNDEBUG)"
    ""
    CMAKE_${lang}_FLAGS_DEBUGASSERTIONS
    "${CMAKE_${lang}_FLAGS_RELWITHDEBINFO}"
  )
endforeach()

target_compile_definitions(
  php_configuration
  INTERFACE
    $<IF:$<CONFIG:Debug,DebugAssertions>,ZEND_DEBUG=1,ZEND_DEBUG=0>
)
