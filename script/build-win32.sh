#!/bin/bash
#
# Repackaging Git for Windows and bundling Git LFS from upstream.
#

DESTINATION=$1
mkdir -p $DESTINATION

# download Git for Windows, verify its the right contents, and unpack it
GIT_FOR_WINDOWS_FILE=git-for-windows.zip
curl -sL -o $GIT_FOR_WINDOWS_FILE $GIT_FOR_WINDOWS_URL
if [ "$APPVEYOR" == "True" ]; then
  COMPUTED_SHA256=$(sha256sum $GIT_FOR_WINDOWS_FILE | awk '{print $1;}')
else
  COMPUTED_SHA256=$(shasum -a 256 $GIT_FOR_WINDOWS_FILE | awk '{print $1;}')
fi

if [ "$COMPUTED_SHA256" = "$GIT_FOR_WINDOWS_CHECKSUM" ]; then
  echo "Git for Windows: checksums match"
  unzip -qq $GIT_FOR_WINDOWS_FILE -d $DESTINATION
else
  echo "Git for Windows: expected checksum $GIT_FOR_WINDOWS_CHECKSUM but got $COMPUTED_SHA256"
  echo "aborting..."
  exit 1
fi

# download Git LFS, verify its the right contents, and unpack it
GIT_LFS_FILE=git-lfs.zip
curl -sL -o $GIT_LFS_FILE $GIT_LFS_URL
if [ "$APPVEYOR" == "True" ]; then
  COMPUTED_SHA256=$(sha256sum $GIT_LFS_FILE | awk '{print $1;}')
else
  COMPUTED_SHA256=$(shasum -a 256 $GIT_LFS_FILE | awk '{print $1;}')
fi
if [ "$COMPUTED_SHA256" = "$GIT_LFS_CHECKSUM" ]; then
  echo "Git LFS: checksums match"
  SUBFOLDER="$DESTINATION/mingw64/libexec/git-core/"
  unzip -qq -j $GIT_LFS_FILE -x '*.md' -d $SUBFOLDER
else
  echo "Git LFS: expected checksum $GIT_LFS_CHECKSUM and got $COMPUTED_SHA256"
  echo "aborting..."
  exit 1
fi

# replace OpenSSL curl with the WinSSL variant
# this was recently incorporated into MinGit, so let's just move the file over and cleanup
ORIGINAL_CURL_LIBRARY="$DESTINATION/mingw64/bin/libcurl-4.dll"
WINSSL_CURL_LIBRARY="$DESTINATION/mingw64/bin/curl-winssl/libcurl-4.dll"
mv $WINSSL_CURL_LIBRARY $ORIGINAL_CURL_LIBRARY
rm -rf "$DESTINATION/mingw64/bin/curl-winssl/"

# TODO: validate change
