include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/CheckCompilerFlag)

option(EXT_INTL "Enable the intl extension" OFF)

add_feature_info(
  "ext/intl"
  EXT_INTL
  "Support for internationalization, a wrapper for ICU library"
)

cmake_dependent_option(
  EXT_INTL_SHARED
  "Build the intl extension as a shared library"
  OFF
  "EXT_INTL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_INTL)
  return()
endif()

if(EXT_INTL_SHARED)
  add_library(php_intl SHARED)
else()
  add_library(php_intl)
endif()

target_sources(
  php_intl
  PRIVATE
    breakiterator/breakiterator_class.cpp
    breakiterator/breakiterator_iterators.cpp
    breakiterator/breakiterator_methods.cpp
    breakiterator/codepointiterator_internal.cpp
    breakiterator/codepointiterator_methods.cpp
    breakiterator/rulebasedbreakiterator_methods.cpp
    calendar/calendar_class.cpp
    calendar/calendar_methods.cpp
    calendar/gregoriancalendar_methods.cpp
    collator/collator_attr.c
    collator/collator_class.c
    collator/collator_compare.c
    collator/collator_convert.c
    collator/collator_create.c
    collator/collator_error.c
    collator/collator_is_numeric.c
    collator/collator_locale.c
    collator/collator_sort.c
    common/common_date.cpp
    common/common_enum.cpp
    common/common_error.c
    converter/converter.c
    dateformat/dateformat_attr.c
    dateformat/dateformat_attrcpp.cpp
    dateformat/dateformat_class.c
    dateformat/dateformat_create.cpp
    dateformat/dateformat_data.c
    dateformat/dateformat_format_object.cpp
    dateformat/dateformat_format.c
    dateformat/dateformat_helpers.cpp
    dateformat/dateformat_parse.c
    dateformat/dateformat.c
    dateformat/datepatterngenerator_class.cpp
    dateformat/datepatterngenerator_methods.cpp
    formatter/formatter_attr.c
    formatter/formatter_class.c
    formatter/formatter_data.c
    formatter/formatter_format.c
    formatter/formatter_main.c
    formatter/formatter_parse.c
    grapheme/grapheme_string.c
    grapheme/grapheme_util.c
    idn/idn.c
    intl_convert.c
    intl_convertcpp.cpp
    intl_error.c
    locale/locale_class.c
    locale/locale_methods.c
    locale/locale.c
    msgformat/msgformat_attr.c
    msgformat/msgformat_class.c
    msgformat/msgformat_data.c
    msgformat/msgformat_format.c
    msgformat/msgformat_helpers.cpp
    msgformat/msgformat_parse.c
    msgformat/msgformat.c
    normalizer/normalizer_class.c
    normalizer/normalizer_normalize.c
    php_intl.c
    resourcebundle/resourcebundle_class.c
    resourcebundle/resourcebundle_iterator.c
    resourcebundle/resourcebundle.c
    spoofchecker/spoofchecker_class.c
    spoofchecker/spoofchecker_create.c
    spoofchecker/spoofchecker_main.c
    timezone/timezone_class.cpp
    timezone/timezone_methods.cpp
    transliterator/transliterator_class.c
    transliterator/transliterator_methods.c
    uchar/uchar.c
)

php_check_compiler_flag(C -Wno-write-strings HAVE_WNO_WRITE_STRINGS_C)
if(HAVE_WNO_WRITE_STRINGS_C)
  target_compile_options(
    php_intl
    PRIVATE
      $<$<COMPILE_LANGUAGE:C>:-Wno-write-strings>
  )
endif()

php_check_compiler_flag(CXX -Wno-write-strings HAVE_WNO_WRITE_STRINGS_CXX)
if(HAVE_WNO_WRITE_STRINGS_CXX)
  target_compile_options(
    php_intl
    PRIVATE
      $<$<COMPILE_LANGUAGE:CXX>:-Wno-write-strings>
  )
endif()

target_compile_definitions(
  php_intl
  PRIVATE
    U_NO_DEFAULT_INCLUDE_UTF_HEADERS=1
    __STDC_LIMIT_MACROS
    __STDC_CONSTANT_MACROS
    __STDC_FORMAT_MACROS
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    $<$<COMPILE_LANGUAGE:CXX>:UNISTR_FROM_CHAR_EXPLICIT=explicit;UNISTR_FROM_STRING_EXPLICIT=explicit>
)

if(CMAKE_SYSTEM_NAME STREQUAL "CYGWIN")
  target_compile_definitions(
    php_intl
    PRIVATE
      $<$<COMPILE_LANGUAGE:CXX>:_POSIX_C_SOURCE=200809L>
  )
endif()

find_package(ICU 50.1 COMPONENTS io uc i18n)
set_package_properties(
  ICU
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the intl extension."
)

if(ICU_VERSION VERSION_GREATER_EQUAL 74)
  set_target_properties(
    php_intl
    PROPERTIES
      CXX_STANDARD 17
      CXX_STANDARD_REQUIRED TRUE
  )
else()
  set_target_properties(
    php_intl
    PROPERTIES
      CXX_STANDARD 11
      CXX_STANDARD_REQUIRED TRUE
  )
endif()

target_link_libraries(php_intl PRIVATE ICU::io ICU::uc ICU::i18n)

if(ICU_VERSION VERSION_GREATER_EQUAL 60)
  target_compile_definitions(php_intl PRIVATE U_HIDE_OBSOLETE_UTF_OLD_H=1)
endif()

add_dependencies(php_intl php_date)
