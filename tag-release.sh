#!/bin/bash

set -e

# Check if version argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 3.44.0"
    echo ""
    echo "This will create a tag like 'v3.44.0-1' where -1 is the build number"
    exit 1
fi

VERSION=$1

# Validate version format (basic semver)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format X.Y.Z (e.g., 3.44.0)"
    exit 1
fi

# Ensure we're on master branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "master" ]; then
    echo "Error: Must be on master branch to create release tags"
    echo "Current branch: $CURRENT_BRANCH"
    exit 1
fi

# Ensure working directory is clean
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Error: Working directory has uncommitted changes"
    git status --short
    exit 1
fi

# Pull latest changes
echo "Pulling latest changes from master..."
git pull origin master

# Find the highest build number for this version
EXISTING_TAGS=$(git tag -l "v${VERSION}-*" 2>/dev/null | grep -E "^v${VERSION}-[0-9]+$" || true)

if [ -z "$EXISTING_TAGS" ]; then
    BUILD_NUMBER=1
else
    # Extract build numbers and find the highest
    BUILD_NUMBER=$(echo "$EXISTING_TAGS" | sed -E "s/^v${VERSION}-([0-9]+)$/\1/" | sort -n | tail -1)
    BUILD_NUMBER=$((BUILD_NUMBER + 1))
fi

# Create the full tag
TAG="v${VERSION}-${BUILD_NUMBER}"

echo "Creating tag: $TAG"

# Create annotated tag
git tag -a "$TAG" -m "Release $TAG"

echo "Tag created successfully: $TAG"
echo ""
echo "To push the tag to remote, run:"
echo "  git push origin $TAG"
echo ""
echo "To push all tags, run:"
echo "  git push origin --tags"