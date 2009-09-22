#!/bin/sh
VERSION=`grep -A 1 CFBundleVersion Info.plist | grep string | sed -e "s/.*\<string\>\(.*\)\<\/string\>.*/\1/"`

rm -rf _tmp

xcodebuild DSTROOT=_tmp INSTALL_PATH=/ install -configuration Release

sed -e "s/{VERSION}/${VERSION}/" MacSweeper\ ReadMe.rtf > _tmp/MacSweeper\ ReadMe.rtf

DMG_NAME=MacSweeper-${VERSION}
rm -f ${DMG_NAME}.dmg
hdiutil create -srcfolder _tmp -volname ${DMG_NAME} ${DMG_NAME}.dmg

rm -rf _tmp
