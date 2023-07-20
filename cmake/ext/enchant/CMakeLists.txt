option(enchant "Whether to build the enchant extension" OFF)

if(enchant)
  php_extension(NAME enchant)

  add_library(ext_enchant
    enchant.c
  )
endif()
