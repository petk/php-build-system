#[=============================================================================[
Configure CMake build types.
#]=============================================================================]

include_guard(GLOBAL)

block(PROPAGATE CMAKE_CONFIGURATION_TYPES)
  get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

  # Set default build type for single-config generators.
  if(NOT is_multi_config AND NOT CMAKE_BUILD_TYPE)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/.git")
      set(default_build_type "Debug")
    else()
      set(default_build_type "Release")
    endif()

    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY VALUE "${default_build_type}")
  endif()

  if(PROJECT_IS_TOP_LEVEL)
    if(is_multi_config)
      if(NOT "PhpRelWithDebInfo" IN_LIST CMAKE_CONFIGURATION_TYPES)
        list(APPEND CMAKE_CONFIGURATION_TYPES PhpRelWithDebInfo)
      endif()
    else()
      set(
        allowed_build_types
        # Not optimized, debug info, assertions:
        Debug
        # Same as Release but optimized for size rather than speed:
        MinSizeRel
        # Custom debug build type based on RelWithDebInfo (optimized, debug
        # info, assertions):
        PhpRelWithDebInfo
        # Optimized, no debug info, no assertions:
        Release
        # Optimized, debug info, no assertions:
        RelWithDebInfo
      )

      set_property(
        CACHE CMAKE_BUILD_TYPE
        PROPERTY STRINGS "${allowed_build_types}"
      )

      set_property(
        CACHE CMAKE_BUILD_TYPE
        PROPERTY
          HELPSTRING
            "Choose the type of build, options are: ${allowed_build_types}"
      )

      if(NOT CMAKE_BUILD_TYPE IN_LIST allowed_build_types)
        message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}")
      endif()
    endif()
  endif()
endblock()

# Set CMAKE_<LANG>_FLAGS_<CONFIG> variables for the PhpRelWithDebInfo build
# type. These should ideally be set for all languages needed for the project
# scope before adding binary targets that need these flags (for example, PHP
# extensions or SAPIs). PhpRelWithDebInfo is based on the RelWithDebInfo build
# type. At time of writing, these variables might contain values specific to
# the build type:
# - CMAKE_<LANG>_FLAGS_RELWITHDEBINFO
# - CMAKE_{EXE,MODULE,SHARED,STATIC}_LINKER_FLAGS_RELWITHDEBINFO
if(PROJECT_IS_TOP_LEVEL)
  get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

  foreach(lang IN LISTS languages)
    string(
      REGEX REPLACE
      "(-DNDEBUG|/DNDEBUG)"
      ""
      CMAKE_${lang}_FLAGS_PHPRELWITHDEBINFO
      "${CMAKE_${lang}_FLAGS_RELWITHDEBINFO}"
    )
  endforeach()

  unset(languages)

  foreach(type EXE MODULE SHARED STATIC)
    set(
      CMAKE_${type}_LINKER_FLAGS_PHPRELWITHDEBINFO
      "${CMAKE_${type}_LINKER_FLAGS_RELWITHDEBINFO}"
    )
  endforeach()
endif()

target_compile_definitions(
  php_config
  INTERFACE $<IF:$<CONFIG:Debug,PhpRelWithDebInfo>,ZEND_DEBUG=1,ZEND_DEBUG=0>
)
