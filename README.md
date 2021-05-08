# Observed test case failures 1700 / 1701 / 1702 (h2c upgrade)

The issue has been reported at: https://github.com/curl/curl/issues/7036

## Overview

I have earlier observed failures of test cases 1700, 1701, and 1702 on my local machine at 1763aceb0, which was earlier mentioned in #7032.

These three cases are all for HTTP/2 on plaintext TCP with the `Upgrade: h2c` haeder. The only difference is the request method, which is `GET`, `POST`, and `HEAD`, respectively. Those three failures look almost identical, thus I may talk about only case 1700 for convenience.

## Environment and issue reproduction

The failures may be reproduced stably at 51c0ebcff and other recent revisions on my local machine, and in a Docker environment constructed purposely for reproducing this issue. Details on the Docker environment would be given below.

<details>
<summary>
Click here for content of the <code>Dockerfile</code>, which may be used to build a Docker image using commands like <code>docker build -t $IMAGE_NAME - < Dockerfile</code>.
</summary>

```
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
```
</details>

<details>
<summary>
Click here for some debugging information from the <code>configure</code> output during the build.
</summary>

```
configure: Configured to build curl/libcurl:

  Host setup:       x86_64-pc-linux-gnu
  Install prefix:   /usr/local
  Compiler:         gcc
   CFLAGS:          -Werror-implicit-function-declaration -O2 -pedantic -Wall -W -Wpointer-arith -Wwrite-strings -Wunused -Wshadow -Winline -Wnested-externs -Wmissing-declarations -Wmissing-prototypes -Wno-long-long -Wbad-function-cast -Wfloat-equal -Wno-multichar -Wsign-compare -Wundef -Wno-format-nonliteral -Wendif-labels -Wstrict-prototypes -Wdeclaration-after-statement -Wold-style-definition -Wstrict-aliasing=3 -Wcast-align -Wtype-limits -Wold-style-declaration -Wmissing-parameter-type -Wempty-body -Wclobbered -Wignored-qualifiers -Wconversion -Wno-sign-conversion -Wvla -ftree-vrp -Wdouble-promotion -Wformat=2 -Warray-bounds=2 -Wshift-negative-value -Wshift-overflow=2 -Wnull-dereference -fdelete-null-pointer-checks -Wduplicated-cond -Wunused-const-variable -Wduplicated-branches -Wrestrict -Walloc-zero -Wformat-overflow=2 -Wformat-truncation=2 -Wimplicit-fallthrough=4 -Wno-system-headers -pthread
   CPPFLAGS:        
   LDFLAGS:         
   LIBS:            -lnghttp2 -lidn2 -lgsasl -lssl -lcrypto -lssl -lcrypto

  curl version:     7.77.0-DEV
  SSL:              enabled (OpenSSL)
  SSH:              no      (--with-{libssh,libssh2})
  zlib:             no      (--with-zlib)
  brotli:           no      (--with-brotli)
  zstd:             no      (--with-zstd)
  GSS-API:          no      (--with-gssapi)
  GSASL:            enabled
  TLS-SRP:          enabled
  resolver:         POSIX threaded
  IPv6:             enabled
  Unix sockets:     enabled
  IDN:              enabled (libidn2)
  Build libcurl:    Shared=yes, Static=yes
  Built-in manual:  no      (--enable-manual)
  --libcurl option: enabled (--disable-libcurl-option)
  Verbose errors:   enabled (--disable-verbose)
  Code coverage:    disabled
  SSPI:             no      (--enable-sspi)
  ca cert bundle:   /etc/ssl/certs/ca-certificates.crt
  ca cert path:     no
  ca fallback:      no
  LDAP:             no      (--enable-ldap / --with-ldap-lib / --with-lber-lib)
  LDAPS:            no      (--enable-ldaps)
  RTSP:             enabled
  RTMP:             no      (--with-librtmp)
  Metalink:         no      (--with-libmetalink)
  PSL:              no      (libpsl not found)
  Alt-svc:          enabled (--disable-alt-svc)
  HSTS:             enabled (--disable-hsts)
  HTTP1:            enabled (internal)
  HTTP2:            enabled (nghttp2)
  HTTP3:            no      (--with-ngtcp2, --with-quiche)
  ECH:              no      (--enable-ech)
  Protocols:        DICT FILE FTP FTPS GOPHER GOPHERS HTTP HTTPS IMAP IMAPS MQTT POP3 POP3S RTSP SMB SMBS SMTP SMTPS TELNET TFTP
  Features:         AsynchDNS GSASL HSTS HTTP2 HTTPS-proxy IDN IPv6 Largefile NTLM NTLM_WB SSL TLS-SRP UnixSockets alt-svc
```
</details>


<details>
<summary>
Click here for the full test results for case 1700, which is generated from <code>srcdir=. /usr/bin/perl -I. ./runtests.pl -a -p -r 1700</code> as part of <code>TFLAGS=1700 make test-full</code>.
</summary>

```
srcdir=. /usr/bin/perl -I. ./runtests.pl -a -p -r 1700
********* System characteristics ******** 
* curl 7.77.0-DEV (x86_64-pc-linux-gnu) 
* libcurl/7.77.0-DEV OpenSSL/1.1.1f libidn2/2.2.0 nghttp2/1.40.0 libgsasl/1.8.1
* Features: alt-svc AsynchDNS gsasl HSTS HTTP2 HTTPS-proxy IDN IPv6 Largefile NTLM NTLM_WB SSL TLS-SRP UnixSockets
* Disabled: 
* Host: 1a100808e8f5
* System: Linux 1a100808e8f5 5.11.14-arch1-1 #1 SMP PREEMPT Wed, 14 Apr 2021 12:06:34 +0000 x86_64 x86_64 x86_64 GNU/Linux
* OS: linux
* Servers: SSL HTTP-IPv6 HTTP-unix FTP-IPv6 
* Env: Valgrind 
* Seed: 224325
***************************************** 
test 1700...[HTTP/2 GET with Upgrade:]

 1700: stdout FAILED:
--- log/check-expected	2021-05-08 12:14:20.726283240 +0000
+++ log/check-generated	2021-05-08 12:14:20.726283240 +0000
@@ -4,17 +4,6 @@
 [CR][LF]
 HTTP/2 200 [CR][LF]
 date: Tue, 09 Nov 2010 14:49:00 GMT[CR][LF]
-last-modified: Tue, 13 Jun 2000 12:10:00 GMT[CR][LF]
-etag: "21025-dc7-39462498"[CR][LF]
-accept-ranges: bytes[CR][LF]
-content-length: 6[CR][LF]
-content-type: text/html[CR][LF]
-funny-head: yesyes[CR][LF]
-via: 1.1 nghttpx[CR][LF]
-[CR][LF]
--foo-[LF]
-HTTP/2 200 [CR][LF]
-date: Tue, 09 Nov 2010 14:49:00 GMT[CR][LF]
 content-length: 6[CR][LF]
 content-type: text/html[CR][LF]
 via: 1.1 nghttpx[CR][LF]
== Contents of files in the log/ dir after test 1700
=== Start of file check-expected
 HTTP/1.1 101 Switching Protocols[CR][LF]
 Connection: Upgrade[CR][LF]
 Upgrade: h2c[CR][LF]
 [CR][LF]
 HTTP/2 200 [CR][LF]
 date: Tue, 09 Nov 2010 14:49:00 GMT[CR][LF]
 last-modified: Tue, 13 Jun 2000 12:10:00 GMT[CR][LF]
 etag: "21025-dc7-39462498"[CR][LF]
 accept-ranges: bytes[CR][LF]
 content-length: 6[CR][LF]
 content-type: text/html[CR][LF]
 funny-head: yesyes[CR][LF]
 via: 1.1 nghttpx[CR][LF]
 [CR][LF]
 -foo-[LF]
 HTTP/2 200 [CR][LF]
 date: Tue, 09 Nov 2010 14:49:00 GMT[CR][LF]
 content-length: 6[CR][LF]
 content-type: text/html[CR][LF]
 via: 1.1 nghttpx[CR][LF]
 [CR][LF]
 -maa-[LF]
=== End of file check-expected
=== Start of file check-generated
 HTTP/1.1 101 Switching Protocols[CR][LF]
 Connection: Upgrade[CR][LF]
 Upgrade: h2c[CR][LF]
 [CR][LF]
 HTTP/2 200 [CR][LF]
 date: Tue, 09 Nov 2010 14:49:00 GMT[CR][LF]
 content-length: 6[CR][LF]
 content-type: text/html[CR][LF]
 via: 1.1 nghttpx[CR][LF]
 [CR][LF]
 -maa-[LF]
=== End of file check-generated
=== Start of file commands.log
 ../libtool --mode=execute /usr/bin/valgrind --tool=memcheck --quiet --leak-check=yes --suppressions=./valgrind.supp --num-callers=16 --log-file=log/valgrind1700 ../src/curl --include --trace-ascii log/trace1700 --trace-time http://127.0.0.1:23921/1700 --http2 http://127.0.0.1:23921/17000001 >log/stdout1700 2>log/stderr1700
=== End of file commands.log
=== Start of file ftpserver.cmd
 Testnum 1700
=== End of file ftpserver.cmd
=== Start of file http_server.log
 12:14:17.419643 Running HTTP IPv4 version on port 44555
 12:14:17.419955 Wrote pid 15688 to .http_server.pid
 12:14:17.419988 Wrote port 44555 to .http_server.port
 12:14:18.418725 ====> Client connect
 12:14:18.418746 accept_connection 3 returned 4
 12:14:18.418758 accept_connection 3 returned 0
 12:14:18.418770 Read 97 bytes
 12:14:18.418777 Process 97 bytes request
 12:14:18.418790 Got request: GET /verifiedserver HTTP/1.1
 12:14:18.418798 Are-we-friendly question received
 12:14:18.418817 Wrote request (97 bytes) input to log/server.input
 12:14:18.418836 Identifying ourselves as friends
 12:14:18.418886 Response sent (56 bytes) and written to log/server.response
 12:14:18.418897 special request received, no persistency
 12:14:18.418904 ====> Client disconnect 0
 12:14:20.586799 ====> Client connect
 12:14:20.586829 accept_connection 3 returned 4
 12:14:20.586847 accept_connection 3 returned 0
 12:14:20.586966 Read 130 bytes
 12:14:20.587004 Process 130 bytes request
 12:14:20.587047 Got request: GET /1700 HTTP/1.1
 12:14:20.587058 Requested test number 1700 part 0
 12:14:20.587103 - request found to be complete (1700)
 12:14:20.587151 Wrote request (130 bytes) input to log/server.input
 12:14:20.587177 Send response test1700 section <data>
 12:14:20.587328 Response sent (256 bytes) and written to log/server.response
 12:14:20.587342 => persistent connection request ended, awaits new request
 12:14:20.587437 Connection closed by client
 12:14:20.587453 ====> Client disconnect 0
 12:14:20.753007 ====> Client connect
 12:14:20.753054 accept_connection 3 returned 4
 12:14:20.753071 accept_connection 3 returned 0
 12:14:20.753088 Read 132 bytes
 12:14:20.753099 Process 132 bytes request
 12:14:20.753114 Got request: GET /17000001 HTTP/1.1
 12:14:20.753125 Requested test number 1700 part 1
 12:14:20.753160 - request found to be complete (1700)
 12:14:20.753195 Wrote request (132 bytes) input to log/server.input
 12:14:20.753211 Send response test1700 section <data1>
 12:14:20.753356 Response sent (119 bytes) and written to log/server.response
 12:14:20.753371 => persistent connection request ended, awaits new request
 12:14:20.753434 Connection closed by client
 12:14:20.753447 ====> Client disconnect 0
=== End of file http_server.log
=== Start of file http_verify.log
 *   Trying 127.0.0.1:44555...
 * Connected to 127.0.0.1 (127.0.0.1) port 44555 (#0)
 > GET /verifiedserver HTTP/1.1
 > Host: 127.0.0.1:44555
 > User-Agent: curl/7.77.0-DEV
 > Accept: */*
 > 
 * Mark bundle as not supporting multiuse
 < HTTP/1.1 200 OK
 < Content-Length: 17
 < 
 { [17 bytes data]
 * Connection #0 to host 127.0.0.1 left intact
=== End of file http_verify.log
=== Start of file http_verify.out
 WE ROOLZ: 15688
=== End of file http_verify.out
=== Start of file server.input
 GET /1700 HTTP/1.1
 Host: 127.0.0.1:23921
 User-Agent: curl/7.77.0-DEV
 Accept: */*
 X-Forwarded-Proto: http
 Via: 1.1 nghttpx
 GET /17000001 HTTP/1.1
 Host: 127.0.0.1:23921
 User-Agent: curl/7.77.0-DEV
 Accept: */*
 X-Forwarded-Proto: http
 Via: 2 nghttpx
=== End of file server.input
=== Start of file server.response
 HTTP/1.1 200 OK
 Content-Length: 17
 WE ROOLZ: 15688
 HTTP/1.1 200 OK
 Date: Tue, 09 Nov 2010 14:49:00 GMT
 Server: test-server/fake
 Last-Modified: Tue, 13 Jun 2000 12:10:00 GMT
 ETag: "21025-dc7-39462498"
 Accept-Ranges: bytes
 Content-Length: 6
 Connection: close
 Content-Type: text/html
 Funny-head: yesyes
 -foo-
 HTTP/1.1 200 OK
 Date: Tue, 09 Nov 2010 14:49:00 GMT
 Content-Length: 6
 Connection: close
 Content-Type: text/html
 -maa-
=== End of file server.response
=== Start of file stderr1700
   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                  Dload  Upload   Total   Spent    Left  Speed
 
   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
 curl: (52) Empty reply from server
   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                  Dload  Upload   Total   Spent    Left  Speed
 
   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
 100     6  100     6    0     0    123      0 --:--:-- --:--:-- --:--:--   162
=== End of file stderr1700
=== Start of file stdout1700
 HTTP/1.1 101 Switching Protocols
 Connection: Upgrade
 Upgrade: h2c
 HTTP/2 200 
 date: Tue, 09 Nov 2010 14:49:00 GMT
 content-length: 6
 content-type: text/html
 server: nghttpx
 via: 1.1 nghttpx
 -maa-
=== End of file stdout1700
=== Start of file trace1700
 12:14:20.525480 == Info:   Trying 127.0.0.1:23921...
 12:14:20.567961 == Info: Connected to 127.0.0.1 (127.0.0.1) port 23921 (#0)
 12:14:20.586830 => Send header, 180 bytes (0xb4)
 0000: GET /1700 HTTP/1.1
 0014: Host: 127.0.0.1:23921
 002b: User-Agent: curl/7.77.0-DEV
 0048: Accept: */*
 0055: Connection: Upgrade, HTTP2-Settings
 007a: Upgrade: h2c
 0088: HTTP2-Settings: AAMAAABkAAQCAAAAAAIAAAAA
 00b2: 
 12:14:20.602866 == Info: Mark bundle as not supporting multiuse
 12:14:20.606111 <= Recv header, 34 bytes (0x22)
 0000: HTTP/1.1 101 Switching Protocols
 12:14:20.611170 <= Recv header, 21 bytes (0x15)
 0000: Connection: Upgrade
 12:14:20.611825 <= Recv header, 14 bytes (0xe)
 0000: Upgrade: h2c
 12:14:20.612256 == Info: Received 101
 12:14:20.622847 == Info: Using HTTP2, server supports multi-use
 12:14:20.623214 == Info: Connection state changed (HTTP/2 confirmed)
 12:14:20.633714 == Info: Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=172
 12:14:20.699200 == Info: Empty reply from server
 12:14:20.704770 == Info: Connection #0 to host 127.0.0.1 left intact
 12:14:20.722167 == Info: Found bundle for host 127.0.0.1: 0x52b17b0 [can multiplex]
 12:14:20.728961 == Info: Re-using existing connection! (#0) with host 127.0.0.1
 12:14:20.730109 == Info: Connected to 127.0.0.1 (127.0.0.1) port 23921 (#0)
 12:14:20.740895 == Info: Using Stream ID: 3 (easy handle 0x52c86c0)
 12:14:20.755243 => Send header, 89 bytes (0x59)
 0000: GET /17000001 HTTP/2
 0016: Host: 127.0.0.1:23921
 002d: user-agent: curl/7.77.0-DEV
 004a: accept: */*
 0057: 
 12:14:20.760030 <= Recv header, 13 bytes (0xd)
 0000: HTTP/2 200 
 12:14:20.760548 <= Recv header, 37 bytes (0x25)
 0000: date: Tue, 09 Nov 2010 14:49:00 GMT
 12:14:20.761717 <= Recv header, 19 bytes (0x13)
 0000: content-length: 6
 12:14:20.762964 <= Recv header, 25 bytes (0x19)
 0000: content-type: text/html
 12:14:20.763158 <= Recv header, 17 bytes (0x11)
 0000: server: nghttpx
 12:14:20.763299 <= Recv header, 18 bytes (0x12)
 0000: via: 1.1 nghttpx
 12:14:20.764487 <= Recv header, 2 bytes (0x2)
 0000: 
 12:14:20.765634 <= Recv data, 6 bytes (0x6)
 0000: -maa-.
 12:14:20.769602 == Info: Connection #0 to host 127.0.0.1 left intact
=== End of file trace1700

Test suite total running time breakdown per task...

Spent 0002.021 seconds starting and verifying test harness servers.
Spent 0000.004 seconds reading definitions and doing test preparations.
Spent 0001.407 seconds actually running test tools.
Spent 0000.000 seconds awaiting server logs lock removal.
Spent 0000.001 seconds verifying test results.
Spent 0003.432 seconds doing all of the above.

Test server starting and verification time per test (top 25)...

-time-  test
------  ----
02.021  1700

Test definition reading and preparation time per test (top 10)...

-time-  test
------  ----
00.004  1700

Test tool execution time per test (top 25)...

-time-  test
------  ----
01.407  1700

Test server logs lock removal time per test (top 15)...

-time-  test
------  ----
00.000  1700

Test results verification time per test (top 10)...

-time-  test
------  ----
00.001  1700

Total time per test (top 50)...

-time-  test
------  ----
03.432  1700

TESTDONE: 1 tests were considered during 3 seconds.
TESTDONE: 0 tests out of 1 reported OK: 0%

TESTFAIL: These test cases failed: 1700
```
</details>

The raw testing logs for case 1700 (as from the `./tests/log/` directory) have been pulled from the built image (using `docker cp $(docker create $IMAGE_NAME):/curl/tests/log .`) and uploaded to a temporary git repository for further inspection in case that's needed: https://github.com/starrify/curl-test-failure-1700

The temporary git repository also contains all three pieces of raw texts shared above.

## Observations from online CI runs

However I'm yet unable to observe the exact failure on these three cases (1700 / 1701 / 1702) from recent online CI runs, although they often fail due to other reasons.

In all recent CI runs that I randomly picked and manually checked, the outcome of test case 1700 is observed to belong to two categories:
1. Where the test case finishes successfully. ([example 1](https://cirrus-ci.com/task/5739104223625216?logs=test#L3276), [example 2](https://github.com/curl/curl/runs/2533722840#step:7:3841))
2. Where the test case is skipped at all. ([example 1](https://dev.azure.com/daniel0244/curl/_build/results?buildId=5700&view=logs&j=0ac86f4c-a876-5e3d-a660-b619f41e4cf7&t=6eb60c57-d761-5380-d590-c7206b742dc5&l=3996), [example 2](https://dev.azure.com/daniel0244/curl/_build/results?buildId=5700&view=logs&j=12a14018-4e59-5dd3-ca9a-d2d325ad33ab&t=4b14a681-0fc4-5dca-d223-60dd75a83922&l=2612))

## Further steps

Further triage may be needed for locating the exact cause of issue (curl code / test case / upstream tools like nghttp2 / etc.)

I would like to spend some more time on further understanding the reasons behind the failure. However given my lack of familiarity with this project, that might take some time.

Therefore I'm filing this issue in advance, so that the community may be aware of the failures (or maybe someone may come and tell me that the issue was merely caused by some silly mistake of mine 😅).