#!/usr/bin/env bash

sudo add-apt-repository ppa:kelleyk/emacs
sudo apt-get update
sudo apt-get install emacs27
mkdir public
emacs -Q --batch -l ./publish.el --funcall my/publish
cp -r site_assets/* public/
