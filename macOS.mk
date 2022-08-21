NICE_PRINT = "\033[1;32m Building $(1)\033[0m\n"

XCODE_TOOLCHAIN = $(shell xcode-select --print-path)/Toolchains/XcodeDefault.xctoolchain

MACOS_SDK = $(shell xcrun -show-sdk-path)

export PREFIX = ${CURDIR}/build/macOS/${ARCH}
LIBDIR = ${PREFIX}/lib

export CXX = ${XCODE_TOOLCHAIN}/usr/bin/clang++
export CC = ${XCODE_TOOLCHAIN}/usr/bin/clang
CROSSFLAGS = -arch ${ARCH} -isysroot ${MACOS_SDK}
export CFLAGS = ${CROSSFLAGS} -O3 -fvisibility=hidden
export CPPFLAGS = ${CROSSFLAGS} -I${MACOS_SDK}/usr/include -I${PREFIX}/include
export CXXFLAGS = ${CFLAGS} -std=c++14 -stdlib=libc++ -fno-aligned-allocation
export LDFLAGS = ${CROSSFLAGS} -e _main -stdlib=libc++ -L${LIBDIR}
export MACOSX_DEPLOYMENT_TARGET := 10.14

LIBTOOLFLAGS = -arch_only ${ARCH}

# Build separate architectures
all:
	mkdir -p download
	@${MAKE} -f macOS.mk macos_arch ARCH=x86_64

macos_arch: status | ${LIBDIR}/libosmium.a

status:
	@printf $(call NICE_PRINT,$(ARCH)) 1>&2;

include download.mk
include build_libs.mk
