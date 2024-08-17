# Frequently asked questions

This is a collection of some explanations discovered during making the build
system.

## Preprocessor macros in configuration header file

The configuration header (`main/php_config.h` on *nix systems and
`main/config.w32.h` on Windows) is generated during the configuration step
based on the tests for particular system. The style might be on the first glance
very inconsistent due to history reasons.

For example,

some macros have two states like undefined/defined, some have undefined/defined
to 1, and some have defined to 0 or 1. In modern code the preprocessor macros
are in theory considered a bad practice due to making the C code unreadable.
However, in practice they are unavoidable to ensure the code works on a variety
of systems.
