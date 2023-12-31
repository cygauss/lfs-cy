./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2 \
                        --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) 
--docdir=/usr/share/doc/bison-3.8.2
make
make install
