./configure --disable-shared /
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess)
--disable-shared
make
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} $LFS/usr/bin
