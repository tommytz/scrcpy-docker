### builder
FROM alpine:edge AS builder

ARG SCRCPY_VER=2.6.1
ARG SERVER_HASH="ca7ab50b2e25a0e5af7599c30383e365983fa5b808e65ce2e1c1bba5bfe8dc3b"

RUN apk add --no-cache \
        curl \
        ffmpeg-dev \
        gcc \
        git \
	libusb-dev \
        make \
        meson \
        musl-dev \
        openjdk17 \
        pkgconf \
        sdl2-dev

RUN PATH=$PATH:/usr/lib/jvm/java-17-openjdk/bin
RUN curl -L -o scrcpy-server https://github.com/Genymobile/scrcpy/releases/download/v${SCRCPY_VER}/scrcpy-server-v${SCRCPY_VER}
RUN echo "$SERVER_HASH  /scrcpy-server" | sha256sum -c -
RUN git clone https://github.com/Genymobile/scrcpy.git
RUN cd scrcpy && meson x --buildtype=release --strip -Db_lto=true -Dprebuilt_server=/scrcpy-server
RUN cd scrcpy/x && ninja install

### runner
FROM alpine:edge AS runner

# needed for android-tools
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories

LABEL maintainer="Pierre Gordon <pierregordon@protonmail.com>"

RUN apk add --no-cache \
        android-tools \
        ffmpeg \
        virtualgl

COPY --from=builder /scrcpy-server /usr/local/share/scrcpy/
COPY --from=builder /scrcpy/x/app/scrcpy /usr/local/bin/

### runner (amd)
FROM runner AS amd

RUN apk add --no-cache mesa-dri-gallium

### runner (intel)
FROM runner AS intel

RUN apk add --no-cache mesa-dri-intel

### runner (nvidia)
FROM runner AS nvidia

RUN apk add --no-cache mesa-dri-nouveau
