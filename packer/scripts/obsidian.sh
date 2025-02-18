#!/bin/bash

cd `mktemp -d`
wget $(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep "browser_download_url.*deb" | grep -v "arm64" | cut -d : -f 2,3 | tr -d \") && apt-get install -qq ./obsidian*.deb