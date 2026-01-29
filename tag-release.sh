#!/bin/bash
set -e

usage() {
    cat <<EOF
Usage: $0 <version> <track>

Tracks: ltr, lr, dev

Examples:
  $0 3.44.8 ltr     -> v3.44.8-ltr-1
  $0 4.0.0 lr       -> v4.0.0-lr-1
  $0 4.1 dev        -> v4.1-dev-$(date +%Y%m%d)-1
EOF
    exit 1
}

[[ $# -lt 2 ]] && usage

VERSION="$1"
TRACK="$2"

case "$TRACK" in
    ltr|lr) [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] && \
            { echo "Error: Version must be X.Y.Z"; exit 1; } ;;
    dev)    [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+$ ]] && \
            { echo "Error: Dev version must be X.Y"; exit 1; }
            VERSION="${VERSION}-dev-$(date +%Y%m%d)" ;;
    *)      echo "Error: Invalid track '$TRACK'"; exit 1 ;;
esac

[[ "$(git branch --show-current)" != "master" ]] && \
    { echo "Error: Must be on master"; exit 1; }

git diff --quiet && git diff --cached --quiet || \
    { echo "Error: Uncommitted changes"; exit 1; }

git pull origin master

PATTERN="v${VERSION}-${TRACK}-*"
EXISTING=$(git tag -l "$PATTERN" | grep -E "^v${VERSION}-${TRACK}-[0-9]+$" || true)

if [[ -z "$EXISTING" ]]; then
    BUILD=1
else
    BUILD=$(echo "$EXISTING" | sed -E "s/.*-([0-9]+)$/\1/" | sort -n | tail -1)
    BUILD=$((BUILD + 1))
fi

TAG="v${VERSION}-${TRACK}-${BUILD}"

git tag -a "$TAG" -m "Release $TAG"

cat <<EOF

Created: $TAG

To release:
  git push origin $TAG

Monitor:
  https://github.com/kwinsch/qgis-server-docker/actions

Verify:
  https://hub.docker.com/r/kwinsch/qgis-server-docker/tags
EOF
