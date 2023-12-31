#以root将文件放在/usr/sources中
chmod -v a+wt /usr/sources

useradd -s /bin/bash -m -k /dev/null cc
#为什么-k /dev/null? https://blog.csdn.net/mjb115889/article/details/82115708

[ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE
su - cc << "SU"
#The ' and ' around the END delimiter are important, otherwise things inside the block like for example $(command) will be parsed and executed.
#https://stackoverflow.com/questions/9712630/what-is-the-difference-between-eof-and-eof-in-shell-heredocs

cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

#主要变量在这，CC_TGT设计为cc而非pc是为了和build的程序分开且兼容 ''内的$,()会被当字符输出，所以注意makeflags的写法(""不会)
cat > ~/.bashrc << "EOF"
set +h
umask 022
CC_DIR=/home/cc/$(uname -m)
LC_ALL=POSIX
CC_TGT=$(uname -m)-cc-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$CC_DIR/tools/bin:$PATH
CONFIG_SITE=$CC_DIR/usr/share/config.site
MAKEFLAGS=-j$(cat /proc/cpuinfo | grep 'processor' | wc -l)
export CC_DIR LC_ALL CC_TGT PATH CONFIG_SITE MAKEFLAGS
EOF

#source ~/.bash_profile在脚本中不可行， . ~/.bash_profile 虽然可以在当前shell进行，但是因为是在其开了的shell里运行.bashrc导致继续运行脚本时没有正确环境
#即使如同下一列，也没有读取bashrc 而若执行/bin/bash改成执行bashrc，不仅要解决权限问题，也将无法完成之后命令
env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash << "ENV"
. ~/.bashrc
mkdir -pv $CC_DIR/{etc,var,lib,bin} $CC_DIR/usr $CC_DIR/tools
ln -sv $CC_DIR/lib $CC_DIR/usr/lib
ln -sv $CC_DIR/bin $CC_DIR/sbin
ln -sv $CC_DIR/bin $CC_DIR/usr/bin
ln -sv $CC_DIR/bin $CC_DIR/usr/sbin

case $(uname -m) in
  x86_64) mkdir -pv $CC_DIR/lib64
  ln -sv $CC_DIR/lib $CC_DIR/lib64
  ln -sv $CC_DIR/lib $CC_DIR/usr/lib64 ;;
esac

cd /usr/sources
tar xvf binutils*.tar.*
cd binutils*/
mkdir -v build
cd       build
../configure --prefix=$CC_DIR/tools \
             --with-sysroot=$CC_DIR \
             --target=$CC_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror
            
make
make install
cd -
rm binutils*/ -rf

tar xvf gcc*.tar.*
cd gcc*/
tar -xf ../mpfr-4.2.0.tar.xz
mv -v mpfr-4.2.0 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
 ;;
esac
mkdir -v build
cd       build
../configure                  \
    --target=$CC_TGT         \
    --prefix=$CC_DIR/tools       \
    --with-glibc-version=2.38 \
    --with-sysroot=$CC_DIR       \
    --with-newlib             \
    --without-headers         \
    --enable-default-pie      \
    --enable-default-ssp      \
    --disable-nls             \
    --disable-shared          \
    --disable-multilib        \
    --disable-threads         \
    --disable-libatomic       \
    --disable-libgomp         \
    --disable-libquadmath     \
    --disable-libssp          \
    --disable-libvtv          \
    --disable-libstdcxx       \
    --enable-languages=c,c++
  make
  make install
cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($CC_TGT-gcc -print-libgcc-file-name)`/include/limits.h
cd -
rm gcc*/ -rf

tar xvf linux*.tar.*
cd linux*/
make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $CC_DIR/usr
cd -
rm linux*/ -rf

tar xvf glibc*.tar.*
cd glibc*/
case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 $CC_DIR/lib/ld-lsb.so.3
    ;;
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $CC_DIR/lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 $CC_DIR/lib64/ld-lsb-x86-64.so.3
    ;;
esac
patch -Np1 -i ../glibc-2.38-fhs-1.patch
mkdir -v build
cd       build
echo "rootsbindir=/usr/sbin" > configparms
../configure                             \
      --prefix=/usr                      \
      --host=$CC_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=4.14               \
      --with-headers=$CC_DIR/usr/include    \
      libc_cv_slibdir=/usr/lib
make
make DESTDIR=$CC_DIR install
sed '/RTLDLIST=/s@/usr@@g' -i $CC_DIR/usr/bin/ldd
cd -
rm glibc*/ -rf

tar xvf gcc*.tar.*
cd gcc*/
mkdir -v build
cd       build
../libstdc++-v3/configure           \
    --host=$CC_TGT                 \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$CC_TGT/include/c++/13.2.0
 make
  make DESTDIR=$CC_DIR install
  rm -v $CC_DIR/usr/lib/lib{stdc++,stdc++fs,supc++}.la
cd -
rm gcc*/ -rf
ENV
SU
[ ! -e /etc/bash.bashrc.NOUSE ] || mv -v /etc/bash.bashrc.NOUSE /etc/bash.bashrc