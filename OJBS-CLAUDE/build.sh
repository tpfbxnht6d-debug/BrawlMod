#!/usr/bin/env bash
set -euo pipefail

SCHEME="BrawlMod"
PROJECT="BrawlMod.xcodeproj"
CONFIG="Release"
BUILD_DIR="$(pwd)/build"
DIST_DIR="$(pwd)/dist"
ARCHIVE_PATH="$BUILD_DIR/$SCHEME.xcarchive"

rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR"

echo ">> archiving (unsigned)"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGN_ENTITLEMENTS="" \
  ONLY_ACTIVE_ARCH=NO \
  archive

APP_PATH="$ARCHIVE_PATH/Products/Applications/$SCHEME.app"
if [ ! -d "$APP_PATH" ]; then
  echo "!! archive did not produce $SCHEME.app"
  exit 1
fi

echo ">> packaging IPA"
PAYLOAD_DIR="$BUILD_DIR/Payload"
rm -rf "$PAYLOAD_DIR"
mkdir -p "$PAYLOAD_DIR"
cp -R "$APP_PATH" "$PAYLOAD_DIR/"

pushd "$BUILD_DIR" > /dev/null
zip -qry "$DIST_DIR/$SCHEME.ipa" "Payload"
popd > /dev/null

echo ">> output: $DIST_DIR/$SCHEME.ipa"
ls -lh "$DIST_DIR/$SCHEME.ipa"
