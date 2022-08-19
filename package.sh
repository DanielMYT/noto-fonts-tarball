#!/bin/bash

# Exit on error.
set -e

# Get version and commit info from config file.
. version.conf
pkg="noto-fonts-$VERSION"

# Ensure working directory doesn't already exist.
if [ -e "workdir" ]; then
  echo "workdir exists, please remove it first." >&2
  exit 1
fi

# Make the working directory and change to it.
mkdir -p "workdir"; cd "workdir"

# Get the stuff.
echo "Getting Noto Fonts..."
git clone https://github.com/googlefonts/noto-fonts
cd noto-fonts; git checkout "$NOTO_COMMIT"; cd ..
rm -f {hinted,unhinted}/ttf/NotoSansTifinagh/NotoSansTifinagh{A,G,H,R,S,T}*.ttf

echo "Getting Noto CJK..."
git clone https://github.com/googlefonts/noto-cjk
cd noto-cjk; git checkout "$NOTO_CJK_COMMIT"; cd ..

echo "Getting Noto Emoji..."
git clone https://github.com/googlefonts/noto-emoji
cd noto-emoji; git checkout "$NOTO_EMOJI_COMMIT"; cd ..

# Install Noto Fonts.
echo "Installing Noto Fonts..."
install -t "$pkg"/usr/share/fonts/noto -Dm644 noto-fonts/unhinted/ttf/Noto*/*.tt{c,f}
install -t "$pkg"/usr/share/fonts/noto -Dm644 noto-fonts/hinted/ttf/Noto*/*.ttf
rm -f "$pkg"/usr/share/fonts/noto/Noto*{Condensed,SemiBold,Extra}*.ttf

# Install Noto CJK.
echo "Installing Noto CJK..."
install -t "$pkg"/usr/share/fonts/noto-cjk -Dm644 noto-cjk/*/OTC/*.ttc

# Install Noto Emoji.
echo "Installing Noto Emoji..."
install -t "$pkg"/usr/share/fonts/noto -Dm644 noto-emoji/fonts/NotoColorEmoji.ttf

# Install fontconfig files.
echo "Installing fontconfig files..."
mkdir -p "$pkg"/etc/fonts/conf.d
for i in ../conf/*; do
  install -t "$pkg"/usr/share/fontconfig/conf.avail -Dm644 $i
  ln -sf ../../../usr/share/fontconfig/conf.avail/$(basename $i) "$pkg"/etc/fonts/conf.d/$(basename $i)
done

# Install licenses.
echo "Installing licenses..."
install -Dm644 noto-fonts/LICENSE "$pkg"/usr/share/licenses/noto-fonts/LICENSE.noto
install -Dm644 noto-cjk/LICENSE "$pkg"/usr/share/licenses/noto-fonts/LICENSE.noto-cjk
install -Dm644 noto-emoji/LICENSE "$pkg"/usr/share/licenses/noto-fonts/LICENSE.noto-emoji

# Create tarball.
echo "Creating package tarball..."
tar -cJf "noto-fonts-$VERSION.tar.xz" "noto-fonts-$VERSION"

# Clean up.
echo "Cleaning up..."
mv "noto-fonts-$VERSION.tar.xz" ..
cd ..
rm -rf "workdir"
