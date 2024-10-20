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
          Debug           # Debug info, assertions, not optimized.
          DebugAssertions # Custom PHP debug build type with assertions enabled
                          # in the RelWithDebInfo mode: optimized, debug info,
                          # assertions.
          MinSizeRel      # Same as Release but optimized for size rather than
                          # speed.
          Release         # No debug info, no assertions, optimized.
          RelWithDebInfo  # Debug info, optimized, no assertions.
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

target_compile_definitions(
  php_configuration
  INTERFACE
    $<IF:$<CONFIG:Debug,DebugAssertions>,ZEND_DEBUG=1,ZEND_DEBUG=0>
)

# Set CMAKE_<LANG>_FLAGS_<CONFIG> variables for the DebugAssertions build type.
foreach(prefix CMAKE_C_FLAGS CMAKE_CXX_FLAGS CMAKE_ASM_FLAGS)
  string(
    REGEX REPLACE
    "(-DNDEBUG|/DNDEBUG)"
    ""
    ${prefix}_DEBUGASSERTIONS
    "${${prefix}_RELWITHDEBINFO}"
  )
endforeach()
