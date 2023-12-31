make mrproper
make headers ARCH=x86_64
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr
