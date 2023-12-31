./configure --prefix=$LFS/tools               \
            --build=$(build-aux/config.guess) \
            --host=$(build-aux/config.guess)  \
            --target=$LFS_TGT                 \
            --program-prefix=lfs-             \
            --disable-werror'
            make
            make install
