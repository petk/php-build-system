add_executable(php_sapi_embed_shared_test_basic basic.c)

target_link_libraries(
  php_sapi_embed_shared_test_basic
  PRIVATE
    PHP::sapi::embed_shared
    PHP::config
)

add_test(
  NAME PhpSapiEmbedSharedBasic
  COMMAND php_sapi_embed_shared_test_basic
)

set_property(
  TEST PhpSapiEmbedSharedBasic
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
  NAME PhpSapiEmbedStaticBasic
  COMMAND php_sapi_embed_static_test_basic
)

set_property(
  TEST PhpSapiEmbedStaticBasic
  PROPERTY PASS_REGULAR_EXPRESSION "Number of functions loaded: [0-9]+"
)
