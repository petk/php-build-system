# PHP/InterproceduralOptimization

Enable interprocedural optimization (IPO), if supported.

Interprocedural optimization adds linker flag `-flto` if it is supported by the
compiler to run standard link-time optimizer.

It can be also controlled more granular by the user with the
`CMAKE_INTERPROCEDURAL_OPTIMIZATION_<CONFIG>` variables based on the build type.

https://cmake.org/cmake/help/latest/prop_tgt/INTERPROCEDURAL_OPTIMIZATION.html
