NICE_PRINT = "\033[1;32m Building $(1)\033[0m\n"

export PREFIX = ${CURDIR}/build/Android/${ARCH}
TOOLCHAIN = ${NDK_PATH}/toolchains/llvm/prebuilt/darwin-x86_64
LIBDIR = ${PREFIX}/lib
INCLUDEDIR = ${PREFIX}/include

export PATH := ${CURDIR}/build/macOS/x86_64/bin:${TOOLCHAIN}/bin:${PATH}

export AR=${HOST}-ar
export AS=${CLANG_PREFIX}-clang
export CC=${CLANG_PREFIX}-clang
export CXX=${CLANG_PREFIX}-clang++
export LD=${HOST}-ld
export STRIP=${HOST}-strip

export CPPFLAGS = -I${INCLUDEDIR}
export CFLAGS = -fPIC -O3 
export CXXFLAGS = -fPIC -O3 -std=c++17
export LDFLAGS = -L${LIBDIR}

ifeq ($(ARCH),armeabi-v7a)
	CFLAGS += -march=armv7-a -mfloat-abi=softfp
	CXXFLAGS += -march=armv7-a -mfloat-abi=softfp
	LDFLAGS += -march=armv7-a -Wl,--fix-cortex-a8
endif

LDFLAGS_PROTOBUF = -llog

# Build separate architectures
all:
	echo ${PATH}
	mkdir -p download
	@${MAKE} -f Android.mk arch ARCH=armeabi-v7a CLANG_PREFIX=armv7a-linux-androideabi16 HOST=arm-linux-androideabi
	@${MAKE} -f Android.mk arch ARCH=arm64-v8a CLANG_PREFIX=aarch64-linux-android21 HOST=aarch64-linux-android >/dev/null
	@${MAKE} -f Android.mk arch ARCH=x86 CLANG_PREFIX=i686-linux-android16 HOST=i686-linux-android >/dev/null
	@${MAKE} -f Android.mk arch ARCH=x86_64 CLANG_PREFIX=x86_64-linux-android21 HOST=x86_64-linux-android >/dev/null

arch: status | ${LIBDIR}/libboost.a ${LIBDIR}/libssl.a ${LIBDIR}/libcurl.a ${LIBDIR}/libsqlite3.a ${LIBDIR}/libicuuc.a ${LIBDIR}/libmsgpackc.a ${LIBDIR}/libxz.a ${LIBDIR}/libharfbuzz.a ${LIBDIR}/libprotobuf-lite.a

status:
	@printf $(call NICE_PRINT,$(ARCH)) 1>&2;

include download.mk
include build_libs.mk

${LIBDIR}/libssl.a: download/libressl
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${LIBRESSL_DIR} && \
	./configure --host=${HOST} --prefix=${PREFIX} --disable-shared --disable-asm && \
	${MAKE} clean && \
	${MAKE} -j8 install

${LIBDIR}/libcurl.a: download/curl ${LIBDIR}/libssl.a ${LIBDIR}/libcares.a
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${CURL_DIR} && \
	./configure --host=${HOST} --prefix=${PREFIX} --disable-shared --with-ssl --disable-verbose --enable-ares --enable-ipv6 --enable-hidden-symbols --enable-threaded-resolver &&\
	${MAKE} clean && \
	${MAKE} -j8 install