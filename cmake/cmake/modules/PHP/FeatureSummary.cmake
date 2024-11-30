#[=============================================================================[
# PHP/FeatureSummary

Print summary of enabled/disabled features.

This is built on top of the CMake's `FeatureSummary` module. It sorts feature
summary alphabetically and categorizes enabled features into SAPIs, extensions,
and other global PHP features. Common misconfiguration issues are summarized
together with missing required system packages.

https://cmake.org/cmake/help/latest/module/FeatureSummary.html
#]=============================================================================]

include_guard(GLOBAL)

include(FeatureSummary)

# Output summary prelude.
block()
  get_target_property(zendVersion Zend::Zend VERSION)
  get_target_property(zendExtensionApiNumber Zend::Zend ZEND_EXTENSION_API_NO)
  get_target_property(zendModuleApiNumber Zend::Zend ZEND_MODULE_API_NO)

  set(info)
  string(
    APPEND
    info
    " * PHP version ................ : ${PHP_VERSION}\n"
    " * PHP API version ............ : ${PHP_API_VERSION}\n"
    " * Zend Engine version ........ : ${zendVersion}\n"
    " * Zend extension API number .. : ${zendExtensionApiNumber}\n"
    " * Zend module API number ..... : ${zendModuleApiNumber}\n"
    " * C compiler ................. : ${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION} (${CMAKE_C_COMPILER})\n"
  )

  if(CMAKE_CXX_COMPILER_LOADED)
    string(
      APPEND
      info
      " * CXX compiler ............... : ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION} (${CMAKE_CXX_COMPILER})\n"
    )
  endif()

  string(
    APPEND
    info
    " * Install prefix ............. : ${CMAKE_INSTALL_PREFIX}\n"
  )

  message(STATUS "")
  message(STATUS "")
  message(STATUS "PHP summary")
  message(STATUS "===========\n\n${info}")
endblock()

# Output enabled features.
block()
  get_property(enabledFeatures GLOBAL PROPERTY ENABLED_FEATURES)

  if(enabledFeatures)
    list(REMOVE_DUPLICATES enabledFeatures)
  endif()

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
    else()
      set(parent "${feature}")
      string(REGEX REPLACE "^(ext|sapi)/" "" item "${feature}")
      string(PREPEND item " * ")
      if(feature MATCHES "^ext/([^ ]+)$")
        if(CMAKE_MATCH_1)
          get_target_property(type php_${CMAKE_MATCH_1} TYPE)
          if(type MATCHES "^(MODULE|SHARED)_LIBRARY$")
            string(APPEND item " (shared)")
          endif()
        endif()
      endif()
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

  if(php)
    message(STATUS "Enabled PHP features:\n\n${php}")
  endif()

  if(sapis)
    message(STATUS "Enabled PHP SAPIs:\n\n${sapis}")
  endif()

  if(extensions)
    message(STATUS "Enabled PHP extensions:\n\n${extensions}")
  endif()
endblock()

# Get missing extensions.
block()
  set(missingExtensions "")
  set(sharedExtensionsSummary "")

  get_property(extensions GLOBAL PROPERTY PHP_EXTENSIONS)

  foreach(extension ${extensions})
    if(NOT TARGET php_${extension})
      continue()
    endif()

    get_target_property(
      dependencies
      php_${extension}
      MANUALLY_ADDED_DEPENDENCIES
    )

    if(NOT dependencies)
      continue()
    endif()

    list(TRANSFORM dependencies REPLACE "^php_" "")

    get_property(allExtensions GLOBAL PROPERTY PHP_ALL_EXTENSIONS)

    foreach(dependency ${dependencies})
      # Skip dependencies that are not inside the current project.
      if(NOT dependency IN_LIST allExtensions)
        continue()
      endif()

      if(NOT TARGET php_${dependency} OR NOT dependency IN_LIST extensions)
        list(APPEND missingExtensions ${dependency})
        list(APPEND _phpFeatureSummaryReason_${dependency} ${extension})
        continue()
      endif()

      get_target_property(dependencyType php_${dependency} TYPE)
      get_target_property(extensionType php_${extension} TYPE)

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

    foreach(extension ${missingExtensions})
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
endblock()
