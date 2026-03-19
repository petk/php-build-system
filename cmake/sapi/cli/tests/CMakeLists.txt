################################################################################
# Test "Configure Command" output in phpinfo().
################################################################################

add_test(NAME PhpTestConfigureCommand COMMAND PHP::sapi::cli -i)

if(PHP_CONFIGURE_COMMAND)
  set_tests_properties(
    PhpTestConfigureCommand
    PROPERTIES
      PASS_REGULAR_EXPRESSION "Configure Command => ${PHP_CONFIGURE_COMMAND}"
  )
else()
  set_tests_properties(
    PhpTestConfigureCommand
    PROPERTIES
      FAIL_REGULAR_EXPRESSION "Configure Command =>"
  )
endif()
