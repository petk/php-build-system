include(FeatureSummary)
include(PHP/Install)

option(PHP_PEAR "Whether to install PEAR" OFF)

add_feature_info(
  "PEAR"
  PHP_PEAR
  "PHP Extension and Application Repository package manager"
)

if(PHP_PEAR)
  set(
    PHP_PEAR_DIR "${CMAKE_INSTALL_DATADIR}/pear"
    CACHE FILEPATH
    "The PEAR installation directory. CMAKE_INSTALL_PREFIX is automatically\
    prepended when given as relative path. Default: DATADIR/pear"
  )
  # Change from INTERNAL type to show variable on consecutive configuration run.
  set_property(CACHE PHP_PEAR_DIR PROPERTY TYPE FILEPATH)
elseif(DEFINED PHP_PEAR_DIR)
  # Hide variable.
  set_property(CACHE PHP_PEAR_DIR PROPERTY TYPE INTERNAL)
endif()
mark_as_advanced(PHP_PEAR_DIR)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(tmpDir "C:/temp/pear")
else()
  set(tmpDir "/tmp/pear")
endif()
if(PHP_PEAR)
  set(
    PHP_PEAR_TEMP_DIR "${tmpDir}"
    CACHE FILEPATH
    "The PEAR temporary directory where PEAR writes temporary files, such as\
    cache, downloaded packages artefacts and similar. Must be absolute path.\
    Default: ${tmpDir}."
  )
  # Change from INTERNAL type to show variable on consecutive configuration run.
  set_property(CACHE PHP_PEAR_TEMP_DIR PROPERTY TYPE FILEPATH)
elseif(DEFINED PHP_PEAR_TEMP_DIR)
  # Hide variable.
  set_property(CACHE PHP_PEAR_TEMP_DIR PROPERTY TYPE INTERNAL)
endif()
mark_as_advanced(PHP_PEAR_TEMP_DIR)

message(CHECK_START "Checking for PEAR")

if(NOT PHP_PEAR)
  message(CHECK_FAIL "no")
  return()
else()
  message(CHECK_PASS "yes")
endif()

message(DEPRECATION "The PHP_PEAR option is deprecated.")

if(NOT SAPI_CLI)
  message(
    FATAL_ERROR
    "The PHP_PEAR option requires CLI SAPI. Please set SAPI_CLI to 'ON'."
  )
endif()

# Check PEAR dependencies.
if(NOT EXT_XML)
  message(
    FATAL_ERROR
    "PEAR requires the xml extension to be enabled. Set EXT_XML to 'ON'.")
endif()

set(PHP_EXECUTABLE)
if(NOT CMAKE_CROSSCOMPILING)
  set(PHP_EXECUTABLE "$<TARGET_FILE:php_cli>")
elseif(CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)
  set(PHP_EXECUTABLE "${CMAKE_CROSSCOMPILING_EMULATOR};$<TARGET_FILE:php_cli>")
endif()

php_install(CODE "
  set(phpPearInstallDir \"$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_PEAR_DIR},\${CMAKE_INSTALL_PREFIX}>\")
  set(phpPearInstallBinDir \"$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_BINDIR},\${CMAKE_INSTALL_PREFIX}>\")
  set(phpPearCurrentSourceDir \"${CMAKE_CURRENT_SOURCE_DIR}\")
  set(phpPearCurrentBinaryDir \"${CMAKE_CURRENT_BINARY_DIR}\")
  set(phpPearPhpExecutable \"${PHP_EXECUTABLE}\")
  set(phpExtensionDir \"$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_EXTENSION_DIR},\${CMAKE_INSTALL_PREFIX}>\")
  # When the xml extension is shared, it must be loaded for the PHP_EXECUTABLE.
  set(EXT_XML_SHARED ${EXT_XML_SHARED})
  if(EXT_XML_SHARED)
    set(phpPearOptions -d extension_dir=${PHP_BINARY_DIR}/modules -d extension=xml)
  endif()
  set(phpPearTempDir \"${PHP_PEAR_TEMP_DIR}\")
  set(phpPearInstalledPhpBin \"\${phpPearInstallBinDir}/$<TARGET_FILE_NAME:php_cli>\")
  set(phpPearPhpProgramPrefix \"${PHP_PROGRAM_PREFIX}\")
  set(phpPearPhpProgramSuffix \"${PHP_PROGRAM_SUFFIX}\")
  set(phpPearInstallSysconfDir \"\${CMAKE_INSTALL_FULL_SYSCONFDIR}\")
")
install(SCRIPT InstallPear.cmake)
