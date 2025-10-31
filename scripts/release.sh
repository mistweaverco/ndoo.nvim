#!/usr/bin/env bash

set -euo pipefail

GH_TAG="v$VERSION"

do_gh_release() {
  echo "Creating new release $GH_TAG"
  gh release create --generate-notes "$GH_TAG"
}

do_gh_release
