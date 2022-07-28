#include <stdlib.h>
#include "HsFFI.h"

HsBool jwtfuzz_init(void);
void jwtfuzz_free(char* err, char** jwts);
void jwtfuzz_end(void);
