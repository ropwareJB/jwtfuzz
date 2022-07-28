
# JwtFuzz

A Library for fuzzing & attacking JSON Web Tokens (JWTs) for use in Penetration Testing and security auditing. Bindings for other languages included.

## Using as a Binary

The `jwtfuzz-exe` binary can be used to generate a series of 'bad' JWT input with various modifications applied, including null signatures, swapped algorithms, psychic signatures, etc. Simply provide a JWT of valid form to stdin;

```
> echo "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c" | ./jwtfuzz-exe
...ommitted...
eyJhbGciOiJOT05FIiwidHlwIjoiSldUIn0.eyJpYXQiOjE1MTYyMzkwMjIsIm5hbWUiOiJKb2huIERvZSIsInN1YiI6IjEyMzQ1Njc4OTAifQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c=
...ommitted...
```

## Using as a Library

The fuzzing functions are also provided as a Unix Shared Library (.so) and Windows DLL.

You can call the library from C or any language in which you can utilize dynamic-library or a Foreign Function Interface (FFI). An example may be found in the `./so/test` directory, which demonstrates usage in C.

This module requires that the `jwtfuzz_init()` function is called to initialize the GHC runtime before you call any of the other library functions. Following, you may call `char** fuzzjwt_fuzz(char** err_ptr, char* jwt)` to generate a series of malicious input.

#### Handling Errors

`err_ptr` should be initialized to NULL prior to calling `fuzzjwt_fuzz` and associated functions. If an error occurred, this variable will be populated with a pointer to a string allocated on the Heap describing an error that occurred.

#### Memory Allocation

Usage of this library allocates memory on the Heap. After consumption of the returned JWTs and `err_ptr`, they must be free'd or you will have a memory leak (overconsumption, not disclosure) in your program whenever you fuzz a JWT. Please see `./so/test/main.c` for an example.

## Compilation

Requires forked hpack (PR open to hpack):
https://github.com/sol/hpack/pull/518

#### Binary
```
make bin
```

#### Shared Library

```
make so
```

### Inspiration

Thanks to Alex Wells for his very useful original JWT Fuzz utility on his blog:
https://node-security.com/posts/jwt-fuzzing/

