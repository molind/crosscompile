# Crosscompile - Right way to cross-compile libs for iOS and Android

## Features
* Easy to configure
* Easy to update libs
* Easy to rebuild
* Separate prefix path for every arch

Some libs have different configuration variables hardcoded into header files during build time. We use separate prefix paths for every architecture to load correct headers for each architecture.

## Usage
### Build libraries
```
make -j # to build for all platforms
make -j ios # build only iOS versions of libraries
make -j android # build only Android version of libraries

touch downloads/libname && make -j # to rebuild one library and it's dependencies
```

### Change library version
* Change $LIBNAME_VER in download.mk

### Add library
It's easy to add more libraries. 
* Modify download.mk to download you library and define $LIBNAME_VER and $LIBNAME_DIR. 
* Modify build_libs.mk to build your lib.
* Add iOS.mk `ios_arch` target dependencies.
* Add Android.mk `arch` target dependencies.

## Setup

### Xcode
Add following line to your .xcconfig
```
LIBS_PATH = $(SRCROOT)/../../libs/build/iOS/$(arch)

HEADER_SEARCH_PATHS = $(inherited) $(LIBS_PATH)/include
LIBRARY_SEARCH_PATHS = $(inherited) $(LIBS_PATH)/lib

LIBS = -lcurl -lfreetype -lharfbuzz-icu -lharfbuzz -licuuc -licui18n -licudata -lmsgpackc -lprotobuf -lsqlite3 -lxz "$(LIBS_PATH)/lib/libcares.a"

```
Where `$(SRCROOT)/../../libs` is path to this repo on your drive.
Libcares linked with full path to force link to static library.

### Android Studio
In CMakeLists.txt add following:
```
get_filename_component(LIBS_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../../libs" ABSOLUTE)
set(ABI_LIBS_DIR "${LIBS_DIR}/build/Android/${ANDROID_ABI}")

include_directories(${ABI_LIBS_DIR}/include)
link_directories(${ABI_LIBS_DIR}/lib)
```

## License
This project is licensed under the terms of the MIT license. See the [LICENSE](LICENSE) file.

## Authors
* Evgen Bodunov @molind
* Arkadi Tolkun @destman