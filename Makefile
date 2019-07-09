all: macos ios android cleanup

include download.mk

macos: prebuild
	@${MAKE} -f macOS.mk

ios: prebuild
	@${MAKE} -f iOS.mk

android: prebuild
	@${MAKE} -f Android.mk

# android_toolchain: 
# 	@${MAKE} -f AndroidToolchain.mk

download:
	mkdir -p download

# install prerequisites
prebuild: download download/icu
#	brew install wget autoconf automake cmake libtool pkgconfig protobuf bjam

clean:
	rm -rf build

clean_all: clean
	rm -rf ${LIB_DIRS}
