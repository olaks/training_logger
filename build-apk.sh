#!/usr/bin/env bash
set -euo pipefail

# Flutter/Android builds require JDK 17 (Gradle's Kotlin compiler
# can't handle JDK 26+).  Use it if installed.
JDK17="/usr/lib/jvm/java-17-openjdk"
if [[ -d "$JDK17" ]]; then
  export JAVA_HOME="$JDK17"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

cd "$(dirname "$0")/flutter_app"

echo "Building release APK..."
flutter pub get
flutter build apk --release
APK="build/app/outputs/flutter-apk/app-release.apk"
echo "APK built: flutter_app/$APK"
echo ""

echo "Building Linux release..."
flutter build linux --release
LINUX_ZIP="build/linux/x64/release/training-logger-linux.zip"
bsdtar -a -cf "$LINUX_ZIP" --options zip:compression=deflate -C build/linux/x64/release bundle
echo "Linux bundle built: flutter_app/$LINUX_ZIP"
echo ""

read -rp "Upload to GitHub release 'latest'? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  gh release upload latest "$APK" "$LINUX_ZIP" --clobber --repo olaks/training_logger
  echo "Uploaded."
fi
