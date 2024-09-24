# PHP/CheckListeningQueue

See: [CheckListeningQueue.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/CheckListeningQueue.cmake)

Check for items required by listening queue implemented in FPM.

Cache variables:

* `HAVE_LQ_TCP_INFO`
  Whether `TCP_INFO` is present.
* `HAVE_LQ_TCP_CONNECTION_INFO`
  Whether `TCP_CONNECTION_INFO` is present.
* `HAVE_LQ_SO_LISTENQ`
  Whether `SO_LISTENQLEN` and `SO_LISTENQLIMIT` are available as alternative to
  `TCP_INFO` and `TCP_CONNECTION_INFO`.
