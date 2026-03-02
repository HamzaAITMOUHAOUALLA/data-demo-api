#!/bin/bash
set -e

currentVersion=$(cat VERSION)
IFS='.' read -r major minor patch <<< "$currentVersion"

patch=$((patch+1))

if [ "$patch" -gt 9 ]; then
  patch=0
  minor=$((minor+1))
fi

if [ "$minor" -gt 9 ]; then
  minor=0
  major=$((major+1))
fi

newVersion="$major.$minor.$patch"

echo "v$newVersion" > .image_tag
echo "$newVersion" > VERSION

echo "New version: v$newVersion"
