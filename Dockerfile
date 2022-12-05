FROM alpine:3.16

ARG ZIG_VERSION

RUN apk update && \
    apk --no-cache add \
        curl \
        make \
        musl-dev \
        libarchive-tools && \
    if echo ${ZIG_VERSION} | grep -q "dev"; then PREFIX=builds; else PREFIX="download/${ZIG_VERSION}"; fi && \
    curl -s \
      https://ziglang.org/${PREFIX}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz |\
      bsdtar -x -f - && \
    mv zig-linux-x86_64-${ZIG_VERSION}/* /usr/local/bin/
