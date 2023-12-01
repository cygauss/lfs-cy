make mrproper
make headers #ARCH=loongarch
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $CLFS/usr
