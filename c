export LFS=/mnt/lfs
mkdir -pv $LFS
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources
chown -R root:root $LFS/sources
mkdir -pv $LFS/{boot,etc,var} $LFS/usr/{bin,lib}
ln -sv bin $LFS/usr/sbin
for i in bin lib sbin; do
  ln -sv usr/$i $LFS/$i
done

case $(uname -m) in
  x86_64) ln -sv lib $LFS/usr/lib64
   ln -sv usr/lib64 $LFS/lib64 ;;
esac

mkdir -pv $LFS/lib64
mkdir -pv $LFS/tools

useradd -s /bin/bash -m -k /dev/null lfs
chown -R lfs $LFS

[ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE
su - lfs << "SU"

cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=x86_64-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
MAKEFLAGS=-j$(nproc)
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE MAKEFLAGS
EOF

env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash << "ENV"
. ~/.bashrc

cat > $LFS/tools/bin/notpm << "EOF"
pushd $LFS/sources
tar xvf $i*.tar.*
pushd $i*/
bash ../$i${!i}.sh
popd
rm -rf $i*/
popd
EOF

/bin/bash << "BASH"
for i in binutils gcc linux glibc gcc m4 ncurses bash coreutils diffutils file findutils gawk grep gzip make patch sed tar xz binutils gcc util grub linux gettext bison perl python texinfo; do
if [ -z ${!i} ] ;then
export $i=1
else
export $i=$((${!i}+1))
fi
notpm
done
BASH









