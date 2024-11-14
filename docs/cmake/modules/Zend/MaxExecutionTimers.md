# MaxExecutionTimers

See: [MaxExecutionTimers.cmake](https://github.com/petk/php-build-system/blob/master/cmake/Zend/cmake/MaxExecutionTimers.cmake)

## Basic usage

```cmake
include(cmake/MaxExecutionTimers.cmake)
```

Check whether to enable Zend max execution timers.

## Cache variables

* [`ZEND_MAX_EXECUTION_TIMERS`](/docs/cmake/variables/ZEND_MAX_EXECUTION_TIMERS.md)

* `HAVE_TIMER_CREATE`

  Whether the system has `timer_create()`.

## Result variables

* `ZEND_MAX_EXECUTION_TIMERS`

  A local variable based on the cache variable and thread safety to be able to
  run consecutive configuration runs. When `ZEND_MAX_EXECUTION_TIMERS` cache
  variable is set to 'auto', local variable default value is set to the
  `PHP_THREAD_SAFETY` value.

## INTERFACE IMPORTED library

* `Zend::MaxExecutionTimers`

  Includes possible additional library to be linked for using `timer_create()`
  and a compile definition.
