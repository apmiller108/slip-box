#!/usr/bin/env bash

set -euo pipefail

# Copy and compile locked packages
mkdir -p .packages
cp -r .packages-locked/* .packages
emacs -Q --batch -l ./publish.el --funcall my/byte-compile-packages-locked

# Update the org ID locations
printf 'yes' | emacs -Q --batch -l ./publish.el --funcall my/update-org-id-locations-file

# Build the markup
emacs -Q --batch -l ./publish.el --funcall my/publish

# Copy the assets (css, js, images, ..etc)
cp -rf site_assets/* public/

# Build the search index file in public dir
ruby serialize_search_index.rb | node build-index.js > public/search-index.js
