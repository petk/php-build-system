include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_IMAP "Enable the imap extension" OFF)

add_feature_info("ext/imap" EXT_IMAP
  "Support for operating with the IMAP protocol."
)

cmake_dependent_option(
  EXT_IMAP_SHARED
  "Build the imap extension as a shared library"
  OFF
  "EXT_IMAP;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  EXT_IMAP_KERBEROS
  "Include Kerberos support in imap extension"
  OFF
  "EXT_IMAP"
  OFF
)

cmake_dependent_option(
  EXT_IMAP_SSL
  "Include SSL support in imap extension"
  OFF
  "EXT_IMAP"
  OFF
)

if(NOT EXT_IMAP)
  return()
endif()

if(EXT_IMAP_SHARED)
  add_library(php_imap SHARED)
else()
  add_library(php_imap)
endif()

target_sources(
  php_imap
  PRIVATE
    php_imap.c
)

target_compile_definitions(php_imap PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(CClient)
set_package_properties(CClient PROPERTIES
  TYPE REQUIRED
  PURPOSE "Necessary to enable the imap extension."
)

target_link_libraries(
  php_imap
  PRIVATE
    $<$<PLATFORM_ID:Windows>:ws2_32;secur32;crypt32;winmm>
  # Link publicly for internal_functions files.
  PUBLIC
    CClient::CClient
)

block()
  message(CHECK_START "Checking for c-client version 2001")

  set(regex [[^[ \t]*#[ \t]*define[ \t]*IMAPSSLPORT[ \t]*\(]])
  file(STRINGS ${CClient_INCLUDE_DIRS}/imap4r1.h results REGEX "${regex}")

  foreach(line ${results})
    if(line MATCHES "${regex}")
      set(have_imapsslport TRUE)
      break()
    endif()
  endforeach()

  if(have_imapsslport)
    message(CHECK_PASS "yes")
    set(
      HAVE_IMAP2001 1
      CACHE INTERNAL "Whether c-client version is 2001 or newer"
    )
  else()
    message(CHECK_FAIL "no")
  endif()
endblock()

message(CHECK_START "Checking for c-client version 2004")
cclient_check_symbol(mail_fetch_overview_sequence HAVE_IMAP2004)
if(HAVE_IMAP2004)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

message(CHECK_START "Checking for new utf8_mime2text signature")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_LIBRARIES CClient::CClient)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_source_compiles(C [[
    #include <stdio.h>
    #include <c-client.h>

    int main(void) {
      SIZEDTEXT *src, *dst;
      utf8_mime2text(src, dst);
      return 0;
    }
  ]] _HAVE_OLD_MIME2TEXT)
cmake_pop_check_state()
if(_HAVE_OLD_MIME2TEXT)
  message(CHECK_FAIL "no")
else()
  set(
    HAVE_NEW_MIME2TEXT 1
    CACHE INTERNAL "Whether utf8_mime2text() has new signature"
  )
  message(CHECK_PASS "yes")
endif()

check_symbol_exists(
  U8T_DECOMPOSE
  "${CClient_INCLUDE_DIRS}/c-client.h"
  _HAVE_U8T_DECOMPOSE
)

if(HAVE_NEW_MIME2TEXT AND NOT _HAVE_U8T_DECOMPOSE)
  message(
    FATAL_ERROR
    "utf8_mime2text() has new signature, but U8T_CANONICAL is missing. This "
    "should not happen. Check CMake logs for additional information."
  )
elseif(_HAVE_OLD_MIME2TEXT AND _HAVE_U8T_DECOMPOSE)
  message(
    FATAL_ERROR
    "utf8_mime2text() has old signature, but U8T_CANONICAL is present. This "
    "should not happen. Check CMake logs for additional information."
  )
endif()

block()
  message(CHECK_START "Checking for Kerberos support in imap extension")

  set(regex [[auth_gss;$]])
  file(STRINGS ${CClient_INCLUDE_DIRS}/linkage.h results REGEX "${regex}")

  foreach(line ${results})
    if(line MATCHES "${regex}")
      set(have_auth_gss TRUE)
      break()
    endif()
  endforeach()

  if((NOT EXT_IMAP_KERBEROS AND have_auth_gss) OR EXT_IMAP_KERBEROS)
    find_package(Kerberos COMPONENTS Krb5 GSSAPI)
    set_package_properties(Kerberos PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary for Kerberos support in the imap extension."
    )

    target_link_libraries(php_imap PRIVATE Kerberos::Kerberos)

    if(Kerberos_FOUND)
      set(HAVE_IMAP_KRB 1 CACHE INTERNAL "Whether imap has Kerberos support")
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "failed")

      if(have_auth_gss)
        message(
          WARNING
          "The imap extenson requires Kerberos because c-client library is "
          "built with Kerberos support."
        )
      endif()
    endif()
  else()
    message(CHECK_FAIL "no")
  endif()
endblock()

block()
  message(CHECK_START "Checking for SSL support in imap extension")

  set(regex [[ssl_onceonlyinit[ \t]*\(\);$]])
  file(STRINGS ${CClient_INCLUDE_DIRS}/linkage.c results REGEX "${regex}")

  foreach(line ${results})
    if(line MATCHES "${regex}")
      set(have_ssl_onceonlyinit TRUE)
      break()
    endif()
  endforeach()

  if((NOT EXT_IMAP_SSL AND have_ssl_onceonlyinit) OR EXT_IMAP_SSL)
    find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION})
    set_package_properties(OpenSSL PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable SSL in the imap extension."
    )

    target_link_libraries(php_imap PRIVATE OpenSSL::SSL)

    if(OpenSSL_FOUND)
      set(HAVE_IMAP_SSL 1 CACHE INTERNAL "Whether imap extension has SSL")
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "failed")

      if(have_ssl_onceonlyinit)
        message(
          WARNING
          "The imap extension requires SSL becasue c-client library is built "
          "with SSL support."
        )
      endif()
    endif()
  else()
    message(CHECK_FAIL "no")
  endif()
endblock()

cclient_check_symbol(rfc822_output_address_list HAVE_RFC822_OUTPUT_ADDRESS_LIST)
cclient_check_symbol(auth_gssapi_valid HAVE_IMAP_AUTH_GSS)
cclient_check_symbol(utf8_to_mutf7 HAVE_IMAP_MUTF7)
