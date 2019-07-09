# using our makefiles
${LIBDIR}/libmsgpackc.a: download/msgpack
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${MSGPACK_DIR} && \
	${MAKE} clean && \
	${MAKE} -j8 install

${LIBDIR}/libxz.a: download/xz
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${XZ_DIR} && \
	${MAKE} clean && \
	${MAKE} -j8 install

${LIBDIR}/libboost.a: download/boost
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${BOOST_DIR} && \
	${MAKE} clean && \
	${MAKE} -j8 install

# using configure
${LIBDIR}/libprotobuf-lite.a: download/protobuf
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${PROTOBUF_DIR} && \
	env LDFLAGS="${LDFLAGS} ${LDFLAGS_PROTOBUF}" ./configure --host=${HOST} --prefix=${PREFIX} --disable-shared --with-protoc=/usr/local/bin/protoc && \
	${MAKE} clean && \
	${MAKE} -j8 install

${LIBDIR}/libsqlite3.a: download/sqlite3
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${SQLITE3_DIR} && \
	env CXXFLAGS="${CXXFLAGS} -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_FTS4" \
	./configure --host=${HOST} --prefix=${PREFIX} --disable-shared && \
	${MAKE} clean && \
	${MAKE} -j8 install-libLTLIBRARIES install-includeHEADERS # we build only lib because there is no `system(int)` func on iOS

${LIBDIR}/libfreetype.a : download/freetype
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${FREETYPE_DIR} && \
	env PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig" \
	./configure --host=${HOST} --prefix=${PREFIX} --disable-shared --without-png --without-harfbuzz && \
	${MAKE} clean && \
	${MAKE} -j8 install

${LIBDIR}/libicuuc.a: download/icu | ${ICU_HOST_DIR}/source/bin/icupkg
	@printf $(call NICE_PRINT,$@) 1>&2;
	@cd ${ICU_DIR}/source && \
	env CXXFLAGS="${CXXFLAGS} -DUCONFIG_NO_IDNA=1 -DUCONFIG_NO_FORMATTING=1 -DUCONFIG_NO_TRANSLITERATION=1 -DUCONFIG_NO_REGULAR_EXPRESSIONS=1 -I${CURDIR}/${ICU_DIR}/tools/tzcode -DUCHAR_TYPE=uint16_t" \
	./configure --host=${HOST} --prefix=${PREFIX} --with-cross-build=${CURDIR}/${ICU_HOST_DIR}/source --disable-shared --enable-static --with-data-packaging=archive --disable-extras --disable-icuio --disable-layout --disable-tools --disable-tests -disable-samples && \
	${MAKE} clean && \
	${MAKE} -j8 install

${LIBDIR}/libharfbuzz.a: download/harfbuzz ${LIBDIR}/libicuuc.a ${LIBDIR}/libfreetype.a
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${HARFBUZZ_DIR} && \
	env PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig" \
	./configure --host=${HOST} --prefix=${PREFIX} --disable-shared --with-freetype=yes --with-glib=no --with-icu=yes && \
	${MAKE} clean && \
	${MAKE} -j8 install

## Only libs with different settings below
${LIBDIR}/libcares.a: download/c-ares
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${C-ARES_DIR} && \
	./configure --host=${HOST} --prefix=${PREFIX} && \
	${MAKE} clean && \
	${MAKE} -j8 install
	