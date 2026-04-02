#[=============================================================================[
This is an internal module and is not intended for direct usage inside projects.
It prints out configuration summary for PHP or a self-contained PHP extension.

Load this module in a CMake project with:

  include(PHP/Internal/Summary)

This module is built on top of the CMake's FeatureSummary module. It sorts
feature summary alphabetically and categorizes enabled features into SAPIs,
extensions, and other global PHP features. Common misconfiguration issues are
summarized together with missing required system packages. This module also
checks dependencies of PHP extensions whether they were enabled and emits error
at the end of the configuration phase in case of misconfiguration.
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

# Validate extensions configuration and output issues with their dependencies.
function(_php_summary_validate_extensions)
  set(missing_extensions "")
  set(recommended_extensions "")
  set(shared_extensions_summary "")
  set(conflicting_extensions "")

  get_property(enabled_extensions GLOBAL PROPERTY PHP_ENABLED_EXTENSIONS)
  get_property(all_extensions GLOBAL PROPERTY PHP_ALL_EXTENSIONS)

  foreach(extension IN LISTS enabled_extensions)
    if(NOT TARGET PHP::ext::${extension})
      continue()
    endif()

    # Check for required extensions.
    get_target_property(
      extensions
      PHP::ext::${extension}
      PHP_REQUIRED_EXTENSIONS
    )

    if(extensions)
      foreach(dependency IN LISTS extensions)
        # Skip dependencies that are not inside the current project.
        if(NOT dependency IN_LIST all_extensions)
          continue()
        endif()

        if(NOT TARGET PHP::ext::${dependency})
          list(APPEND missing_extensions ${dependency})
          list(APPEND _php_summary_reasons_${dependency} ${extension})
          continue()
        endif()

        get_target_property(dependency_type PHP::ext::${dependency} TYPE)
        get_target_property(extension_type PHP::ext::${extension} TYPE)

        if(
          dependency_type STREQUAL "MODULE_LIBRARY"
          AND NOT extension_type STREQUAL "MODULE_LIBRARY"
        )
          string(TOUPPER "${extension}" extension_upper)
          string(
            APPEND
            shared_extensions_summary
            " * ${extension}\n"
            "   Either set 'PHP_EXT_${extension_upper}' to 'shared' (its "
            "dependency, the ${dependency} extension is configured as shared) "
            "or build ${dependency} statically."
            "\n"
          )
        endif()
      endforeach()
    endif()

    # Check for recommended extensions.
    get_target_property(
      extensions
      PHP::ext::${extension}
      PHP_RECOMMENDED_EXTENSIONS
    )

    if(extensions)
      foreach(dependency IN LISTS extensions)
        # Skip dependencies that are not inside the current project.
        if(NOT dependency IN_LIST all_extensions)
          continue()
        endif()

        if(NOT TARGET PHP::ext::${dependency})
          list(APPEND recommended_extensions ${dependency})
          list(
            APPEND
            _php_summary_recommended_reasons_${dependency}
            ${extension}
          )
        endif()
      endforeach()
    endif()

    # Check for conflicting extensions.
    get_target_property(
      extensions
      PHP::ext::${extension}
      PHP_CONFLICTING_EXTENSIONS
    )

    if(extensions)
      foreach(conflict IN LISTS extensions)
        # Skip extensions that are not inside the current project.
        if(NOT conflict IN_LIST all_extensions)
          continue()
        endif()

        if(TARGET PHP::ext::${conflict})
          list(APPEND conflicting_extensions ${conflict})
          list(APPEND _php_summary_conflicting_reasons_${conflict} ${extension})
        endif()
      endforeach()
    endif()
  endforeach()

  if(conflicting_extensions)
    list(REMOVE_DUPLICATES conflicting_extensions)

    set(message "The following PHP extensions are in conflict:\n\n")

    foreach(extension IN LISTS conflicting_extensions)
      list(JOIN _php_summary_conflicting_reasons_${extension} ", " reasons)
      string(TOUPPER "${extension}" extension_upper)
      string(
        APPEND
        message
        " * ${extension} conflicts with ${reasons}\n"
        "   Set 'PHP_EXT_${extension_upper}' to 'OFF' or disable conflicting "
        "extensions\n"
      )
    endforeach()

    message(STATUS "${message}")
  endif()

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

  if(recommended_extensions)
    list(REMOVE_DUPLICATES recommended_extensions)
    set(
      message
      "The following recommended PHP extensions have not been enabled:\n\n"
    )

    foreach(extension IN LISTS recommended_extensions)
      string(TOUPPER "${extension}" extension_upper)
      string(
        APPEND
        message
        " * ${extension}\n"
        "   Set 'PHP_EXT_${extension_upper}' to 'ON'\n"
      )
      list(JOIN _php_summary_recommended_reasons_${extension} ", " reasons)
      string(APPEND message "   (Suggested by ${reasons})\n")
    endforeach()

    message(STATUS "${message}")
  endif()

  if(shared_extensions_summary)
    message(
      STATUS
      "The following PHP extensions must be reconfigured:\n\n"
      "${shared_extensions_summary}"
    )
  endif()

  if(missing_extensions OR shared_extensions_summary OR conflicting_extensions)
    message(SEND_ERROR "Please reconfigure PHP extensions, aborting CMake run.")
  endif()
endfunction()

# Checks whether extension is enabled.
function(_php_summary_check_extension)
  # The opcache extension has non-standard name.
  if("${ARGV0}" STREQUAL "opcache")
    set(name "Zend OPcache")
  else()
    set(name "${ARGV0}")
  endif()

  get_target_property(php_executable PHP::Interpreter LOCATION)

  execute_process(
    COMMAND ${php_executable} --ri ${name}
    RESULT_VARIABLE code
    OUTPUT_QUIET
    ERROR_QUIET
  )

  if(code EQUAL 0)
    set(${ARGV1} TRUE)
  else()
    set(${ARGV1} FALSE)
  endif()

  return(PROPAGATE ${ARGV1})
endfunction()

# Validate self-contained extension and output missing required extensions.
function(_php_summary_validate_extension extension)
  if(NOT TARGET PHP::ext::${extension})
    return()
  endif()

  # Check for required extensions.
  set(required_extensions "")

  get_target_property(
    extensions
    PHP::ext::${extension}
    PHP_REQUIRED_EXTENSIONS
  )

  if(extensions)
    list(REMOVE_DUPLICATES extensions)
    set(message "The following missing PHP extensions must be enabled:\n\n")

    foreach(dependency IN LISTS extensions)
      _php_summary_check_extension(${dependency} result)

      if(NOT result)
        list(APPEND required_extensions ${dependency})
        string(APPEND message " * ${dependency}\n")
      endif()
    endforeach()

    if(required_extensions)
      message(STATUS "${message}")
    endif()
  endif()

  # Check for recommended extensions.
  set(recommended_extensions "")

  get_target_property(
    extensions
    PHP::ext::${extension}
    PHP_RECOMMENDED_EXTENSIONS
  )

  if(extensions)
    list(REMOVE_DUPLICATES extensions)
    set(message "The following recommended PHP extensions are not enabled:\n\n")

    foreach(dependency IN LISTS extensions)
      _php_summary_check_extension(${dependency} result)

      if(NOT result)
        list(APPEND recommended_extensions ${dependency})
        string(APPEND message " * ${dependency}\n")
      endif()
    endforeach()

    if(recommended_extensions)
      message(STATUS "${message}")
    endif()
  endif()

  # Check for conflicting extensions.
  set(conflicting_extensions "")

  get_target_property(
    extensions
    PHP::ext::${extension}
    PHP_CONFLICTING_EXTENSIONS
  )

  if(extensions)
    list(REMOVE_DUPLICATES extensions)
    set(message "")

    foreach(conflict IN LISTS extensions)
      _php_summary_check_extension(${conflict} result)
      if(result)
        list(APPEND conflicting_extensions ${conflict})
        string(APPEND message " * ${conflict}\n")
      endif()
    endforeach()

    if(conflicting_extensions)
      message(
        STATUS
        "Extension ${extension} conflicts with the following extensions:\n\n"
        "${message}"
      )
    endif()
  endif()

  set(message "")

  if(required_extensions)
    string(
      APPEND
      message
      "Please install missing PHP extensions. "
    )
  endif()

  if(conflicting_extensions)
    string(
      APPEND
      message
      "Please disable conflicting PHP extensions to use ${extension}. "
    )
  endif()

  if(required_extensions OR conflicting_extensions)
    message(SEND_ERROR "${message}Aborting CMake run.")
  endif()
endfunction()

# Print php-src configuration summary.
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
          if(type STREQUAL "MODULE_LIBRARY")
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

  _php_summary_validate_extensions()

  # Output missing required packages.
  feature_summary(
    FATAL_ON_MISSING_REQUIRED_PACKAGES
    WHAT
      RECOMMENDED_PACKAGES_NOT_FOUND
      REQUIRED_PACKAGES_NOT_FOUND
    QUIET_ON_EMPTY
  )
endfunction()

# Print self-contained extension configuration summary.
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

  _php_summary_validate_extension(${extension})

  feature_summary(
    FATAL_ON_MISSING_REQUIRED_PACKAGES
    WHAT
      ENABLED_FEATURES
      RECOMMENDED_PACKAGES_NOT_FOUND
      REQUIRED_PACKAGES_NOT_FOUND
    QUIET_ON_EMPTY
  )
endfunction()
