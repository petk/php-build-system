# `ZEND_GLOBAL_REGISTER_VARIABLES`

* Default: `ON`
* Values: `ON|OFF`

When enabled, the
[Zend/CheckGlobalRegisterVariables](/docs/cmake/modules/Zend/CheckGlobalRegisterVariables.md)
module checks whether the compiler and target system support the so-called
global register variables. If not supported, they will be disabled.
