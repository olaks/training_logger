#!/usr/bin/env bash
set -euo pipefail

# Build the Flutter web bundle and deploy it to GitHub Pages via the
# gh-pages branch (force-pushed each run as a single orphan commit).
#
# Pages source must be set to branch=gh-pages, path=/. The script also
# triggers a Pages build at the end so the new files go live.

REPO="olaks/training_logger"
BASE_HREF="/training_logger/"
COMMIT_EMAIL="3839812+olaks@users.noreply.github.com"
COMMIT_NAME="Ola Storås"

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$ROOT/flutter_app"
WEB_BUILD="$APP_DIR/build/web"
DEPLOY_DIR="$(mktemp -d -t training-logger-ghpages-XXXXXX)"
trap 'rm -rf "$DEPLOY_DIR"' EXIT

VERSION=$(awk -F'[ +]' '/^version:/ {print $2}' "$APP_DIR/pubspec.yaml")
if [[ -z "$VERSION" ]]; then
  echo "Could not parse version from pubspec.yaml" >&2
  exit 1
fi

echo "Deploying web for v$VERSION → https://olaks.github.io$BASE_HREF"

echo "Building web release..."
cd "$APP_DIR"
flutter pub get
flutter build web --release --base-href "$BASE_HREF"

echo "Staging deploy dir at $DEPLOY_DIR..."
cp -r "$WEB_BUILD/." "$DEPLOY_DIR/"
touch "$DEPLOY_DIR/.nojekyll"

cd "$DEPLOY_DIR"
git init -q -b gh-pages
git remote add origin "git@github.com:$REPO.git"
git add -A
git -c user.email="$COMMIT_EMAIL" -c user.name="$COMMIT_NAME" \
  commit -q -m "Deploy web build v$VERSION"
git push -u --force origin gh-pages

echo "Triggering GitHub Pages build..."
gh api -X POST "/repos/$REPO/pages/builds" >/dev/null

echo "Waiting for Pages build..."
prev=""
while true; do
  s=$(gh api "/repos/$REPO/pages/builds/latest" \
        --jq '.status + " | " + (.error.message // "")' 2>/dev/null || echo "unknown")
  if [[ "$s" != "$prev" ]]; then
    echo "  $s"
    prev="$s"
  fi
  case "$s" in
    built*) break ;;
    errored*) echo "Pages build failed." >&2; exit 1 ;;
  esac
  sleep 5
done

echo "Done: https://olaks.github.io$BASE_HREF"
