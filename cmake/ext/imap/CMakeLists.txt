include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_IMAP "Enable the imap extension" OFF)

add_feature_info(
  "ext/imap"
  EXT_IMAP
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

find_package(Cclient)
set_package_properties(
  Cclient
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the imap extension."
)

target_link_libraries(
  php_imap
  PRIVATE
    $<$<PLATFORM_ID:Windows>:ws2_32;secur32;crypt32;winmm>
  # Link publicly for internal_functions files.
  PUBLIC
    Cclient::Cclient
)

if(TARGET Cclient::Cclient)
  block()
    message(CHECK_START "Checking for Kerberos support in imap extension")

    file(
      STRINGS
      ${Cclient_INCLUDE_DIR}/linkage.h
      auth_gss_results
      REGEX
      [[auth_gss;$]]
    )

    if((NOT EXT_IMAP_KERBEROS AND auth_gss_results) OR EXT_IMAP_KERBEROS)
      find_package(Kerberos COMPONENTS Krb5 GSSAPI)
      set_package_properties(
        Kerberos
        PROPERTIES
          TYPE REQUIRED
          PURPOSE "Necessary for Kerberos support in the imap extension."
      )

      target_link_libraries(php_imap PRIVATE Kerberos::Krb5 Kerberos::GSSAPI)

      if(Kerberos_FOUND)
        set(HAVE_IMAP_KRB 1 CACHE INTERNAL "Whether imap has Kerberos support")
        message(CHECK_PASS "yes")
      else()
        message(CHECK_FAIL "failed")

        if(auth_gss_results)
          message(
            WARNING
            "The imap extension requires Kerberos because c-client library is "
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

    file(
      STRINGS
      ${Cclient_INCLUDE_DIR}/linkage.c
      ssl_onceonlyinit_results
      REGEX
      [[ssl_onceonlyinit[ \t]*\(\);$]]
    )

    if((NOT EXT_IMAP_SSL AND ssl_onceonlyinit_results) OR EXT_IMAP_SSL)
      find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION})
      set_package_properties(
        OpenSSL
        PROPERTIES
          TYPE REQUIRED
          PURPOSE "Necessary to enable SSL in the imap extension."
      )

      target_link_libraries(php_imap PRIVATE OpenSSL::SSL)

      if(OpenSSL_FOUND)
        set(HAVE_IMAP_SSL 1 CACHE INTERNAL "Whether imap extension has SSL")
        message(CHECK_PASS "yes")
      else()
        message(CHECK_FAIL "failed")

        if(ssl_onceonlyinit_results)
          message(
            WARNING
            "The imap extension requires SSL because c-client library is built "
            "with SSL support."
          )
        endif()
      endif()
    else()
      message(CHECK_FAIL "no")
    endif()
  endblock()
endif()
