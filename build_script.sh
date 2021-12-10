#!/usr/bin/env bash

set -euo pipefail

emacs -Q --batch -l ./publish.el --funcall my/update-org-id-locations-file
emacs -Q --batch -l ./publish.el --funcall my/publish
cp -rf site_assets/* public/
ruby serialize_search_index.rb | node build-index.js > public/search-index.js
