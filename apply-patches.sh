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
find thunderbird-patches/$VERSION -type f -name *.patch -exec cp '{}' patches ';'

echo
echo "======================================================="
echo "Applying patch series for main repository"
echo "... without patches for Windows installer"
sed -i 's/08-branding-m-c.patch/# 08-branding-m-c.patch/g' thunderbird-patches/$VERSION/series-M-C
sed -i 's/08a-branding-m-c.patch/# 08a-branding-m-c.patch/g' thunderbird-patches/$VERSION/series-M-C
cat thunderbird-patches/$VERSION/series-M-C | while read line || [[ -n $line ]]
    do 
        [[ -f patches/$line ]] && echo Applying patch $line ... && patch -p1 -i patches/$line
    done

echo
echo "======================================================="
echo "Applying patch series for comm repository"
cd comm
cat ../thunderbird-patches/$VERSION/series | while read line || [[ -n $line ]]
    do
        [[ -f ../patches/$line ]] && echo Applying patch $line ... && patch -p1 -i ../patches/$line
    done
cd ..
