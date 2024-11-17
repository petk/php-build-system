<!-- This is auto-generated file. -->
# CheckListeningQueue

* Module source code: [CheckListeningQueue.cmake](https://github.com/petk/php-build-system/blob/master/cmake/sapi/fpm/cmake/CheckListeningQueue.cmake)

Check FPM listening queue implementation.

## Cache variables

* `HAVE_LQ_TCP_INFO`

  Whether `TCP_INFO` is present.

* `HAVE_LQ_TCP_CONNECTION_INFO`

  Whether `TCP_CONNECTION_INFO` is present.

* `HAVE_LQ_SO_LISTENQ`

  Whether `SO_LISTENQLEN` and `SO_LISTENQLIMIT` are available as alternative to
  `TCP_INFO` and `TCP_CONNECTION_INFO`.

## Basic usage

```cmake
# CMakeLists.txt
include(cmake/CheckListeningQueue.cmake)
```
