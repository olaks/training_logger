#!/usr/bin/env bash
# Analyze and test the Flutter app — what the pre-commit hook runs, and what
# release.sh runs before a release.
#
# A widget test that fails mid-pumpAndSettle can leave `flutter test` running
# forever, so the run is capped instead of left to hang.
set -euo pipefail
cd "$(dirname "$0")/../flutter_app"

flutter analyze
timeout "${CHECK_TEST_TIMEOUT:-300}" flutter test
