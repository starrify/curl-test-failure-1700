FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
# list picked from .travis.yml + a few manual additions (before / after)
RUN apt-get update && apt-get install -y \
  git \
  autoconf \
  libtool \
  libssl-dev \
  cmake \
  valgrind \
  libev-dev \
  libc-ares-dev \
  g++ \
  stunnel4 \
  libidn2-dev \
  gnutls-bin \
  python3-impacket \
  ninja-build \
  libgsasl7-dev \
  libnghttp2-dev \
  nghttp2
WORKDIR /curl
ARG REVISION=51c0ebcff2140c38ff389b4fcfb8216f5e9d198c
RUN git init . && git remote add origin https://github.com/curl/curl.git \
  && git fetch origin $REVISION && git checkout $REVISION
RUN ./buildconf && ./configure --with-openssl --enable-warnings --enable-werror && make
ARG TFLAGS=1700
# ignore the command failure so that the outcome may be saved
RUN make test-full || true
