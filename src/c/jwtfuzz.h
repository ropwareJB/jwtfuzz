#include <stdlib.h>
#include "HsFFI.h"

/* Attempt to include exposed functions here as well, instead of using the generated stub. */
#if defined(__cplusplus)
extern "C" {
#endif
extern HsPtr fuzzjwt_fuzz(HsPtr a1, HsPtr a2);
#if defined(__cplusplus)
}
#endif

HsBool jwtfuzz_init(void);
void jwtfuzz_free(char* err, char** jwts);
void jwtfuzz_end(void);
