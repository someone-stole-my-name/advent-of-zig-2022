ZIG_VERSION=0.11.0-dev.149+7733246d6
IMAGE_NAME=zigci

all: clean test fmt benchmark

clean:
	$(RM) -rf zig-cache bin README.md

test:
	zig build test

build:
	zig build -p .

benchmark: build
	echo '```' > README.md
	./bin/aoc-2022 2>> README.md
	echo '```' >> README.md

fmt:
	find . -name "*.zig" -exec zig fmt --check {} \;

docker-build:
	docker build \
		-t $(IMAGE_NAME) \
		--build-arg ZIG_VERSION=$(ZIG_VERSION) \
		-f Dockerfile .

docker-%: docker-build
	docker run \
		--rm \
		--privileged \
		-v $(shell pwd):/data \
		-w /data $(DOCKER_EXTRA_ARGS) \
		$(IMAGE_NAME) sh -c "make $*"
