include(CheckSourceCompiles)
include(CMakeDependentOption)

################################################################################
# Configuration options.
################################################################################

option(SAPI_PHPDBG "Enable the phpdbg SAPI module" ON)

cmake_dependent_option(
  SAPI_PHPDBG_SHARED
  "Build phpdbg SAPI as a shared module"
  OFF
  "SAPI_PHPDBG"
  OFF
)

# TODO: Check if this can be simplified in favor of the CMake's Debug build type.
cmake_dependent_option(
  SAPI_PHPDBG_DEBUG
  "Build phpdbg SAPI in debug mode"
  OFF
  "SAPI_PHPDBG"
  OFF
)

# TODO: Check if this can be simplified and removed by only checking if
# ext/readline extension has been enabled during the build.
cmake_dependent_option(
  SAPI_PHPDBG_READLINE
  "Enable readline support in phpdbg (depends on ext/readline)"
  OFF
  "SAPI_PHPDBG"
  OFF
)

message(CHECK_START "Checking whether to build phpdbg SAPI")
if(SAPI_PHPDBG)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
  return()
endif()

################################################################################
# Executable and library.
################################################################################

set(php_phpdbg_sources
  phpdbg_bp.c
  phpdbg_break.c
  phpdbg_btree.c
  phpdbg_cmd.c
  phpdbg_frame.c
  phpdbg_help.c
  phpdbg_info.c
  phpdbg_io.c
  phpdbg_lexer.c
  phpdbg_list.c
  phpdbg_out.c
  phpdbg_parser.c
  phpdbg_print.c
  phpdbg_prompt.c
  phpdbg_set.c
  phpdbg_sigsafe.c
  phpdbg_utils.c
  phpdbg_watch.c
  $<$<PLATFORM_ID:Windows>:phpdbg_win.c>
  phpdbg.c
)

add_executable(php_phpdbg ${php_phpdbg_sources})

target_compile_definitions(
  php_phpdbg
  PRIVATE
    _GNU_SOURCE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    $<$<PLATFORM_ID:Windows>:YY_NO_UNISTD_H>
)

target_link_libraries(
  php_phpdbg
  PRIVATE
    PHP::main
    $<$<PLATFORM_ID:Windows>:ws2_32;user32>
)

target_link_options(
  php_phpdbg
  PRIVATE
    $<$<PLATFORM_ID:Windows>:/stack:8388608>
)

set_target_properties(
  php_phpdbg
  PROPERTIES
    OUTPUT_NAME phpdbg
    # TODO: Check if there's a better solution here:
    ENABLE_EXPORTS TRUE
)

################################################################################
# Readline support.
################################################################################

message(CHECK_START "Checking for readline support in phpdbg")

if(SAPI_PHPDBG_READLINE AND EXT_READLINE)
  if(EXT_READLINE_LIBREADLINE)
    message(CHECK_PASS "enabled (readline)")
  else()
    message(CHECK_PASS "enabled (libedit)")
  endif()

  # Check and use ext/readline if enabled and built statically.
  target_link_libraries(
    php_phpdbg
    PRIVATE
      $<$<TARGET_EXISTS:php_readline>:$<TARGET_PROPERTY:php_readline,IMPORTED_LINK_INTERFACE_LIBRARIES>>
  )

  set(HAVE_PHPDBG_READLINE 1 CACHE INTERNAL "Whether phpdbg has readline support")
elseif(SAPI_PHPDBG_READLINE)
  message(CHECK_FAIL "disabled")
  message(WARNING "Set 'EXT_READLINE=ON' to enable readline support in phpdbg")
else()
  message(CHECK_FAIL "disabled")
endif()

################################################################################
# The phpdbg shared library.
################################################################################

# TODO: Should ext/readline be linked here also like in the phpdbg executable?
if(SAPI_PHPDBG_SHARED)
  add_library(php_phpdbg_shared SHARED)

  set_target_properties(php_phpdbg_shared PROPERTIES OUTPUT_NAME phpdbg)

  target_sources(php_phpdbg_shared PRIVATE ${php_phpdbg_sources})

  target_compile_definitions(
    php_phpdbg_shared
    PRIVATE
      $<TARGET_PROPERTY:PHP::main,INTERFACE_COMPILE_DEFINITIONS>
      $<$<PLATFORM_ID:Windows>:YY_NO_UNISTD_H>
  )

  target_include_directories(
    php_phpdbg_shared
    PRIVATE
      $<TARGET_PROPERTY:PHP::main,INTERFACE_INCLUDE_DIRECTORIES>
  )

  target_compile_options(
    php_phpdbg_shared
    PRIVATE $<TARGET_PROPERTY:PHP::main,INTERFACE_COMPILE_OPTIONS>
  )

  target_link_libraries(
    php_phpdbg_shared
    PRIVATE
      # TODO: fix this better in the future (building with -fPIC etc).
      #PHP::main
      $<$<PLATFORM_ID:Windows>:ws2_32;user32>
  )
endif()

################################################################################
# Generate lexers and parsers.
################################################################################

if(BISON_FOUND)
  bison_target(
    php_phpdbg_parser
    phpdbg_parser.y
    ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.c
    COMPILE_FLAGS "-Wall -v -d"
    DEFINES_FILE ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.h
  )
endif()

if(RE2C_FOUND)
  re2c_target(
    NAME php_phpdbg_lexer
    INPUT ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_lexer.l
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_lexer.c
    OPTIONS --no-generation-date -cbdF
  )
endif()

################################################################################
# Configuration checks.
################################################################################

include(PHP/CheckTiocgwinsz)

if(SAPI_PHPDBG_DEBUG)
  set(PHPDBG_DEBUG 1 CACHE INTERNAL "Whether phpdbg debugging is enabled")
else()
  set(PHPDBG_DEBUG 0 CACHE INTERNAL "Whether phpdbg debugging is enabled")
endif()

message(CHECK_START "Checking for userfaultfd faulting on write-protected memory support")
check_source_compiles(C "
  #include <linux/userfaultfd.h>
  #ifndef UFFDIO_WRITEPROTECT_MODE_WP
  # error userfaults on write-protected memory not supported
  #endif
  int main(void) {
    return 0;
  }
" _HAVE_USERFAULTFD_WRITEFAULT)
if(_HAVE_USERFAULTFD_WRITEFAULT)
  if(PHP_THREAD_SAFETY)
    set(
      HAVE_USERFAULTFD_WRITEFAULT 1
      CACHE INTERNAL "Whether faulting on write-protected memory support can \
be compiled for userfaultfd"
    )
    message(CHECK_PASS "yes")
  else()
    set(THREADS_PREFER_PTHREAD_FLAG TRUE)
    find_package(Threads)

    if(Threads_FOUND)
      message(CHECK_PASS "yes")

      set(
        HAVE_USERFAULTFD_WRITEFAULT 1
        CACHE INTERNAL "Whether faulting on write-protected memory support can \
be compiled for userfaultfd"
      )

      target_link_libraries(php_phpdbg PRIVATE Threads::Threads)
    else()
      message(CHECK_FAIL "no")
      message(WARNING "Threads not available.")
    endif()
  endif()
else()
  message(CHECK_FAIL "no")
endif()

set(HAVE_PHPDBG 1 CACHE INTERNAL "Whether the phpdbg SAPI is enabled")

################################################################################
# Installation.
################################################################################

# Man documentation.
block()
  # TODO: Add @program_prefix@
  set(program_prefix "")
  configure_file(phpdbg.1.in phpdbg.1 @ONLY)
endblock()

# TODO: Add prefix and suffix to installed executable file.
install(
  TARGETS php_phpdbg
  RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# TODO: Add prefix and suffix to installed man documentation file.
install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/phpdbg.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)

# Create log and run directories on installation.
install(DIRECTORY DESTINATION ${CMAKE_INSTALL_LOCALSTATEDIR}/log)
install(DIRECTORY DESTINATION ${CMAKE_INSTALL_LOCALSTATEDIR}/run)
