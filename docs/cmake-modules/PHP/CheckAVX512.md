# PHP/CheckAVX512

Check whether compiler supports AVX-512 extensions. Note that this is a compiler
check, not a runtime check where further adjustments are done in the php-src C
code to use these extensions.

TODO: Adjust checks for MSVC.

Cache variables:

* `PHP_HAVE_AVX512_SUPPORTS`
  Whether compiler supports AVX-512.
* `PHP_HAVE_AVX512_VBMI_SUPPORTS`
  Whether compiler supports AVX-512 VBMI.
