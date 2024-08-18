# Frequently asked questions

This is a collection of some explanations discovered during making the build
system.

## Preprocessor macros in configuration header file

The configuration header (`main/php_config.h` on *nix systems and
`main/config.w32.h` on Windows) is generated during the configuration step
based on the tests for particular system. The style might be on the first glance
very inconsistent due to history reasons.

For example,

some macros have two states like *undefined/defined*, some have
*undefined/defined to 1*, and some have *defined to 0 or 1*. In modern code the
preprocessor macros are in theory considered a bad practice due to making the C
code unreadable. However, in practice they are unavoidable to ensure the
portability of the code on a variety of systems.

The *undefined/defined to 1* style is there mostly due to the Autotools historic
reasons where in the early C days it was easier to write C like this:

```c
#if HAVE_SOMETHING
    /* ... */
#endif
```

When `HAVE_SOMETHING` is not defined, compiler automatically resolves it to
value `0`. However, in today's C code the `-Wundef` warnings appear in such code
if `HAVE_SOMETHING` is undefined, so the code should be written as:

```c
#ifdef HAVE_SOMETHING
    /* ... */
#endif
```

The *undefined/defined to 1* is in these configuration headers only a relic from
the past. New code can use the *undefined/defined* states or
*defined to 0 or 1*.
