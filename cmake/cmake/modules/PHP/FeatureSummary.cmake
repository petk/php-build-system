#[=============================================================================[
# PHP/FeatureSummary

Print summary of enabled/disabled features.

This is built on top of the CMake's `FeatureSummary` module. It sorts feature
summary alphabetically and categorizes enabled features into SAPIs, extensions,
and other global PHP features. Common misconfiguration issues are summarized
together with missing required system packages.

See also: https://cmake.org/cmake/help/latest/module/FeatureSummary.html

## Basic usage

```cmake
# CMakeLists.txt

# Include module and output configuration summary
include(PHP/FeatureSummary)
php_feature_summary()
```

## Functions

Output PHP configuration summary:

```cmake
php_feature_summary()
```
#]=============================================================================]

include_guard(GLOBAL)

include(FeatureSummary)

# Add new item to the summary preamble with dotted leader.
function(php_feature_summary_preamble_add_item label value output)
  # If preamble is already set, use it to calculate column width, otherwise use
  # predefined helper template.
  if(${output})
    set(template "${${output}}")
  else()
    set(template " * <label> .................... : <value>")
  endif()

  string(REGEX MATCH "^ \\\* ([^\r\n]+ [.]+) : " _ "${template}")
  string(LENGTH "${CMAKE_MATCH_1}" width)
  string(LENGTH "${label}" length)
  math(EXPR numberOfDots "${width} - ${length} - 1")

  if(numberOfDots GREATER 0)
    string(REPEAT "." ${numberOfDots} leader)
    set(leader " ${leader} ")
  else()
    set(leader "")
  endif()

  string(APPEND ${output} " * ${label}${leader}: ${value}\n")
  set("${output}" "${${output}}" PARENT_SCOPE)
endfunction()

# Get summary preamble.
function(php_feature_summary_preamble result)
  php_feature_summary_preamble_add_item("${PROJECT_NAME} version" "${PROJECT_VERSION}" preamble)
  php_feature_summary_preamble_add_item("PHP API version" "${PHP_API_VERSION}" preamble)

  if(TARGET Zend::Zend)
    get_target_property(zendVersion Zend::Zend VERSION)
    get_target_property(zendExtensionApi Zend::Zend ZEND_EXTENSION_API_NO)
    get_target_property(zendModuleApi Zend::Zend ZEND_MODULE_API_NO)
    php_feature_summary_preamble_add_item("Zend Engine version" "${zendVersion}" preamble)
    php_feature_summary_preamble_add_item("Zend extension API number" "${zendExtensionApi}" preamble)
    php_feature_summary_preamble_add_item("Zend module API number" "${zendModuleApi}" preamble)
  endif()

  if(CMAKE_C_COMPILER_LOADED)
    set(compiler "")
    if(CMAKE_C_COMPILER_ID)
      string(APPEND compiler "${CMAKE_C_COMPILER_ID}")
    endif()
    if(CMAKE_C_COMPILER_VERSION)
      string(APPEND compiler " ${CMAKE_C_COMPILER_VERSION}")
    endif()
    string(STRIP "${compiler}" compiler)
    if(compiler)
      string(APPEND compiler " (${CMAKE_C_COMPILER})")
    else()
      string(APPEND compiler "${CMAKE_C_COMPILER}")
    endif()
    php_feature_summary_preamble_add_item("C compiler" "${compiler}" preamble)
  endif()

  if(CMAKE_CXX_COMPILER_LOADED)
    set(compiler "")
    if(CMAKE_CXX_COMPILER_ID)
      string(APPEND compiler "${CMAKE_CXX_COMPILER_ID}")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION)
      string(APPEND compiler " ${CMAKE_CXX_COMPILER_VERSION}")
    endif()
    string(STRIP "${compiler}" compiler)
    if(compiler)
      string(APPEND compiler " (${CMAKE_CXX_COMPILER})")
    else()
      string(APPEND compiler "${CMAKE_CXX_COMPILER}")
    endif()
    php_feature_summary_preamble_add_item("CXX compiler" "${compiler}" preamble)
  endif()

  get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
  if(isMultiConfig)
    set(buildType "Multi-config generator")
  elseif(CMAKE_BUILD_TYPE)
    set(buildType "${CMAKE_BUILD_TYPE}")
  else()
    set(buildType "N/A")
  endif()

  php_feature_summary_preamble_add_item("Build type" "${buildType}" preamble)
  php_feature_summary_preamble_add_item("Install prefix" "${CMAKE_INSTALL_PREFIX}" preamble)

  set(${result} "${preamble}" PARENT_SCOPE)
endfunction()

# Output configuration summary.
function(php_feature_summary)
  php_feature_summary_preamble(preamble)

  message(STATUS "")
  message(STATUS "")
  message(STATUS "PHP configuration summary")
  message(STATUS "=========================\n\n${preamble}")

  # Output enabled features.
  get_property(enabledFeatures GLOBAL PROPERTY ENABLED_FEATURES)
  list(REMOVE_DUPLICATES enabledFeatures)
  list(SORT enabledFeatures COMPARE NATURAL CASE INSENSITIVE)

  set(php "")
  set(sapis "")
  set(extensions "")

  foreach(feature IN LISTS enabledFeatures)
    if(parent AND feature MATCHES "^${parent} ")
      string(REGEX REPLACE "^${parent}[ ]+" "" item "${feature}")

      if(NOT item MATCHES "^(with|without) ")
        string(PREPEND item "with ")
      endif()
      string(PREPEND item "   - ")

      set(indentation "     ")
    else()
      if(feature MATCHES "^(ext|sapi)/")
        set(parent "${feature}")
      else()
        unset(parent)
      endif()

      string(REGEX REPLACE "^(ext|sapi)/" "" item "${feature}")
      string(PREPEND item " * ")
      if(feature MATCHES "^ext/([^ ]+)$")
        if(CMAKE_MATCH_1)
          get_target_property(type php_ext_${CMAKE_MATCH_1} TYPE)
          if(type MATCHES "^(MODULE|SHARED)_LIBRARY$")
            string(APPEND item " (shared)")
          endif()
        endif()
      endif()

      set(indentation "   ")
    endif()

    get_property(description GLOBAL PROPERTY _CMAKE_${feature}_DESCRIPTION)
    if(description)
      string(REPLACE "\n" "\n${indentation}" description "${description}")
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

  if(php)
    message(STATUS "Enabled PHP features:\n\n${php}")
  endif()

  if(sapis)
    message(STATUS "Enabled PHP SAPIs:\n\n${sapis}")
  endif()

  if(extensions)
    message(STATUS "Enabled PHP extensions:\n\n${extensions}")
  endif()

  # Get missing extensions.
  set(missingExtensions "")
  set(sharedExtensionsSummary "")

  get_property(extensions GLOBAL PROPERTY PHP_EXTENSIONS)

  foreach(extension IN LISTS extensions)
    if(NOT TARGET php_ext_${extension})
      continue()
    endif()

    get_target_property(
      dependencies
      php_ext_${extension}
      MANUALLY_ADDED_DEPENDENCIES
    )

    if(NOT dependencies)
      continue()
    endif()

    list(TRANSFORM dependencies REPLACE "^php_ext_" "")

    get_property(allExtensions GLOBAL PROPERTY PHP_ALL_EXTENSIONS)

    foreach(dependency IN LISTS dependencies)
      # Skip dependencies that are not inside the current project.
      if(NOT dependency IN_LIST allExtensions)
        continue()
      endif()

      if(NOT TARGET php_ext_${dependency} OR NOT dependency IN_LIST extensions)
        list(APPEND missingExtensions ${dependency})
        list(APPEND _phpFeatureSummaryReason_${dependency} ${extension})
        continue()
      endif()

      get_target_property(dependencyType php_ext_${dependency} TYPE)
      get_target_property(extensionType php_ext_${extension} TYPE)

      if(
        dependencyType MATCHES "^(MODULE|SHARED)_LIBRARY$"
        AND NOT extensionType MATCHES "^(MODULE|SHARED)_LIBRARY$"
      )
        string(TOUPPER "${extension}" extensionUpper)
        string(
          APPEND
          sharedExtensionsSummary
          " * ${extension}\n"
          "   Set 'EXT_${extensionUpper}_SHARED' to 'ON' (its dependency "
          "${dependency} extension will be built as shared)\n"
        )
      endif()
    endforeach()
  endforeach()

  if(missingExtensions)
    list(REMOVE_DUPLICATES missingExtensions)
    set(message "The following missing PHP extensions must be enabled:\n\n")

    foreach(extension IN LISTS missingExtensions)
      string(TOUPPER "${extension}" extensionUpper)
      string(
        APPEND
        message
        " * ${extension}\n"
        "   Set 'EXT_${extensionUpper}' to 'ON'\n"
      )
      list(JOIN _phpFeatureSummaryReason_${extension} ", " reasons)
      string(APPEND message "   (Required by ${reasons})\n")
    endforeach()

    message(STATUS "${message}")
  endif()

  if(sharedExtensionsSummary)
    set(message "The following PHP extensions must be reconfigured:\n\n")
    string(APPEND message "${sharedExtensionsSummary}")

    message(STATUS "${message}")
  endif()

  if(missingExtensions OR sharedExtensionsSummary)
    message(
      SEND_ERROR
      "PHP/FeatureSummary error: Please reconfigure PHP extensions, aborting "
      "CMake run."
    )
  endif()

  # Output missing required packages.
  feature_summary(
    FATAL_ON_MISSING_REQUIRED_PACKAGES
    WHAT REQUIRED_PACKAGES_NOT_FOUND
    QUIET_ON_EMPTY
    DESCRIPTION "The following REQUIRED packages have not been found:\n"
  )
endfunction()
