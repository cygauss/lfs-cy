./configure --prefix=/usr   \
            --enable-shared \
            --without-ensurepip \
                        --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess)
            make
make DESTDIR=$LFS install
