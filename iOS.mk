NICE_PRINT = "\033[1;32m Building $(1)\033[0m\n"

XCODE_TOOLCHAIN = $(shell xcode-select --print-path)/Toolchains/XcodeDefault.xctoolchain
IOS_PLATFORM ?= iphoneos

IOS_SDK = $(shell xcrun -sdk ${IOS_PLATFORM} -show-sdk-path)

export PATH := ${CURDIR}/build/macOS/x86_64/bin:${PATH}

export PREFIX = ${CURDIR}/build/iOS/${ARCH}
LIBDIR = ${PREFIX}/lib

export CXX = ${XCODE_TOOLCHAIN}/usr/bin/clang++
export CC = ${XCODE_TOOLCHAIN}/usr/bin/clang
CROSSFLAGS = -isysroot ${IOS_SDK} -arch ${ARCH} -miphoneos-version-min=8.0
export CFLAGS = ${CROSSFLAGS} -O3 -fembed-bitcode -fvisibility=hidden
export CPPFLAGS = ${CROSSFLAGS} -I${IOS_SDK}/usr/include -I${PREFIX}/include
export CXXFLAGS = ${CFLAGS} -std=c++14 -stdlib=libc++ -fno-aligned-allocation
export LDFLAGS = ${CROSSFLAGS} -e _main -stdlib=libc++ -L${LIBDIR} -L${IOS_SDK}/usr/lib
export CMAKE_FLAGS = -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_MACOSX_BUNDLE=OFF -DCMAKE_OSX_SYSROOT=${IOS_SDK} -DCMAKE_OSX_ARCHITECTURES=${ARCH} -DCMAKE_OSX_DEPLOYMENT_TARGET=8.0 -DCMAKE_SYSTEM_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX}
HOST = arm-apple-darwin
LIBTOOLFLAGS = -arch_only ${ARCH}

# Build separate architectures
all:
	mkdir -p download
	@${MAKE} -f iOS.mk build ARCH=arm64 LIBS_PLATFORM=iphoneos
	@${MAKE} -f iOS.mk build ARCH=armv7 LIBS_PLATFORM=iphoneos >/dev/null
	@${MAKE} -f iOS.mk build ARCH=arm64 LIBS_PLATFORM=iphonesimulator >/dev/null
	@${MAKE} -f iOS.mk build ARCH=x86_64 LIBS_PLATFORM=iphonesimulator >/dev/null
	@${MAKE} -f iOS.mk build ARCH=i386 LIBS_PLATFORM=iphonesimulator >/dev/null

build: status | ${LIBDIR}/libosmium.a

status:
	@printf $(call NICE_PRINT,$(ARCH)) 1>&2;

include download.mk
include build_libs.mk

