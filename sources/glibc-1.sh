case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 $LFS/usr/lib/ld-lsb.so.3
    ;;
    x86_64) ln -sfv ld-linux-x86-64.so.2 $LFS/usr/lib/ld-lsb-x86-64.so.3
    ;;
esac
patch -Np1 -i ../glibc-2.38-fhs-1.patch
mkdir -v build
cd       build
echo "rootsbindir=/usr/bin" > configparms
../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=6.6.8              \
      --with-headers=$LFS/usr/include    \
      --disable-nscd \
      libc_cv_slibdir=/usr/lib
make
make DESTDIR=$LFS install
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
