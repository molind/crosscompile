${LIBDIR}/libosmium.a: download/osmium ${LIBDIR}/libexpat.a ${LIBDIR}/libboost.a ${LIBDIR}/libproj.a ${LIBDIR}/libprotozero
	@printf $(call NICE_PRINT,$@) 1>&2;

	cd ${OSMIUM_DIR} && \
	rm -rf build && mkdir build && cd build \
	&& cmake .. && \
	${MAKE} -j install

${LIBDIR}/libexpat.a: download/expat
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${EXPAT_DIR} && \
	./configure --host=${HOST} --prefix=${PREFIX} --disable-shared && \
	${MAKE} clean && \
	${MAKE} -j8 install

${LIBDIR}/libprotozero: download/protozero
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${PROTOZERO_DIR} && \
	rm -rf ${PREFIX}/include/protozero && \
	cp -r include/protozero ${PREFIX}/include/ && \
	touch ${LIBDIR}/libprotozero

${LIBDIR}/libproj.a: download/proj ${LIBDIR}/libtiff.a ${LIBDIR}/libcurl.a
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${PROJ_DIR} && \
	rm -rf build && mkdir build && cd build \
	&& cmake .. ${CMAKE_FLAGS} -DBUILD_TESTING=OFF -DBUILD_APPS=OFF \
		-DCURL_INCLUDE_DIR=${PREFIX}/include -DCURL_LIBRARY=${LIBDIR}/libcurl.a \
		-DTIFF_INCLUDE_DIR=${PREFIX}/include -DTIFF_LIBRARY=${LIBDIR}/libtiff.a && \
	${MAKE} -j install

${LIBDIR}/libtiff.a: download/tiff
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${TIFF_DIR} && \
	rm -rf _build && mkdir _build && cd _build \
	&& cmake .. ${CMAKE_FLAGS} -DBUILD_SHARED_LIBS=OFF && \
	${MAKE} -j install

${LIBDIR}/libboost.a: download/boost
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${BOOST_DIR} && \
	${MAKE} clean && \
	${MAKE} -j8 install

## Only libs with different settings below
${LIBDIR}/libcurl.a: download/curl
	@printf $(call NICE_PRINT,$@) 1>&2;
	cd ${CURL_DIR} && \
	./configure --host=${HOST} --prefix=${PREFIX} --disable-shared --enable-ipv6 --with-darwinssl --enable-threaded-resolver && \
	${MAKE} clean && \
	${MAKE} -j install
