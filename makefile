
BIN_PATH := $(shell cd src && stack path --dist-dir --allow-different-user)
BIN := jwtfuzz
BUILD_CONTAINER := ${BIN}-gcp-builder

bin: FORCE
	cd src && stack build --allow-different-user
	make copy

watch: FORCE
	cd src && stack build --allow-different-user --file-watch --exec "make -C ./.. copy"

copy: FORCE
	cp src/${BIN_PATH}/build/${BIN}/${BIN} bin/;

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
