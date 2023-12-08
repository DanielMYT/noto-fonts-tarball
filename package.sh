#!/bin/bash

# The authors of this script claim no copyright on it due to it being trivial.
# If a license is needed, it can be considered dedicated to the public domain.
# No warranty or guarantee of any kind is provided.

# Note that the output file(s) produced from this script will be under the
# license(s) of their own project(s). The authors of this script make
# no additional copyright claims on those projects.

# Exit on error.
set -e

# Get version and commit info from config file.
. version.conf
pkg_noto="noto-fonts-${NOTO_VERSION}"
pkg_cjk="noto-fonts-cjk-${NOTO_CJK_VERSION}"
pkg_emoji="noto-fonts-emoji-${NOTO_EMOJI_VERSION}"

# Ensure working directory doesn't already exist.
if [ -e "workdir" ]; then
  echo "workdir exists, please remove it first." >&2
  exit 1
fi

# Make the working directory and change to it.
mkdir -p "workdir"; cd "workdir"

# Get Noto Fonts.
echo "Getting Noto Fonts..."
git clone https://github.com/notofonts/notofonts.github.io
cd notofonts.github.io; git checkout "$NOTO_COMMIT"; cd ..

# Get Noto CJK Fonts.
echo "Getting Noto CJK Fonts..."
git clone https://github.com/googlefonts/noto-cjk
cd noto-cjk; git checkout "$NOTO_CJK_COMMIT"; cd ..

# Get Noto Emoji Fonts.
echo "Getting Noto Emoji Fonts..."
git clone https://github.com/googlefonts/noto-emoji
cd noto-emoji; git checkout "$NOTO_EMOJI_COMMIT"; cd ..

# Install Noto Fonts.
echo "Installing Noto Fonts..."
install -t "${pkg_noto}"/usr/share/fonts/noto -Dm644 notofonts.github.io/fonts/*/hinted/ttf/*.ttf
rm -f "${pkg_noto}"/usr/share/fonts/noto/Noto*{Condensed,SemiBold,Extra}*.ttf

# Install Noto CJK.
echo "Installing Noto CJK Fonts..."
install -t "${pkg_cjk}"/usr/share/fonts/noto-cjk -Dm644 noto-cjk/*/OTC/*.ttc

# Install Noto Emoji.
echo "Installing Noto Emoji Fonts..."
install -t "${pkg_emoji}"/usr/share/fonts/noto -Dm644 noto-emoji/fonts/NotoColorEmoji.ttf

# Install fontconfig files.
echo "Installing fontconfig files..."
for i in ../conf/{46,66}-noto-{mono,sans,serif}.conf; do
  install -t "${pkg_noto}"/usr/share/fontconfig/conf.avail -Dm644 $i
  install -d "${pkg_noto}"/usr/share/fontconfig/conf.default
  ln -sf ../conf.avail/$(basename $i) "${pkg_noto}"/usr/share/fontconfig/conf.default/$(basename $i)
done
install -t "${pkg_cjk}"/usr/share/fontconfig/conf.avail  -Dm644 ../conf/70-noto-cjk.conf
install -d "${pkg_cjk}"/usr/share/fontconfig/conf.default
ln -sf ../conf.avail/70-noto-cjk.conf "${pkg_cjk}"/usr/share/fontconfig/conf.default/70-noto-cjk.conf

# Package licenses.
echo "Installing licenses..."
install -t "${pkg_noto}"/usr/share/licenses/noto-fonts -Dm644 notofonts.github.io/LICENSE
install -t "${pkg_cjk}"/usr/share/licenses/noto-fonts-cjk -Dm644 notofonts.github.io/LICENSE
install -t "${pkg_emoji}"/usr/share/licenses/noto-fonts-emoji -Dm644 noto-emoji/LICENSE

# Create tarball for Noto Fonts.
echo "Creating tarball for Noto Fonts..."
tar -cJf "noto-fonts-${NOTO_VERSION}.tar.xz" "noto-fonts-${NOTO_VERSION}"

# Create tarball for Noto CJK Fonts.
echo "Creating tarball for Noto CJK Fonts..."
tar -cJf "noto-fonts-cjk-${NOTO_CJK_VERSION}.tar.xz" "noto-fonts-cjk-${NOTO_CJK_VERSION}"

# Create tarball for Noto Emoji Fonts.
echo "Creating tarball for Noto Emoji Fonts..."
tar -cJf "noto-fonts-emoji-${NOTO_EMOJI_VERSION}.tar.xz" "noto-fonts-emoji-${NOTO_EMOJI_VERSION}"

# Clean up.
echo "Cleaning up..."
mv noto-fonts-*.tar.xz ..
cd ..
rm -rf "workdir"
