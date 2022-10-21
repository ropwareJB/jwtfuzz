package main

//  -I ${PATH_STACK}/c \
//  -I ${PATH_GHC_INCLUDES} \
//  -I ${BIN_PATH_ABS}/build \
//  -L${BIN_PATH_ABS}/build/jwtfuzz \
//  -L${BIN_PATH_ABS}/build \
//  -ljwtfuzz \
//  -lHSjwtfuzz \
//  -Wl,-rpath,'$$ORIGIN' \

// TODO: Install dylibs to /usr/lib/libjwtfuzz.dylib'
// TODO: Install 

// TMP run:
// DYLD_LIBRARY_PATH="/Users/brownj17/dev/jwtfuzz/src/.stack-work/dist/x86_64-osx/Cabal-3.4.1.0/build:/Users/brownj17/dev/jwtfuzz/src/.stack-work/dist/x86_64-osx/Cabal-3.4.1.0/build/jwtfuzz" ./main

/*
#cgo CFLAGS: -g -Wall
#cgo CFLAGS: -I /Users/brownj17/dev/jwtfuzz/src/c
#cgo LDFLAGS: -L/Users/brownj17/dev/jwtfuzz/src/.stack-work/dist/x86_64-osx/Cabal-3.4.1.0/build
#cgo LDFLAGS: -L/Users/brownj17/dev/jwtfuzz/src/.stack-work/dist/x86_64-osx/Cabal-3.4.1.0/build/jwtfuzz
#cgo LDFLAGS: -ljwtfuzz
#cgo LDFLAGS: -lHSjwtfuzz

#include <stdlib.h>
#include <stdio.h>
#include <jwtfuzz/src/c/jwtfuzz.h>

char** fuzzer(char** fuzz_err, char* jwt){
  char** jwts = fuzzjwt_fuzz(fuzz_err, jwt);

  if(*fuzz_err == NULL){
    // char* jwt = NULL;
    // int i;
    // for(i=0, jwt=jwts[i]; jwt != NULL; i++, jwt=jwts[i]){
    //   printf("%s\n", jwt);
    // }
  }
  return jwts;
}
void wrapjwtfuzz_free(char* fuzz_err, char** jwts){
  jwtfuzz_free(fuzz_err, jwts);
}
int jwtsLength(char** jwts){
  int i=0;
  for(;jwts[i] != NULL;i++) continue;
  return i;
}
*/
import "C"
import (
  "fmt"
  "unsafe"
)

func fuzzJwt(jwt string) ([]string, *string) {

  var cErr *C.char = nil;
  var cJwt *C.char = C.CString(jwt);
  var jwts **C.char  = C.fuzzer((**C.char)(unsafe.Pointer(&cErr)), cJwt);
  defer func(){
    C.wrapjwtfuzz_free(cErr, jwts);
    C.free(unsafe.Pointer(cJwt));
  }()

  var length = int(C.jwtsLength(jwts));
  goJwtsSlice := unsafe.Slice(jwts, length);

  if(cErr != nil){
    var goErr string = C.GoString(cErr);
    return nil, &goErr
  }

  var goJwts []string = make([]string, length);
  for i := 0; i < len(goJwts); i++ {
    goJwts[i] = C.GoString(goJwtsSlice[i]);
  }
  
  return goJwts, nil
}

func main() {
  C.jwtfuzz_init();

  var jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";

  goJwts, err := fuzzJwt(jwt);
  if err != nil {
    fmt.Printf("Error! %s\n", err);
  }else{
    for i := 0; i < len(goJwts); i++ {
      fmt.Printf("Extracted JWT %s\n", goJwts[i]);
    }
  }

  C.jwtfuzz_end();
}
