#!/bin/bash
VERSION="$1"

UNAME=$(uname)
UNAME_ARCH=$(uname -i)
# Hack for Debian 11 Bullseye on Amazon EC2 image.
if [[ "$UNAME" == *"$aarch64"* ]] && [ "$UNAME_ARCH" = "unknown" ]; then
    UNAME_ARCH="aarch64"
fi

. thunderbird-patches/$VERSION/$VERSION.sh

if [ "$UNAME_ARCH" = "x86_64" ]; then
    echo
    echo "======================================================="
    echo "Copying mozconfig-Linux"
    cp thunderbird-patches/$VERSION/mozconfig-Linux mozconfig
elif [ "$UNAME_ARCH" = "aarch64" ]; then
    echo
    echo "======================================================="
    echo "Copying mozconfig-Linux-aarch64"
    cp thunderbird-patches/$VERSION/mozconfig-Linux-aarch64 mozconfig
fi

echo
echo "======================================================="
echo "Copying patches"
cp thunderbird-patches/$VERSION/mozconfig-Linux mozconfig
rm -rf patches; mkdir patches
find thunderbird-patches -type f -name *.patch -exec cp '{}' patches ';'

echo
echo "======================================================="
echo "Applying patch series for main repository"
cat thunderbird-patches/$VERSION/series-M-C | while read line || [[ -n $line ]]; do [[ -f patches/$line ]] && echo Applying patch $line ... && patch -R -p1 < patches/$line; done

echo
echo "======================================================="
echo "Applying patch series for comm repository"
cd comm
cat thunderbird-patches/$VERSION/series | while read line || [[ -n $line ]]; do [[ -f ../patches/$line ]] && echo Applying patch $line ... && patch -R -p1 < ../patches/$line; done
cd ..
