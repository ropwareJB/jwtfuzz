
HS_LIBDIR := $(shell cd src && stack ghc -- --print-libdir)
PATH_STACK := $(shell cd src && pwd)
BIN_PATH := $(shell cd src && stack path --dist-dir --allow-different-user)
BIN_PATH_ABS := $(shell pwd)/src/${BIN_PATH}
PATH_STACK_PROGRAMS := $(shell cd src && stack path --programs)
BIN := jwtfuzz-exe
BUILD_CONTAINER := ${BIN}-gcp-builder

ifeq ($(OS),Windows_NT)
    # CCFLAGS += -D WIN32
		# 2022-10-12: Not currently supported
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        #CCFLAGS += -D LINUX
				PATH_LIBHS_JWTFUZZ := ${BIN_PATH_ABS}/build/libHSjwtfuzz.so
				PATH_LIB_JWTFUZZ := ${BIN_PATH_ABS}/build/jwtfuzz/libjwtfuzz.so
				LIB_PRELOAD := LD_PRELOAD="${PATH_LIB_JWTFUZZ} ${PATH_LIBHS_JWTFUZZ}"
    endif
    ifeq ($(UNAME_S),Darwin)
        #CCFLAGS += -D OSX
				PATH_LIBHS_JWTFUZZ := ${BIN_PATH_ABS}/build/libHSjwtfuzz.dylib
				PATH_LIB_JWTFUZZ := ${BIN_PATH_ABS}/build/jwtfuzz/libjwtfuzz.dylib
				LIB_PRELOAD := DYLD_INSERT_LIBRARIES="${PATH_LIB_JWTFUZZ}:${PATH_LIBHS_JWTFUZZ}"
    endif
endif

PATH_GHC_INCLUDES := ${PATH_STACK_PROGRAMS}/ghc-tinfo6-9.0.2/lib/ghc-9.0.2/include

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
	@if [ $(UNAME_S) = "Linux" ]; then \
		ln -s ${BIN_PATH_ABS}/build/libHSjwtfuzz-*.so ${PATH_LIBHS_JWTFUZZ}; \
	fi
	@if [ $(UNAME_S) = "Darwin" ]; then \
		ln -s ${BIN_PATH_ABS}/build/libHSjwtfuzz-*.dylib ${PATH_LIBHS_JWTFUZZ}; \
	fi

	# Compile test program that links with jwtfuzz lib
	cd so/test && \
		gcc -o test \
		-I ${PATH_STACK}/c \
		-I ${PATH_GHC_INCLUDES} \
		-I ${BIN_PATH_ABS}/build \
		-L${BIN_PATH_ABS}/build/jwtfuzz \
		-L${BIN_PATH_ABS}/build \
		-ljwtfuzz \
		-lHSjwtfuzz \
		-Wl,-rpath,'$$ORIGIN' \
		main.c

	echo "Running Tests.."
	cd so/test && \
		 ${LIB_PRELOAD} ./test

docker-build-container:
	sudo docker build -t ${BUILD_CONTAINER} -f docker/Dockerfile-build .

docker-build: docker-build-container
	sudo docker run -it -v $$(pwd):/app ${BUILD_CONTAINER} bash -c 'cd /app/; make bin'

docker-build-watch: docker-build-container
	sudo docker run -it -v $$(pwd):/app ${BUILD_CONTAINER} bash -c 'cd /app/; make watch'

go:
	cd go && \
		go build

clean:
	rm bin/*

.PHONY: clean

FORCE: ;
