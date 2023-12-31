make mrproper
make ARCH=x86 headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr
