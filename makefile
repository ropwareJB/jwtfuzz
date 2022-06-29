
HS_LIBDIR = $(shell cd src && stack ghc -- --print-libdir)
BIN_PATH = $(shell cd src && stack path --dist-dir --allow-different-user)
BIN := jwtfuzz
BUILD_CONTAINER := ${BIN}-gcp-builder

bin: FORCE
	cd src && stack build --allow-different-user
	make copy

watch: FORCE
	cd src && stack build --allow-different-user --file-watch --exec "make -C ./.. copy"

copy: FORCE
	cp src/${BIN_PATH}/build/${BIN}/${BIN} bin/;

so: FORCE
	# Compile test program that links with jwtfuzz lib
	gcc -o test main.c -L. -ljwtfuzz -I ../ -I /home/jb/.stack/programs/x86_64-linux/ghc-tinfo6-9.0.2/lib/ghc-9.0.2/include -Wl,-rpath,'$ORIGIN'
	cd so && gcc -c -fPIC entry.c -I "${HS_LIBDIR}/include"
	# gcc -shared -o libfuzz.so entry.c ../src/libjwtfuzz.so -fPIC -I "$(cd ../src && stack ghc -- --print-libdir)/include"
	# gcc -o test main.c -L. -ljwtfuzz -lHSrts-ghc9.0.2 -L/usr/lib/ghc-9.0.2/base-4.15.1.0/ -lHSbase-4.15.1.0-ghc9.0.2 -L/usr/lib/ghc-9.0.2/rts/   -lHSbase-compat-0.12.0-At5rtEWccPdHHWueoNKXDb-ghc9.0.2 -L/usr/lib/ghc-9.0.2/template-haskell-2.17.0.0/ -lHStemplate-haskell-2.17.0.0-ghc9.0.2 -L/usr/lib/ghc-9.0.2/pretty-1.1.3.6/ -lHSpretty-1.1.3.6-ghc9.0.2 -Wl,-rpath,'$ORIGIN' -L/usr/lib/ghc-9.0.2/ghc-prim-0.7.0/ -lHSghc-prim-0.7.0-ghc9.0.2 -L /usr/lib/ghc-9.0.2/ghc-bignum-1.1/ -lHSghc-bignum-1.1-ghc9.0.2 -L/usr/lib/ghc-9.0.2/containers-0.6.4.1/ -lHScontainers-0.6.4.1-ghc9.0.2 -L/usr/lib/ghc-9.0.2/process-1.6.13.2/ -lHSprocess-1.6.13.2-ghc9.0.2 -L/usr/lib/ghc-9.0.2/transformers-0.5.6.2/ -lHStransformers-0.5.6.2-ghc9.0.2 -L/usr/lib/ghc-9.0.2/unix-2.7.2.2/ -lHSunix-2.7.2.2-ghc9.0.2 -L/usr/lib/ghc-9.0.2/bytestring-0.10.12.1/ -lHSbytestring-0.10.12.1-ghc9.0.2 -L/usr/lib/ghc-9.0.2/ghc-boot-9.0.2/ -lHSghc-boot-9.0.2-ghc9.0.2 -L/usr/lib/ghc-9.0.2/binary-0.8.8.0/ -lHSbinary-0.8.8.0-ghc9.0.2 -L/usr/lib/ghc-9.0.2/ghc-boot-th-9.0.2/ -lHSghc-boot-th-9.0.2-ghc9.0.2 -L/usr/lib/ghc-9.0.2/filepath-1.4.2.1/ -lHSfilepath-1.4.2.1-ghc9.0.2 -L/usr/lib/ghc-9.0.2/array-0.5.4.0/ -lHSarray-0.5.4.0-ghc9.0.2 -L/usr/lib/ghc-9.0.2/directory-1.3.6.2/ -lHSdirectory-1.3.6.2-ghc9.0.2 -L/usr/lib/ghc-9.0.2/time-1.9.3/ -lHStime-1.9.3-ghc9.0.2 -L/usr/lib/ghc-9.0.2/deepseq-1.4.5.0/ -lHSdeepseq-1.4.5.0-ghc9.0.2 -L ../../src/.stack-work/dist/x86_64-linux/Cabal-3.4.1.0/build/ -lHSjwtfuzz-0.1.0.0-3o9dCXmrGjKIY01cM8yVHN-ghc9.0.2 -lHSaeson-1.5.6.0-H6kLokBQSerXHqNAeEUXq-ghc9.0.2 -L/usr/lib/ghc-9.0.2/text-1.2.5.0/ -lHStext-1.2.5.0-ghc9.0.2 -lHSaeson-compat-0.3.10-GrJFrYjSOIT56Vnhdh66y1-ghc9.0.2 -lHSaeson-pretty-0.8.9-5BFzibrQzonLolWmE08lmr-ghc9.0.2


docker-build-container:
	sudo docker build -t ${BUILD_CONTAINER} -f docker/Dockerfile-build .

docker-build: docker-build-container
	sudo docker run -it -v $$(pwd):/app ${BUILD_CONTAINER} bash -c 'cd /app/; make bin'

docker-build-watch: docker-build-container
	sudo docker run -it -v $$(pwd):/app ${BUILD_CONTAINER} bash -c 'cd /app/; make watch'

clean:
	rm bin/*

.PHONY: clean

FORCE: ;
