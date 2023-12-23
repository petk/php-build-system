# Introduction to compiling C programs

Building a C program is a 4-step process in which the source code is translated
to a machine readable format ready to be executed:

* Preprocessing
* Compiling
* Assembly
* Linking

For the purposes of this introduction, let's create a simple "Hello world" C
program `main.c`:

```c
/* Include a standard header that declares functions dealing with standard input
   and output. */
#include <stdio.h>

/* Define a macro with a string value. */
#define MY_NAME "John Doe"

/**
 * The main function in C is a special entry point of a program where the
 * execution begins.
 */
int main(void) {
  printf("%s\n", MY_NAME);

  return 0;
}
```

## Preprocessing

The first step in building the C program is to run a preprocessor on the source
code. Preprocessor in its basics removes all the comments from the source code,
includes the header files, and replaces macro definitions in the code. To see
the preprocessing output result run `gcc -E`:

```sh
gcc -E main.c
```

## Compiling

In the next step, the preprocessed file is passed to the compiler which
generates assembly code.

This could be analogous to running this and stop at the compilation step:

```sh
gcc -c main.c
```

## Assembly

In this step the assembly code is passed to the assembler which assembles the
code into an object file.

To stop at the assembly step:

```sh
gcc -S main.c
```

## Linking

Once the code is preprocessed, compiled, and assembled, the object file is ready
to be converted to a library or executable.

To build an executable:

```sh
gcc main.c
```

## See also

Some excellent resources to checkout:

* [How does Linux execute my main()?](https://linuxgazette.net/84/hawk.html)
* [PHP Internals Book](https://www.phpinternalsbook.com/) - Useful resource to
  learn more about PHP internals.
