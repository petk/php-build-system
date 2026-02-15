# TODO: Recheck and fix this.

find_program(PHP_MIDL_EXECUTABLE midl)
mark_as_advanced(PHP_MIDL_EXECUTABLE)

if(NOT PHP_MIDL_EXECUTABLE)
  return()
endif()

add_library(php_ext_com_dotnet_comtest MODULE)

target_sources(
  php_ext_com_dotnet_comtest
  PRIVATE
    comtest/comtest.cpp
    comtest/comtest.def
    ${CMAKE_CURRENT_BINARY_DIR}/comtest/comtest_i.c
)

target_include_directories(
  php_ext_com_dotnet_comtest
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/comtest
)

target_compile_options(php_ext_com_dotnet_comtest PRIVATE /nologo)
target_link_libraries(php_ext_com_dotnet_comtest PRIVATE oleaut32)

add_dependencies(php_ext_com_dotnet php_ext_com_dotnet_comtest)

add_custom_command(
  OUTPUT
    comtest/comtest.h
    comtest/comtest_i.c
    comtest/comtest.tlb
  COMMAND
    ${PHP_MIDL_EXECUTABLE}
    /nologo
    /h ${CMAKE_CURRENT_BINARY_DIR}/comtest/comtest.h
    /iid ${CMAKE_CURRENT_BINARY_DIR}/comtest/comtest_i.c
    /tlb ${CMAKE_CURRENT_BINARY_DIR}/comtest/comtest.tlb
    ${CMAKE_CURRENT_SOURCE_DIR}/comtest/comtest.idl
  COMMENT "[ext/com_dotnet] Generating comtest library sources"
  VERBATIM
  COMMAND_EXPAND_LISTS
)

file(CONFIGURE OUTPUT register.cmake CONTENT [[
  message(STATUS "[ext/com_dotnet] Adding keys to Windows Registry for tests")

  execute_process(
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}\\1.0"
        /d "PHP COM Test Library"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}\\1.0\\0"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}\\1.0\\0\\win32"
        /d "@CMAKE_CURRENT_BINARY_DIR@/comtest/comtest.tlb"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}\\1.0\\0\\win64"
        /d "@CMAKE_CURRENT_BINARY_DIR@/comtest/comtest.tlb"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}\\1.0\\FLAGS"
        /d 0 /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}\\1.0\\HELPDIR"
        /d "@CMAKE_CURRENT_BINARY_DIR@/comtest"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\CLSID\\{B13FE324-D595-44C7-97D7-82CE20EDF878}"
        /d "PHP COM Test Document"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\CLSID\\{B13FE324-D595-44C7-97D7-82CE20EDF878}\\InprocServer32"
        /d "@CMAKE_CURRENT_BINARY_DIR@/comtest/comtest.dll"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\PHPTest.Document"
        /d "PHP COM Test Document"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\PHPTest.Document\\CLSID"
        /d "{B13FE324-D595-44C7-97D7-82CE20EDF878}"
        /f > NUL
  )
]])

file(CONFIGURE OUTPUT unregister.cmake CONTENT [[
  message(STATUS "[ext/com_dotnet] Removing keys from Windows Registry for tests")

  execute_process(
    COMMAND reg delete "HKCU\\SOFTWARE\\Classes\\PHPTest.Document" /f > NUL
    COMMAND reg delete "HKCU\\SOFTWARE\\Classes\\CLSID\\{B13FE324-D595-44C7-97D7-82CE20EDF878}" /f > NUL
    COMMAND reg delete "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}" /f > NUL
  )
]])

add_test(
  NAME PhpExtComDotNetRegisterComTest
  COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/register.cmake
)
set_tests_properties(
  PhpExtComDotNetRegisterComTest
  PROPERTIES
    FIXTURES_SETUP PhpExtComDotNetFixtures
)

add_test(
  NAME PhpExtComDotNetUnregisterComTest
  COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/unregister.cmake
)
set_tests_properties(
  PhpExtComDotNetUnregisterComTest
  PROPERTIES
    FIXTURES_CLEANUP PhpExtComDotNetFixtures
)

if(PHP_SOURCE_DIR)
  set(dir "${PHP_SOURCE_DIR}")
else()
  set(dir "${CMAKE_CURRENT_SOURCE_DIR}")
endif()

set_property(
  TEST PhpRunTests
  DIRECTORY ${dir}
  APPEND
  PROPERTY
  FIXTURES_REQUIRED PhpExtComDotNetFixtures
)
