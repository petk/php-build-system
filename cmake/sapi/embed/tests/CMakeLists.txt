if(NOT PHP_ENABLE_TESTING)
  return()
endif()

add_executable(php_sapi_embed_shared_test_basic basic.c)

target_link_libraries(
  php_sapi_embed_shared_test_basic
  PRIVATE
    PHP::sapi::embed_shared
    PHP::config
)

add_test(
  NAME php_sapi_embed_shared_test_basic
  COMMAND php_sapi_embed_shared_test_basic
)

set_property(
  TEST php_sapi_embed_shared_test_basic
  PROPERTY PASS_REGULAR_EXPRESSION "Number of functions loaded: [0-9]+"
)

add_executable(php_sapi_embed_static_test_basic basic.c)

target_link_libraries(
  php_sapi_embed_static_test_basic
  PRIVATE
    PHP::sapi::embed
    PHP::config
)

add_test(
  NAME php_sapi_embed_static_test_basic
  COMMAND php_sapi_embed_static_test_basic
)

set_property(
  TEST php_sapi_embed_static_test_basic
  PROPERTY PASS_REGULAR_EXPRESSION "Number of functions loaded: [0-9]+"
)
