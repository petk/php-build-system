add_library(php_main STATIC
  explicit_bzero.c
  fastcgi.c
  fopen_wrappers.c
  internal_functions_cli.c
  internal_functions.c
  main.c
  network.c
  output.c getopt.c
  php_content_types.c
  php_ini_builder.c
  php_ini.c
  php_odbc_utils.c
  php_open_temporary_file.c
  php_scandir.c
  php_syslog.c
  php_ticks.c
  php_variables.c
  reentrancy.c
  rfc1867.c
  safe_bcmp.c
  SAPI.c
  snprintf.c
  spprintf.c
  streams/cast.c
  streams/filter.c
  streams/glob_wrapper.c
  streams/memory.c
  streams/mmap.c
  streams/plain_wrapper.c
  streams/streams.c
  streams/transports.c
  streams/userspace.c
  streams/xp_socket.c
  strlcat.c
  strlcpy.c
)

add_library(PHP::main ALIAS php_main)

target_compile_definitions(php_main PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_include_directories(
  php_configuration
  INTERFACE ${CMAKE_CURRENT_BINARY_DIR}
            ${CMAKE_CURRENT_SOURCE_DIR}
            ${PROJECT_BINARY_DIR}
            ${PROJECT_SOURCE_DIR}
)

# Link publicly for PHP SAPIs to consume it also.
target_link_libraries(php_main PUBLIC Zend::Zend)
target_link_libraries(php_main PUBLIC PHP::configuration)

# Add Zend's PUBLIC/INTERFACE compile options to configuration.
# Cleaner COMPILE_ONLY generator expression is available in CMake >= 3.27.
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.27)
  target_link_libraries(php_configuration INTERFACE $<COMPILE_ONLY:Zend::Zend>)
else()
  target_include_directories(php_configuration
    INTERFACE $<TARGET_PROPERTY:Zend::Zend,INTERFACE_INCLUDE_DIRECTORIES>
  )
endif()

# Add DTrace.
if(PHP_DTRACE)
  message(CHECK_START "Checking for DTrace support")

  find_package(DTrace)
  set_package_properties(DTrace PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the DTrace support."
  )

  if(DTrace_FOUND)
    get_target_property(
      _php_dtrace_includes
      php_configuration
      INTERFACE_INCLUDE_DIRECTORIES
    )

    dtrace_target(
      TARGET php_main
      INPUT ${PROJECT_SOURCE_DIR}/Zend/zend_dtrace.d
      HEADER ${PROJECT_BINARY_DIR}/Zend/zend_dtrace_gen.h
      SOURCES ${PROJECT_SOURCE_DIR}/main/main.c
              ${PROJECT_SOURCE_DIR}/Zend/zend_API.c
              ${PROJECT_SOURCE_DIR}/Zend/zend_dtrace.c
              ${PROJECT_SOURCE_DIR}/Zend/zend_exceptions.c
              ${PROJECT_SOURCE_DIR}/Zend/zend_execute.c
              ${PROJECT_SOURCE_DIR}/Zend/zend.c
      INCLUDES ${_php_dtrace_includes}
    )

    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

# Add Dmalloc.
if(PHP_DMALLOC)
  message(CHECK_START "Checking for Dmalloc support")

  find_package(Dmalloc)
  set_package_properties(Dmalloc PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to use Dmalloc memory debugger."
  )

  target_compile_definitions(
    php_configuration
    INTERFACE $<$<COMPILE_LANGUAGE:ASM,C,CXX>:MALLOC_FUNC_CHECK>
  )

  target_link_libraries(php_main PRIVATE Dmalloc::Dmalloc)

  if(Dmalloc_FOUND)
    message(CHECK_PASS "yes")
    set(HAVE_DMALLOC 1 CACHE INTERNAL "Whether the Dmalloc library is available")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

get_cmake_property(extensions PHP_EXTENSIONS)
foreach(extension IN LISTS extensions)
  if(NOT TARGET PHP::${extension})
    add_library(PHP::${extension} ALIAS php_${extension})
  endif()

  # Add extension's PUBLIC/INTERFACE compile options to configuration.
  # Cleaner COMPILE_ONLY generator expression is available in CMake >= 3.27.
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.27)
    target_link_libraries(php_configuration
      INTERFACE $<COMPILE_ONLY:PHP::${extension}>
    )
  else()
    target_include_directories(php_configuration
      INTERFACE $<TARGET_PROPERTY:PHP::${extension},INTERFACE_INCLUDE_DIRECTORIES>
    )
  endif()

  target_link_libraries(php_${extension} PRIVATE PHP::configuration)

  # Add configuration compile options before the extension compile options.
  target_compile_options(php_${extension}
    BEFORE PRIVATE
      $<TARGET_PROPERTY:php_configuration,INTERFACE_COMPILE_OPTIONS>
  )

  get_target_property(extension_type php_${extension} TYPE)

  if(extension_type STREQUAL "SHARED_LIBRARY")
    set_property(TARGET php_${extension} PROPERTY POSITION_INDEPENDENT_CODE TRUE)

    # On macOS, additional linker flags need to be passed for shared libraries.
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
      set_target_properties(
        php_${extension}
        PROPERTIES LINK_FLAGS "-undefined dynamic_lookup"
      )
    endif()
  else()
    target_link_libraries(php_main PRIVATE PHP::${extension})
  endif()
endforeach()

################################################################################
# Install headers.
################################################################################

function(_php_main_create_files)
  # Create main/internal_functions* files.
  set(EXT_INCLUDE_CODE "")
  set(EXT_MODULE_PTRS "")

  # Add artifacts of static enabled PHP extensions to symbol definitions.
  get_cmake_property(php_extensions PHP_EXTENSIONS)
  foreach(extension IN LISTS php_extensions)
    # Skip if extension is shared.
    get_target_property(extension_type php_${extension} TYPE)
    if(extension_type MATCHES "^(MODULE|SHARED)_LIBRARY$")
      continue()
    endif()

    file(GLOB_RECURSE extension_headers
      "${PROJECT_SOURCE_DIR}/ext/${extension}/*.h"
    )

    foreach(extension_header IN LISTS extension_headers)
      file(READ "${extension_header}" file_content)
      string(FIND "${file_content}" "phpext_" pattern_index)

      if(NOT pattern_index EQUAL -1)
        cmake_path(GET extension_header FILENAME file_name)
        set(
          EXT_INCLUDE_CODE
          "${EXT_INCLUDE_CODE}\n#include \"ext/${extension}/${file_name}\""
        )
      endif()
    endforeach()

    set(EXT_MODULE_PTRS "${EXT_MODULE_PTRS}\n\tphpext_${extension}_ptr,")
  endforeach()

  message(STATUS "Creating main/internal_functions.c")
  configure_file(main/internal_functions.c.in main/internal_functions.c)

  message(STATUS "Creating main/internal_functions_cli.c")
  configure_file(main/internal_functions.c.in main/internal_functions_cli.c)

  # TODO: Set configure command string.
  set(CONFIGURE_COMMAND "cmake")
  # Set the 'include_path' INI directive.
  set(INCLUDE_PATH ".:${EXPANDED_PEAR_INSTALLDIR}")
  set(EXPANDED_EXTENSION_DIR "${PHP_EXTENSION_DIR}")
  set(EXPANDED_PHP_CONFIG_FILE_PATH "${PHP_CONFIG_FILE_PATH}")
  set(EXPANDED_PHP_CONFIG_FILE_SCAN_DIR "${PHP_CONFIG_FILE_SCAN_DIR}")
  set(EXPANDED_BINDIR "${CMAKE_INSTALL_FULL_BINDIR}")
  set(EXPANDED_SBINDIR "${CMAKE_INSTALL_FULL_SBINDIR}")
  set(EXPANDED_MANDIR "${CMAKE_INSTALL_FULL_MANDIR}")
  set(EXPANDED_LIBDIR "${CMAKE_INSTALL_FULL_LIBDIR}")
  set(EXPANDED_DATADIR "${CMAKE_INSTALL_FULL_DATADIR}")
  set(EXPANDED_SYSCONFDIR "${CMAKE_INSTALL_FULL_SYSCONFDIR}")
  set(EXPANDED_LOCALSTATEDIR "${CMAKE_INSTALL_FULL_LOCALSTATEDIR}")
  set(prefix "${CMAKE_INSTALL_PREFIX}")
  # Set shared library object extension.
  string(REPLACE "." "" SHLIB_DL_SUFFIX_NAME ${CMAKE_SHARED_MODULE_SUFFIX})

  message(STATUS "Creating main/build-defs.h")
  configure_file(main/build-defs.h.in main/build-defs.h @ONLY)

  set(
    HAVE_BUILD_DEFS_H 1
    CACHE INTERNAL "Whether build-defs.h header file is present."
  )

  message(STATUS "Creating main/php_config.h")
  configure_file(main/php_config.cmake.h.in main/php_config.h @ONLY)

  message(STATUS "Creating main/php_version.h")
  configure_file(main/php_version.h.in main/php_version.h @ONLY)
endfunction()

# Run at the end of the configuration.
cmake_language(
  DEFER
    DIRECTORY ${PROJECT_SOURCE_DIR}
  CALL _php_main_create_files
)

file(GLOB_RECURSE _php_main_headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")

target_sources(
  php_main
  PUBLIC FILE_SET HEADERS
    BASE_DIRS "${PROJECT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}"
    FILES
      ${_php_main_headers}
      "${CMAKE_CURRENT_BINARY_DIR}/build-defs.h"
      "${CMAKE_CURRENT_BINARY_DIR}/php_config.h"
)

install(
  TARGETS php_main
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
