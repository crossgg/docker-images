#!/bin/sh

ROOT_DIR=`pwd`
rm -rf typecho

echo "Downloading typecho v1.3.0 release..."
curl -L -o typecho.zip https://github.com/typecho/typecho/releases/download/v1.3.0/typecho.zip
unzip typecho.zip -d typecho
rm -f typecho.zip

echo "typecho v1.3.0 downloaded and extracted to ./typecho"

# Download themes
cd "$ROOT_DIR/typecho/usr/themes"
git clone https://github.com/Dreamer-Paul/Single.git single
git clone https://github.com/ttys3/typecho-theme-amaze.git amaze
git clone https://github.com/shiyiya/typecho-theme-sagiri.git Sagiri
git clone https://github.com/Siphils/Typecho-Theme-Aria.git Aria
git clone https://github.com/Seevil/fantasy.git fantasy

# Download plugins
cd "$ROOT_DIR/typecho/usr/plugins"
git clone https://github.com/ayangyuan/Youtube-Typecho-Plugin Youtube
git clone https://github.com/Dreamer-Paul/Pio.git Pio
git clone https://github.com/Copterfly/CodeHighlighter-for-Typecho.git CodeHighlighter
git clone https://github.com/ttys3/typecho-AceThemeEditor.git AceThemeEditor

cd "$ROOT_DIR"