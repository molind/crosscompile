OSMIUM_VER = 2.18.0
CURL_VER = 7.65.1
PROTOZERO_VER = 1.7.1
BZIP2_VER = 1.0.8
PROJ_VER = 9.0.1
TIFF_VER = 4.4.0
BOOST_VER = 1.70.0
BOOST_VER_UNDERSCORE = $(subst .,_,${BOOST_VER})
EXPAT_VER = 2.4.8
EXPAT_VER_UNDERSCORE = $(subst .,_,${EXPAT_VER})

OSMIUM_DIR = download/osmium-${OSMIUM_VER}
CURL_DIR = download/curl-${CURL_VER}
BOOST_DIR = download/boost-${BOOST_VER}
EXPAT_DIR = download/expat-${EXPAT_VER}
PROTOZERO_DIR = download/protozero-${PROTOZERO_VER}
BZIP2_DIR = download/bzip2-${BZIP2_VER}
PROJ_DIR = download/proj-${PROJ_VER}
TIFF_DIR = download/tiff-${TIFF_VER}

# Downloading libs

${OSMIUM_DIR}:
	rm -f download/osmium

	wget https://github.com/osmcode/libosmium/archive/refs/tags/v${OSMIUM_VER}.tar.gz
	tar xzvf v${OSMIUM_VER}.tar.gz
	rm v${OSMIUM_VER}.tar.gz
	mv libosmium-${OSMIUM_VER} ${OSMIUM_DIR}

download/osmium: | ${OSMIUM_DIR}
	echo ${OSMIUM_VER} > download/osmium

${CURL_DIR}:
	rm -f download/curl

	wget https://curl.haxx.se/download/curl-${CURL_VER}.tar.gz
	tar xzvf curl-${CURL_VER}.tar.gz
	rm curl-${CURL_VER}.tar.gz
	mv curl-${CURL_VER} ${CURL_DIR}

download/curl: | ${CURL_DIR}
	echo ${CURL_VER} > download/curl

${EXPAT_DIR}:
	rm -f download/expat

	wget https://github.com/libexpat/libexpat/releases/download/R_${EXPAT_VER_UNDERSCORE}/expat-${EXPAT_VER}.tar.gz
	tar xzvf expat-${EXPAT_VER}.tar.gz
	rm expat-${EXPAT_VER}.tar.gz
	mv expat-${EXPAT_VER} ${EXPAT_DIR}

download/expat: | ${EXPAT_DIR}
	echo ${EXPAT_VER} > download/expat

${PROTOZERO_DIR}:
	rm -f download/protozero

	wget https://github.com/mapbox/protozero/archive/refs/tags/v${PROTOZERO_VER}.tar.gz
	tar xzvf v${PROTOZERO_VER}.tar.gz
	rm v${PROTOZERO_VER}.tar.gz
	mv protozero-${PROTOZERO_VER} ${PROTOZERO_DIR}

download/protozero: | ${PROTOZERO_DIR}
	echo ${PROTOZERO_VER} > download/protozero

${PROTOZERO_DIR}:
	rm -f download/protozero

	wget https://github.com/mapbox/protozero/archive/refs/tags/v${PROTOZERO_VER}.tar.gz
	tar xzvf v${PROTOZERO_VER}.tar.gz
	rm v${PROTOZERO_VER}.tar.gz
	mv protozero-${PROTOZERO_VER} ${PROTOZERO_DIR}

download/protozero: | ${PROTOZERO_DIR}
	echo ${PROTOZERO_VER} > download/protozero

${BZIP2_DIR}:
	rm -f download/protozero

	wget https://sourceware.org/pub/bzip2/bzip2-${BZIP2_VER}.tar.gz
	tar xzvf bzip2-${BZIP2_VER}.tar.gz
	rm bzip2-${BZIP2_VER}.tar.gz
	mv bzip2-${BZIP2_VER} ${BZIP2_DIR}

download/bzip2: | ${BZIP2_DIR}
	echo ${BZIP2_VER} > download/bzip2

${PROJ_DIR}:
	rm -f download/proj

	wget https://download.osgeo.org/proj/proj-${PROJ_VER}.tar.gz
	tar xzvf proj-${PROJ_VER}.tar.gz
	rm proj-${PROJ_VER}.tar.gz
	mv proj-${PROJ_VER} ${PROJ_DIR}

download/proj: | ${PROJ_DIR}
	echo ${PROJ_VER} > download/proj

${TIFF_DIR}:
	rm -f download/tiff

	wget https://download.osgeo.org/libtiff/tiff-${TIFF_VER}.tar.gz
	tar xzvf tiff-${TIFF_VER}.tar.gz
	rm tiff-${TIFF_VER}.tar.gz
	mv tiff-${TIFF_VER} ${TIFF_DIR}

download/tiff: | ${TIFF_DIR}
	echo ${TIFF_VER} > download/tiff

${BOOST_DIR}:
	rm -f download/boost

	wget https://boostorg.jfrog.io/artifactory/main/release/${BOOST_VER}/source/boost_${BOOST_VER_UNDERSCORE}.tar.bz2
	tar xzvf boost_${BOOST_VER_UNDERSCORE}.tar.bz2
	rm boost_${BOOST_VER_UNDERSCORE}.tar.bz2
	mv boost_${BOOST_VER_UNDERSCORE} ${BOOST_DIR}

	# patch it
	cd ${BOOST_DIR} && patch -p0 < ../../patch/boost.patch

download/boost: | ${BOOST_DIR}
	echo ${BOOST_VER} > download/boost
