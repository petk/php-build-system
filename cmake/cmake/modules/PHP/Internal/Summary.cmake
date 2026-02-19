#[=============================================================================[
This is an internal module and is not intended for direct usage inside projects.
It prints out configuration summary for PHP or PHP extension.

Load this module in a CMake project with:

  include(PHP/Internal/Summary)

This module built on top of the CMake's FeatureSummary module. It sorts feature
summary alphabetically and categorizes enabled features into SAPIs, extensions,
and other global PHP features. Common misconfiguration issues are summarized
together with missing required system packages.

See also: https://cmake.org/cmake/help/latest/module/FeatureSummary.html
#]=============================================================================]

include_guard(GLOBAL)

include(FeatureSummary)

# Add new item to the summary preamble with dotted leader.
function(_php_summary_preamble_add_item label value output)
  # Template helper to calculate column width.
  set(template " * <label> ........................... : <value>")
  string(REGEX MATCH "^ \\\* ([^ ]+ [.]+)" _ "${template}")
  string(LENGTH "${CMAKE_MATCH_1}" width)

  string(LENGTH "${label}" length)
  math(EXPR dots "${width} - ${length} - 1")

  set(leader "")
  if(dots GREATER_EQUAL 2)
    string(REPEAT "." ${dots} leader)
    set(leader " ${leader}")
  elseif(dots EQUAL 1)
    set(leader "  ")
  elseif(dots EQUAL 0)
    set(leader " ")
  elseif(dots LESS 0)
    string(SUBSTRING "${label}" 0 ${width} label)
  endif()

  string(APPEND ${output} " * ${label}${leader} : ${value}\n")
  return(PROPAGATE ${output})
endfunction()

# Get summary preamble.
function(_php_summary_preamble result)
  _php_summary_preamble_add_item(
    "PHP version"
    "${PHP_VERSION}"
    ${result}
  )

  _php_summary_preamble_add_item(
    "PHP API version"
    "${PHP_API_VERSION}"
    ${result}
  )

  if(TARGET PHP::Zend)
    get_target_property(PHP_ZEND_VERSION PHP::Zend VERSION)
    get_target_property(PHP_ZEND_MODULE_API_NO PHP::Zend PHP_ZEND_MODULE_API_NO)
    get_target_property(PHP_ZEND_EXTENSION_API_NO PHP::Zend PHP_ZEND_EXTENSION_API_NO)
  endif()

  if(PHP_ZEND_VERSION)
    _php_summary_preamble_add_item(
      "Zend Engine version"
      "${PHP_ZEND_VERSION}"
      ${result}
    )
  endif()

  if(PHP_ZEND_MODULE_API_NO)
    _php_summary_preamble_add_item(
      "Zend module API number"
      "${PHP_ZEND_MODULE_API_NO}"
      ${result}
    )
  endif()

  if(PHP_ZEND_EXTENSION_API_NO)
    _php_summary_preamble_add_item(
      "Zend extension API number"
      "${PHP_ZEND_EXTENSION_API_NO}"
      ${result}
    )
  endif()

  get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
  foreach(language IN ITEMS ${languages})
    if(language STREQUAL "CXX")
      set(language_label "C++")
    else()
      set(language_label "${language}")
    endif()

    # Add compiler info.
    if(CMAKE_${language}_COMPILER_LOADED)
      set(compiler "")
      if(CMAKE_${language}_COMPILER_ID)
        string(APPEND compiler "${CMAKE_${language}_COMPILER_ID}")
      endif()
      if(CMAKE_${language}_COMPILER_VERSION)
        string(APPEND compiler " ${CMAKE_${language}_COMPILER_VERSION}")
      endif()
      string(STRIP "${compiler}" compiler)
      if(compiler)
        string(APPEND compiler " (${CMAKE_${language}_COMPILER})")
      else()
        string(APPEND compiler "${CMAKE_${language}_COMPILER}")
      endif()
      _php_summary_preamble_add_item(
        "${language_label} compiler"
        "${compiler}"
        ${result}
      )
    endif()

    # Add linker info.
    if(CMAKE_${language}_COMPILER_LINKER)
      set(linker "")
      if(CMAKE_${language}_COMPILER_LINKER_ID)
        string(APPEND linker "${CMAKE_${language}_COMPILER_LINKER_ID}")
      endif()
      if(CMAKE_${language}_COMPILER_LINKER_VERSION)
        string(APPEND linker " ${CMAKE_${language}_COMPILER_LINKER_VERSION}")
      endif()
      string(STRIP "${linker}" linker)
      if(linker)
        string(APPEND linker " (${CMAKE_${language}_COMPILER_LINKER})")
      else()
        string(APPEND linker "${CMAKE_${language}_COMPILER_LINKER}")
      endif()
      _php_summary_preamble_add_item(
        "${language_label} linker"
        "${linker}"
        ${result}
      )
    endif()
  endforeach()

  _php_summary_preamble_add_item(
    "Building on (host system)"
    "${CMAKE_HOST_SYSTEM}"
    ${result}
  )

  _php_summary_preamble_add_item(
    "Host CPU"
    "${CMAKE_HOST_SYSTEM_PROCESSOR}"
    ${result}
  )

  _php_summary_preamble_add_item(
    "Building for (target system)"
    "${CMAKE_SYSTEM}"
    ${result}
  )

  _php_summary_preamble_add_item(
    "Target CPU"
    "${CMAKE_SYSTEM_PROCESSOR}"
    ${result}
  )

  _php_summary_preamble_add_item(
    "CMAKE_C_COMPILER_ARCHITECTURE_ID"
    "${CMAKE_C_COMPILER_ARCHITECTURE_ID}"
    ${result}
  )

  _php_summary_preamble_add_item(
    "CMake version"
    "${CMAKE_VERSION}"
    ${result}
  )

  _php_summary_preamble_add_item(
    "CMake generator"
    "${CMAKE_GENERATOR}"
    ${result}
  )

  get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
  if(is_multi_config)
    set(build_type "Multi-config generator")
  elseif(CMAKE_BUILD_TYPE)
    set(build_type "${CMAKE_BUILD_TYPE}")
  else()
    set(build_type "N/A")
  endif()

  _php_summary_preamble_add_item("Build type" "${build_type}" ${result})

  return(PROPAGATE ${result})
endfunction()

# Output configuration summary.
function(php_summary_print)
  _php_summary_preamble(preamble)

  _php_summary_preamble_add_item(
    "Install prefix"
    "${CMAKE_INSTALL_PREFIX}"
    preamble
  )

  message(STATUS "")
  message(STATUS "")
  message(STATUS "PHP configuration summary")
  message(STATUS "=========================\n\n${preamble}")

  # Output enabled features.
  get_property(enabled_features GLOBAL PROPERTY ENABLED_FEATURES)
  list(REMOVE_DUPLICATES enabled_features)
  list(SORT enabled_features COMPARE NATURAL CASE INSENSITIVE)

  set(php "")
  set(sapis "")
  set(extensions "")

  foreach(feature IN LISTS enabled_features)
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
          get_target_property(type PHP::ext::${CMAKE_MATCH_1} TYPE)
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
  set(missing_extensions "")
  set(shared_extensions_summary "")

  get_property(extensions GLOBAL PROPERTY PHP_EXTENSIONS)

  foreach(extension IN LISTS extensions)
    if(NOT TARGET php_ext_${extension})
      continue()
    endif()

    get_target_property(
      dependencies
      PHP::ext::${extension}
      MANUALLY_ADDED_DEPENDENCIES
    )

    if(NOT dependencies)
      continue()
    endif()

    list(TRANSFORM dependencies REPLACE "^php_ext_" "")

    get_property(all_extensions GLOBAL PROPERTY PHP_ALL_EXTENSIONS)

    foreach(dependency IN LISTS dependencies)
      # Skip dependencies that are not inside the current project.
      if(NOT dependency IN_LIST all_extensions)
        continue()
      endif()

      if(NOT TARGET php_ext_${dependency} OR NOT dependency IN_LIST extensions)
        list(APPEND missing_extensions ${dependency})
        list(APPEND _php_summary_reasons_${dependency} ${extension})
        continue()
      endif()

      get_target_property(dependency_type PHP::ext::${dependency} TYPE)
      get_target_property(extension_type PHP::ext::${extension} TYPE)

      if(
        dependency_type MATCHES "^(MODULE|SHARED)_LIBRARY$"
        AND NOT extension_type MATCHES "^(MODULE|SHARED)_LIBRARY$"
      )
        string(TOUPPER "${extension}" extension_upper)
        string(
          APPEND
          shared_extensions_summary
          " * ${extension}\n"
          "   Set 'PHP_EXT_${extension_upper}_SHARED' to 'ON' (its dependency "
          "${dependency} extension will be built as shared)\n"
        )
      endif()
    endforeach()
  endforeach()

  if(missing_extensions)
    list(REMOVE_DUPLICATES missing_extensions)
    set(message "The following missing PHP extensions must be enabled:\n\n")

    foreach(extension IN LISTS missing_extensions)
      string(TOUPPER "${extension}" extension_upper)
      string(
        APPEND
        message
        " * ${extension}\n"
        "   Set 'PHP_EXT_${extension_upper}' to 'ON'\n"
      )
      list(JOIN _php_summary_reasons_${extension} ", " reasons)
      string(APPEND message "   (Required by ${reasons})\n")
    endforeach()

    message(STATUS "${message}")
  endif()

  if(shared_extensions_summary)
    set(message "The following PHP extensions must be reconfigured:\n\n")
    string(APPEND message "${shared_extensions_summary}")

    message(STATUS "${message}")
  endif()

  if(missing_extensions OR shared_extensions_summary)
    message(SEND_ERROR "Please reconfigure PHP extensions, aborting CMake run.")
  endif()

  # Output missing required packages.
  feature_summary(
    FATAL_ON_MISSING_REQUIRED_PACKAGES
    WHAT
      RECOMMENDED_PACKAGES_NOT_FOUND
      REQUIRED_PACKAGES_NOT_FOUND
    QUIET_ON_EMPTY
  )
endfunction()

function(php_summary_print_extension extension)
  if(PROJECT_VERSION)
    _php_summary_preamble_add_item(
      "${extension} version"
      "${PROJECT_VERSION}"
      preamble
    )
  endif()

  _php_summary_preamble(preamble)

  _php_summary_preamble_add_item(
    "PHP extension dir"
    "${PHP_EXTENSION_DIR}"
    preamble
  )

  message(STATUS "")
  message(STATUS "")
  set(title "PHP extension ${extension} configuration summary")
  message(STATUS "${title}")
  string(LENGTH "${title}" width)
  string(REPEAT "=" ${width} underline)
  message(STATUS "${underline}\n\n${preamble}")

  feature_summary(
    FATAL_ON_MISSING_REQUIRED_PACKAGES
    WHAT
      ENABLED_FEATURES
      RECOMMENDED_PACKAGES_NOT_FOUND
      REQUIRED_PACKAGES_NOT_FOUND
    QUIET_ON_EMPTY
  )
endfunction()
