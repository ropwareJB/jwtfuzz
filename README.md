
# JwtFuzz

A Library for fuzzing & attacking JSON Web Tokens (JWTs) for use in Penetration Testing and security auditing. Bindings for other languages included.

### TODO
- Compile to shared object
Compiling to shared obj is working manually, however not normally supported by stack.
Requires a patch to hpack to support.
https://github.com/sol/hpack/issues/258
- Python bindings
- Go bindings
- Release on Hackage/Stackage
- Release to PyPy
- Package as Archlinux AUR bin
- Burp Extension?
- Write to File
- Take in list of payloads to insert
- Sign tokens with key
- Psychic Signatures


### Inspiration

Thanks to Alex Wells for his original JWT Fuzz utility on his blog:
https://node-security.com/posts/jwt-fuzzing/
