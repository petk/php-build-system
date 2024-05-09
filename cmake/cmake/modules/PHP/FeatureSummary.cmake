#[=============================================================================[
Print summary of enabled/disabled features.

This is built on top of the default FeatureSummary module. It sorts feature
summary alphabetically and categorizes enabled features into SAPIs, extensions,
and other global PHP features.

https://cmake.org/cmake/help/latest/module/FeatureSummary.html
]=============================================================================]#

include_guard(GLOBAL)

include(FeatureSummary)

message("
+--------------------------------------------------------------------+
| Summary                                                            |
+--------------------------------------------------------------------+
")

# Output enabled features.
block()
  feature_summary(
    WHAT ENABLED_FEATURES
    VAR enabledFeatures
  )

  get_property(enabledFeatures GLOBAL PROPERTY ENABLED_FEATURES)

  if(enabledFeatures)
    list(REMOVE_DUPLICATES enabledFeatures)
  endif()

  list(SORT enabledFeatures COMPARE NATURAL)

  set(sapis "")
  set(extensions "")
  set(php "")

  foreach(feature ${enabledFeatures})
    if(parent AND feature MATCHES "^${parent} ")
      set(item "   * ${feature}")
    else()
      set(item " * ${feature}")
      set(parent "${feature}")
    endif()

    get_property(description GLOBAL PROPERTY _CMAKE_${feature}_DESCRIPTION)
    if(description)
      string(APPEND item ", ${description}")
    endif()

    string(APPEND item "\n")

    if(feature MATCHES "^sapi/")
      string(APPEND sapis "${item}")
    elseif(feature MATCHES "^ext/")
      string(APPEND extensions "${item}")
    else()
      string(APPEND php "${item}")
    endif()
  endforeach()

  if(sapis)
    message(STATUS "Enabled SAPIs:\n\n${sapis}")
  endif()

  if(extensions)
    message(STATUS "Enabled extensions:\n\n${extensions}")
  endif()

  if(php)
    message(STATUS "Enabled PHP features:\n\n${php}")
  endif()
endblock()

# Output missing packages.
feature_summary(
  FATAL_ON_MISSING_REQUIRED_PACKAGES
  WHAT REQUIRED_PACKAGES_NOT_FOUND
  QUIET_ON_EMPTY
)
