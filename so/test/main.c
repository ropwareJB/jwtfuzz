
#include <stdlib.h>
#include "entry.h"
// #include "Lib_stub.h"
//
extern void fuzzJwt(HsPtr a1);

int main(){
	jwtfuzz_init();

	// Do some compute here.
	fuzzJwt("abcd.abcd.aaaa");

	jwtfuzz_end();
	return 0;
}
