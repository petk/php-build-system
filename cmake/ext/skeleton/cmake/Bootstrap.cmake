# Set GNU standard installation directories.
include(GNUInstallDirs)

# Run at the end of the extension's configuration phase.
cmake_language(DEFER DIRECTORY ${CMAKE_SOURCE_DIR} CALL _php_hook_end_of_configure())
function(_php_hook_end_of_configure)
  message(STATUS "********PHP Bootstrap********")
  message(STATUS "This is executed at the end of the extension's configuration.")
  message(STATUS "********PHP Bootstrap********")
endfunction()
