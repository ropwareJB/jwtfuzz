
#include <stdlib.h>
#include "entry.h"
#include "Lib_stub.h"

int main(){
	jwtfuzz_init();

	// Do some compute here.
	fuzzJwt("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c");

	jwtfuzz_end();
	return 0;
}
