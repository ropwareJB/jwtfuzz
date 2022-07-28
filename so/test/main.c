
#include <stdio.h>
#include <stdlib.h>
#include <entry.h>
#include <Lib_stub.h>

#define EXAMPLE_JWT_VALID "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
#define EXAMPLE_JWT_INVALID "..."

void* fuzzJwt(char* jwt);

int main(){
	jwtfuzz_init();

	fuzzJwt(EXAMPLE_JWT_VALID);
	fuzzJwt(EXAMPLE_JWT_INVALID);

	jwtfuzz_end();
	return 0;
}

void* fuzzJwt(char* jwt){
	char* fuzz_err = NULL;
	char** jwts = fuzzjwt_fuzz(&fuzz_err, jwt);

	if(fuzz_err != NULL){
		printf("An error occurred: %s", fuzz_err);
	}else{
		/* Print out each JWT for example */
		char* jwt = NULL;
		int i;
		for(i=0, jwt=jwts[i]; jwt != NULL; i++, jwt=jwts[i]){
		 printf("%s\n", jwt);
		}
	}
	jwtfuzz_free(fuzz_err, jwts);
}
