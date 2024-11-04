# `ZEND_FIBER_ASM`

Default: `ON`

Values: `ON|OFF`

Enable the use of Boost fiber assembly files using the
[Zend/Fibers](/docs/cmake/modules/Zend/Fibers.md) module. If disabled or system
isn't supported, fiber support will be run through the legacy ucontext.

> [!NOTE]
> When target system is Windows, this option is always set to `ON` and option is
> hidden in the CMake GUIs as there is no alternative implementation available.
