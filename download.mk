CURL_VER = 7.65.1
HARFBUZZ_VER = 2.5.1
ICU_VER = 64.2
ICU_VER_UNDERSCORE = $(subst .,_,${ICU_VER})
ICU_VER_SHORT = $(basename $(ICU_VER))
MSGPACK_VER = 3.2.0
XZ_VER = 20130513
PROTOBUF_VER = 3.6.1
SQLITE3_VER = 3280000
LIBRESSL_VER = 2.9.2
FREETYPE_VER = 2.10.0
BOOST_VER = 1.70.0
BOOST_VER_UNDERSCORE = $(subst .,_,${BOOST_VER})
C-ARES_VER = 1.15.0

CURL_DIR = download/curl-${CURL_VER}
HARFBUZZ_DIR = download/harfbuzz-${HARFBUZZ_VER}
ICU_DIR = download/icu-${ICU_VER}
ICU_HOST_DIR = download/icu_host-${ICU_VER}
MSGPACK_DIR = download/msgpack-${MSGPACK_VER}
XZ_DIR = download/xz-${XZ_VER}
PROTOBUF_DIR = download/protobuf-${PROTOBUF_VER}
SQLITE3_DIR = download/sqlite3-${SQLITE3_VER}
LIBRESSL_DIR = download/libressl-${LIBRESSL_VER}
FREETYPE_DIR = download/freetype-${FREETYPE_VER}
BOOST_DIR = download/boost-${BOOST_VER}
C-ARES_DIR = download/c-ares-${C-ARES_VER}

LIB_DIRS = \
	${CURL_DIR} \
	${HARFBUZZ_DIR} \
	${ICU_DIR} \
	${MSGPACK_DIR} \
	${XZ_DIR} \
	${PROTOBUF_DIR} \
	${SQLITE3_DIR} \
	${LIBRESSL_DIR} \
	${BOOST_DIR} \
	${C-ARES_DIR}

# Download libraries. see http://stackoverflow.com/a/4251368/241482
# download: | ${LIB_DIRS}

# Downloading libs
${SQLITE3_DIR}:
	rm -f download/sqlite3

	wget https://www.sqlite.org/2019/sqlite-autoconf-${SQLITE3_VER}.tar.gz
	tar xzvf sqlite-autoconf-${SQLITE3_VER}.tar.gz
	rm sqlite-autoconf-${SQLITE3_VER}.tar.gz
	mv sqlite-autoconf-${SQLITE3_VER} ${SQLITE3_DIR}
	
download/sqlite3: | ${SQLITE3_DIR}
	echo ${SQLITE3_VER} > download/sqlite3

${PROTOBUF_DIR}:
	rm -f download/protobuf

	wget https://github.com/google/protobuf/releases/download/v${PROTOBUF_VER}/protobuf-cpp-${PROTOBUF_VER}.tar.gz
	tar xzvf protobuf-cpp-${PROTOBUF_VER}.tar.gz
	rm protobuf-cpp-${PROTOBUF_VER}.tar.gz
	mv protobuf-${PROTOBUF_VER} ${PROTOBUF_DIR}
	cd ${PROTOBUF_DIR} && ./autogen.sh

download/protobuf: | ${PROTOBUF_DIR}	
	echo ${PROTOBUF_VER} > download/protobuf

${BOOST_DIR}:
	rm -f download/boost

	wget https://dl.bintray.com/boostorg/release/${BOOST_VER}/source/boost_${BOOST_VER_UNDERSCORE}.tar.bz2
	tar xzvf boost_${BOOST_VER_UNDERSCORE}.tar.bz2
	rm boost_${BOOST_VER_UNDERSCORE}.tar.bz2
	mv boost_${BOOST_VER_UNDERSCORE} ${BOOST_DIR}

	# patch it
	cd ${BOOST_DIR} && patch -p0 < ../../patch/boost.patch

download/boost: | ${BOOST_DIR}	
	echo ${BOOST_VER} > download/boost

${XZ_DIR}:
	rm -f download/xz

	wget http://tukaani.org/xz/xz-embedded-${XZ_VER}.tar.gz
	tar xzvf xz-embedded-${XZ_VER}.tar.gz
	rm xz-embedded-${XZ_VER}.tar.gz
	
	# pre-patch move
	mv xz-embedded-${XZ_VER} xz-embedded
	patch -p0 < patch/xz-embedded.patch
	# post-patch move
	mv xz-embedded ${XZ_DIR}

download/xz: | ${XZ_DIR}
	echo ${XZ_VER} > download/xz

${MSGPACK_DIR}:
	rm -f download/msgpack

	wget https://github.com/msgpack/msgpack-c/releases/download/cpp-${MSGPACK_VER}/msgpack-${MSGPACK_VER}.tar.gz
	tar xzvf msgpack-${MSGPACK_VER}.tar.gz
	rm msgpack-${MSGPACK_VER}.tar.gz

	# pre-patch move
	mv msgpack-${MSGPACK_VER} msgpack
	patch -p0 < patch/msgpack.patch
	# post-patch move
	mv msgpack ${MSGPACK_DIR}

download/msgpack: | ${MSGPACK_DIR}
	echo ${MSGPACK_VER} > download/msgpack

${ICU_DIR}:
	rm -f download/icu

	wget http://download.icu-project.org/files/icu4c/${ICU_VER}/icu4c-${ICU_VER_UNDERSCORE}-src.tgz
	tar xzvf icu4c-${ICU_VER_UNDERSCORE}-src.tgz
	rm icu4c-${ICU_VER_UNDERSCORE}-src.tgz
	mv icu ${ICU_DIR}
	chmod a+x ${ICU_DIR}/source/configure

${ICU_HOST_DIR}/source/bin/icupkg: ${ICU_DIR}
	cp -R ${ICU_DIR} ${ICU_HOST_DIR}
	cd ${ICU_HOST_DIR}/source && \
	./configure --enable-static && \
	${MAKE} clean && \
	${MAKE} -j8 all

${CURDIR}/icudt${ICU_VER_SHORT}l.dat: ${ICU_HOST_DIR}/source/bin/icupkg
	cd ${CURDIR}/${ICU_HOST_DIR}/source/data/out/build/icudt${ICU_VER_SHORT}l && \
	env DYLD_LIBRARY_PATH="${CURDIR}/${ICU_HOST_DIR}/source/lib" ${CURDIR}/${ICU_HOST_DIR}/source/bin/pkgdata --rebuild --mode common --name icudt${ICU_VER_SHORT}l --destdir "${CURDIR}" ${CURDIR}/icudata.lst

download/icu: | ${ICU_DIR} ${ICU_HOST_DIR}/source/bin/icupkg ${CURDIR}/icudt${ICU_VER_SHORT}l.dat
	echo ${ICU_VER} > download/icu

${CURL_DIR}:
	rm -f download/curl

	wget http://curl.haxx.se/download/curl-${CURL_VER}.tar.gz
	tar xzvf curl-${CURL_VER}.tar.gz
	rm curl-${CURL_VER}.tar.gz
	mv curl-${CURL_VER} ${CURL_DIR}

download/curl: | ${CURL_DIR}
	echo ${CURL_VER} > download/curl

${C-ARES_DIR}:
	rm -f download/c-ares

	wget https://c-ares.haxx.se/download/c-ares-${C-ARES_VER}.tar.gz
	tar xzvf c-ares-${C-ARES_VER}.tar.gz
	rm c-ares-${C-ARES_VER}.tar.gz
	mv c-ares-${C-ARES_VER} ${C-ARES_DIR}

download/c-ares: | ${C-ARES_DIR}
	echo ${C-ARES_VER} > download/c-ares

${HARFBUZZ_DIR}:
	rm -f download/harfbuzz

	wget https://github.com/harfbuzz/harfbuzz/releases/download/${HARFBUZZ_VER}/harfbuzz-${HARFBUZZ_VER}.tar.xz
	tar xzvf harfbuzz-${HARFBUZZ_VER}.tar.xz
	rm harfbuzz-${HARFBUZZ_VER}.tar.xz
	mv harfbuzz-${HARFBUZZ_VER} ${HARFBUZZ_DIR}

download/harfbuzz: | ${HARFBUZZ_DIR}
	echo ${HARFBUZZ_VER} > download/harfbuzz

${LIBRESSL_DIR}:
	rm -f download/libressl

	wget https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VER}.tar.gz
	tar xzvf libressl-${LIBRESSL_VER}.tar.gz
	rm libressl-${LIBRESSL_VER}.tar.gz
	mv libressl-${LIBRESSL_VER} ${LIBRESSL_DIR}
	cd ${LIBRESSL_DIR} && patch -p0 < ../../patch/libressl.patch && aclocal && automake && autoconf

download/libressl: | ${LIBRESSL_DIR}
	echo ${LIBRESSL_VER} > download/libressl

${FREETYPE_DIR}:
	rm -f download/freetype

	wget https://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE_VER}.tar.gz
	tar xzvf freetype-${FREETYPE_VER}.tar.gz
	rm freetype-${FREETYPE_VER}.tar.gz
	mv freetype-${FREETYPE_VER} ${FREETYPE_DIR}

download/freetype: | ${FREETYPE_DIR}
	echo ${FREETYPE_VER} > download/freetype
