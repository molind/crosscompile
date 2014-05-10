XCODE_DEVELOPER = $(shell xcode-select --print-path)
IOS_PLATFORM ?= iPhoneOS

# Pick latest SDK in the directory
IOS_PLATFORM_DEVELOPER = ${XCODE_DEVELOPER}/Platforms/${IOS_PLATFORM}.platform/Developer
IOS_SDK = ${IOS_PLATFORM_DEVELOPER}/SDKs/$(shell ls ${IOS_PLATFORM_DEVELOPER}/SDKs | sort -r | head -n1)

all: build_arches
	mkdir -p lib

	# Make fat libraries for all architectures
	for file in build/armv7/lib/*.a; \
		do name=`basename $$file .a`; \
		${IOS_PLATFORM_DEVELOPER}/usr/bin/lipo -create \
			-arch armv7 build/armv7/lib/$$name.a \
			-arch armv7s build/armv7s/lib/$$name.a \
			-arch arm64 build/arm64/lib/$$name.a \
			-arch i386 build/i386/lib/$$name.a \
			-arch x86_64 build/x86_64/lib/$$name.a \
			-output lib/$$name.a \
		; \
		done;
	echo "Making fat libs"

# Build separate architectures
build_arches:
	${MAKE} arch ARCH=armv7 IOS_PLATFORM=iPhoneOS
	${MAKE} arch ARCH=armv7s IOS_PLATFORM=iPhoneOS
	${MAKE} arch ARCH=arm64 IOS_PLATFORM=iPhoneOS
	${MAKE} arch ARCH=i386 IOS_PLATFORM=iPhoneSimulator
	${MAKE} arch ARCH=x86_64 IOS_PLATFORM=iPhoneSimulator

PREFIX = ${CURDIR}/build/${ARCH}
LIBDIR = ${PREFIX}/lib
INCLUDEDIR = ${PREFIX}/include

CXX = ${XCODE_DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++
CC = ${XCODE_DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
CFLAGS = -isysroot ${IOS_SDK} -I${IOS_SDK}/usr/include -arch ${ARCH} -miphoneos-version-min=5.0
CXXFLAGS = -stdlib=libc++ -isysroot ${IOS_SDK} -I${IOS_SDK}/usr/include -arch ${ARCH}  -miphoneos-version-min=5.0
LDFLAGS = -stdlib=libc++ -isysroot ${IOS_SDK} -L${LIBDIR} -L${IOS_SDK}/usr/lib -arch ${ARCH} -miphoneos-version-min=5.0
LIBTOOLFLAGS = -arch_only ${ARCH}

arch: ${LIBDIR}/libsqlite3.a ${LIBDIR}/libprotobuf.a

${LIBDIR}/libsqlite3.a: ${CURDIR}/sqlite3
	cd sqlite3 && env CXX=${CXX} CC=${CC} CFLAGS="${CFLAGS}" \
	CXXFLAGS="${CXXFLAGS} -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_FTS4 -DSQLITE_ENABLE_FTS4_UNICODE61" \
	LDFLAGS="${LDFLAGS}" ./configure --host=arm-apple-darwin --disable-shared --prefix=${PREFIX} && ${MAKE} clean install

${LIBDIR}/libprotobuf.a: ${CURDIR}/protobuf
	cd protobuf && env CXX=${CXX} CC=${CC} CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
	./configure --host=arm-apple-darwin --disable-shared --with-protoc=/usr/local/bin/protoc --prefix=${PREFIX} && ${MAKE} clean install

${CURDIR}/sqlite3:
	curl https://www.sqlite.org/2014/sqlite-autoconf-3080403.tar.gz > sqlite3.tar.gz
	tar xzvf sqlite3.tar.gz
	rm sqlite3.tar.gz
	mv sqlite-autoconf-3080403 sqlite3
	touch sqlite3

${CURDIR}/protobuf:
	curl https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz > protobuf.tar.gz
	tar xzvf protobuf.tar.gz
	rm protobuf.tar.gz
	mv protobuf-2.5.0 protobuf
# add arm64 support https://code.google.com/p/protobuf/issues/detail?id=575
	patch -p0 <protobuf_arm64.patch
	touch protobuf

clean:
	rm -rf build lib sqlite3 protobuf
