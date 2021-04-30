#!/usr/bin/env bash

emacs -Q --batch -l ./publish.el --funcall my/publish
ln -s ${HOME}/slip-box/site_assets/css ${HOME}/slip-box/public/css
ln -s ${HOME}/slip-box/site_assets/js ${HOME}/slip-box/public/js
