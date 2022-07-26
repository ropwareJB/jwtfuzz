
#include <stdio.h>
#include <stdlib.h>
#include "entry.h"
#include "Lib_stub.h"

#define EXAMPLE_JWT "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"

int main(){
	jwtfuzz_init();

	char** jwts = fuzzJwt(EXAMPLE_JWT);
	char* jwt = NULL;
	int i;
	for(i=0, jwt=jwts[i]; jwt != NULL; i++, jwt=jwts[i]){
	 printf("%s\n", jwt);
	}

	jwtfuzz_end();
	return 0;
}
