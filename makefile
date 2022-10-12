
HS_LIBDIR := $(shell cd src && stack ghc -- --print-libdir)
PATH_STACK := $(shell cd src && pwd)
BIN_PATH := $(shell cd src && stack path --dist-dir --allow-different-user)
BIN_PATH_ABS := $(shell pwd)/src/${BIN_PATH}
PATH_STACK_PROGRAMS := $(shell cd src && stack path --programs)
BIN := jwtfuzz-exe
BUILD_CONTAINER := ${BIN}-gcp-builder

PATH_LIBHS_JWTFUZZ := ${BIN_PATH_ABS}/build/libHSjwtfuzz.so
PATH_LIB_JWTFUZZ := ${BIN_PATH_ABS}/build/jwtfuzz/libjwtfuzz.so

bin: FORCE
	cd src && \
		stack build \
		--allow-different-user
	make copy

watch: FORCE
	cd src && \
		stack build \
		--allow-different-user \
		--file-watch \
		--exec "make -C ./.. copy"

copy: FORCE
	cp ./src/${BIN_PATH}/build/${BIN}/${BIN} bin/;

so: FORCE
	# Clean env
	rm ${PATH_LIBHS_JWTFUZZ} 2>/dev/null || true

	cd src && \
		stack build --allow-different-user

	# Create a symlink to libHSjwtfuzz
	ln -s ${BIN_PATH_ABS}/build/libHSjwtfuzz-*.so ${PATH_LIBHS_JWTFUZZ}

	# Compile test program that links with jwtfuzz lib
	cd so/test && \
		gcc -o test \
		-I ${PATH_STACK}/c \
		-I ${PATH_STACK_PROGRAMS}/ghc-tinfo6-9.0.2/lib/ghc-9.0.2/include \
		-I ${BIN_PATH_ABS}/build \
		-L${BIN_PATH_ABS}/build/jwtfuzz \
		-L${BIN_PATH_ABS}/build \
		-ljwtfuzz \
		-lHSjwtfuzz \
		-Wl,-rpath,'$$ORIGIN' \
		main.c

	echo "Runing Tests.."
	cd so/test && \
		LD_PRELOAD="\
${PATH_LIB_JWTFUZZ} \
${PATH_LIBHS_JWTFUZZ}" \
		./test

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
