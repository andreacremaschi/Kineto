#!/bin/sh
MACOSX_HEADER_DIR="$BUILD_DIR/$BUILD_STYLE/dc1394.framework/Headers/macosx";

VENDOR_HEADER_DIR="$BUILD_DIR/$BUILD_STYLE/dc1394.framework/Headers/vendor";

mkdir -p "$MACOSX_HEADER_DIR";
cp "$SOURCE_ROOT/libdc1394-current/dc1394/macosx/capture.h" "$MACOSX_HEADER_DIR";

mkdir -p "$VENDOR_HEADER_DIR";
cd "$SOURCE_ROOT/libdc1394-current/dc1394/vendor";
cp avt.h basler.h basler_sff.h pixelink.h "$VENDOR_HEADER_DIR";
cd "$OLDPWD";
