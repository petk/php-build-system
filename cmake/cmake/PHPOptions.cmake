option(DEBUG "Whether to include debugging symbols" OFF)

option(SHORT_TAGS "Whether to enable short tags by default" ON)

option(ZTS "Enable thread safety" OFF)

option(RTLD_NOW "Whether to dlopen extensions with RTLD_NOW instead of RTLD_LAZY" OFF)

option(IPV6 "Whether to enable IPv6 support" ON)

if(DEBUG)
  set(ZEND_DEBUG 1)
else()
  set(ZEND_DEBUG 0)
endif()

if(SHORT_TAGS)
  set(DEFAULT_SHORT_OPEN_TAG "1" CACHE STRING "Whether to enable the short-form <? start tag by default")
else()
  set(DEFAULT_SHORT_OPEN_TAG "0" CACHE STRING "Whether to enable the short-form <? start tag by default")
endif()

if(ZTS)
  set(ZTS 1 CACHE STRING "Whether thread safety is enabled")
endif()

if(RTLD_NOW)
  set(PHP_USE_RTLD_NOW 1 CACHE STRING "Use dlopen with RTLD_NOW instead of RTLD_LAZY")
endif()
