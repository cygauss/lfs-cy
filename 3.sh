export MAKEFLAGS='-j16'
#ensure the partition mkfsed
#export LFS_PART=/dev/nvme0n1p3
#the dir of sources(don't put / at end)
export LFS_SOURCES=/root/sources

NOT_DIF=".cfg" NOT_SOURCES="/root/sources" bash $LFS_SOURCES/notpm linux

export LFS=/mnt/lfs
mkdir -pv $LFS

#mount -v $LFS_PART $LFS

mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources
cp -a $LFS_SOURCES/. $LFS/sources
echo $MAKEFLAGS > $LFS/sources/makeflags
chown root:root $LFS/sources/*

mkdir -p $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
  ln -sv usr/$i $LFS/$i
done

case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64 ;;
esac

mkdir -pv $LFS/tools
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) chown -v lfs $LFS/lib64 ;;
esac

[ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE

su - lfs  << "END"

cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
MAKEFLAGS=$(cat /mnt/lfs/sources/makeflags)
NOT_SOURCES=/mnt/lfs/sources
NOT_DIF=.cc
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE MAKEFLAGS NOT_SOURCES NOT_DIF
EOF

. ~/.bash_profile

. ~/.bashrc

bash $NOT_SOURCES/notpm binutils
bash $NOT_SOURCES/notpm gcc
NOT_DIF=".cc-headers" bash $NOT_SOURCES/notpm linux
bash $NOT_SOURCES/notpm glibc
NOT_DIF=".cc-libstdc++"  bash $NOT_SOURCES/notpm gcc
export NOT_DIF=".tt"
bash $NOT_SOURCES/notpm m4
bash $NOT_SOURCES/notpm ncurses
bash $NOT_SOURCES/notpm bash
bash $NOT_SOURCES/notpm coreutils
bash $NOT_SOURCES/notpm diffutils
bash $NOT_SOURCES/notpm file
bash $NOT_SOURCES/notpm findutils
bash $NOT_SOURCES/notpm gawk
bash $NOT_SOURCES/notpm grep
bash $NOT_SOURCES/notpm gzip
bash $NOT_SOURCES/notpm make
bash $NOT_SOURCES/notpm patch
bash $NOT_SOURCES/notpm sed
bash $NOT_SOURCES/notpm tar
bash $NOT_SOURCES/notpm xz
bash $NOT_SOURCES/notpm binutils
bash $NOT_SOURCES/notpm gcc
END

chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) chown -R root:root $LFS/lib64 ;;
esac
mkdir -pv $LFS/{dev,proc,sys,run}
mount -v --bind /dev $LFS/dev
mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run
if [ -h $LFS/dev/shm ]; then
  mkdir -pv $LFS/$(readlink $LFS/dev/shm)
else
  mount -t tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi

chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    MAKEFLAGS="$MAKEFLAGS"      \
    NOT_DIF=.tt                 \
    NOT_SOURCES=/sources        \
   /bin/bash --login << "END"
mkdir -pv /{boot,home,mnt,opt,srv}
mkdir -pv /etc/{opt,sysconfig}
mkdir -pv /lib/firmware
mkdir -pv /media/{floppy,cdrom}
mkdir -pv /usr/{,local/}{include,src}
mkdir -pv /usr/local/{bin,lib,sbin}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
mkdir -pv /var/{cache,local,log,mail,opt,spool}
mkdir -pv /var/lib/{color,misc,locate}
ln -sfv /run /var/run
ln -sfv /run/lock /var/lock
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp
ln -sv /proc/self/mounts /etc/mtab

cat > /etc/hosts << "EOF"
127.0.0.1  localhost $(hostname)
::1        localhost
EOF

cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF

touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

bash /sources/notpm gettext
bash /sources/notpm bison
bash /sources/notpm perl
bash /sources/notpm Python
bash /sources/notpm texinfo
bash /sources/notpm util-linux
rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
rm -rf /tools
export NOT_DIF=.lfs
bash /sources/notpm man-pages
bash /sources/notpm iana-etc
bash /sources/notpm glibc
bash /sources/notpm zlib
bash /sources/notpm bzip2
bash /sources/notpm xz
bash /sources/notpm zstd
bash /sources/notpm file
bash /sources/notpm readline
bash /sources/notpm m4
bash /sources/notpm bc
bash /sources/notpm flex
bash /sources/notpm tcl
bash /sources/notpm expect
bash /sources/notpm dejagnu
bash /sources/notpm binutils
bash /sources/notpm gmp
bash /sources/notpm mpfr
bash /sources/notpm mpc
bash /sources/notpm attr
bash /sources/notpm acl
bash /sources/notpm libcap
bash /sources/notpm libxcrypt
bash /sources/notpm shadow
bash /sources/notpm gcc
bash /sources/notpm pkgconf
bash /sources/notpm ncurses
bash /sources/notpm sed
bash /sources/notpm psmisc
bash /sources/notpm gettext
bash /sources/notpm bison
bash /sources/notpm grep
bash /sources/notpm bash
exec /usr/bin/bash --login << "EOF"
bash /sources/notpm libtool
bash /sources/notpm gdbm
bash /sources/notpm gperf
bash /sources/notpm expat
bash /sources/notpm inetutils
bash /sources/notpm less
bash /sources/notpm perl
bash /sources/notpm XML::Parser
bash /sources/notpm intltool
bash /sources/notpm autoconf
bash /sources/notpm automake
bash /sources/notpm openssl
bash /sources/notpm kmod
NOT_DIF=".lfs-libelf" bash /sources/notpm elfutils
bash /sources/notpm libffi
bash /sources/notpm Python
bash /sources/notpm flit_core
bash /sources/notpm wheel
bash /sources/notpm ninja
bash /sources/notpm meson
bash /sources/notpm coreutils
bash /sources/notpm check
bash /sources/notpm diffutils
bash /sources/notpm gawk
bash /sources/notpm findutils
bash /sources/notpm groff
NOT_DIF=".blfs" bash /sources/notpm mandoc
NOT_DIF=".blfs" bash /sources/notpm efivar
NOT_DIF=".blfs" bash /sources/notpm popt
NOT_DIF=".blfs" bash /sources/notpm efibootmgr
NOT_DIF=".blfs" bash /sources/notpm grub
bash /sources/notpm gzip
bash /sources/notpm iproute2
bash /sources/notpm kbd
bash /sources/notpm libpipeline
bash /sources/notpm make
bash /sources/notpm patch
bash /sources/notpm tar
bash /sources/notpm texinfo
bash /sources/notpm MarkupSafe
bash /sources/notpm Jinja2
NOT_DIF=".lfs-udev" bash /sources/notpm Systemd
bash /sources/notpm man-db
bash /sources/notpm procps-ng
bash /sources/notpm util-linux
bash /sources/notpm e2fsprogs
bash /sources/notpm sysklogd
bash /sources/notpm sysvint

save_usrlib="$(cd /usr/lib; ls ld-linux*[^g])
             libc.so.6
             libthread_db.so.1
             libquadmath.so.0.0.0
             libstdc++.so.6.0.32
             libitm.so.1.0.0
             libatomic.so.1.2.0"

cd /usr/lib

for LIB in $save_usrlib; do
    objcopy --only-keep-debug $LIB $LIB.dbg
    cp $LIB /tmp/$LIB
    strip --strip-unneeded /tmp/$LIB
    objcopy --add-gnu-debuglink=$LIB.dbg /tmp/$LIB
    install -vm755 /tmp/$LIB /usr/lib
    rm /tmp/$LIB
done

online_usrbin="bash find strip"
online_usrlib="libbfd-2.41.so
               libsframe.so.1.0.0
               libhistory.so.8.2
               libncursesw.so.6.4
               libm.so.6
               libreadline.so.8.2
               libz.so.1.2.13
               $(cd /usr/lib; find libnss*.so* -type f)"

for BIN in $online_usrbin; do
    cp /usr/bin/$BIN /tmp/$BIN
    strip --strip-unneeded /tmp/$BIN
    install -vm755 /tmp/$BIN /usr/bin
    rm /tmp/$BIN
done

for LIB in $online_usrlib; do
    cp /usr/lib/$LIB /tmp/$LIB
    strip --strip-unneeded /tmp/$LIB
    install -vm755 /tmp/$LIB /usr/lib
    rm /tmp/$LIB
done

for i in $(find /usr/lib -type f -name \*.so* ! -name \*dbg) \
         $(find /usr/lib -type f -name \*.a)                 \
         $(find /usr/{bin,sbin,libexec} -type f); do
    case "$online_usrbin $online_usrlib $save_usrlib" in
        *$(basename $i)* )
            ;;
        * ) strip --strip-unneeded $i
            ;;
    esac
done

unset BIN LIB save_usrlib online_usrbin online_usrlib

rm -rf /tmp/*
find /usr/lib /usr/libexec -name \*.la -delete
find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf

bash /sources/notpm lfs-bootscripts
bash /usr/lib/udev/init-net-rules.sh
echo "<lfs>" > /etc/hostname
cat > /etc/inittab << "EXI"
# Begin /etc/inittab

id:3:initdefault:

si::sysinit:/etc/rc.d/init.d/rc S

l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6

ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now

su:S06:once:/sbin/sulogin
s1:1:respawn:/sbin/sulogin

1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
4:2345:respawn:/sbin/agetty tty4 9600
5:2345:respawn:/sbin/agetty tty5 9600
6:2345:respawn:/sbin/agetty tty6 9600

# End /etc/inittab
EXI

cat > /etc/sysconfig/clock << "EXI"
# Begin /etc/sysconfig/clock

UTC=0

# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
CLOCKPARAMS=

# End /etc/sysconfig/clock
EXI
cat > /etc/profile << "EXI"
# Begin /etc/profile

export LANG=en_SG.UTF-8

# End /etc/profile
EXI

cat > /etc/inputrc << "EXI"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8-bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
EXI

cat > /etc/shells << "EXI"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EXI

cat > /etc/fstab << "EXI"
# Begin /etc/fstab
/dev/nvme0n1p2     /            ext4       defaults            0     1
/dev/nvme0n1p1     /boot         vfat       defaults            0     2
proc           /proc          proc     nosuid,noexec,nodev 0     0
sysfs          /sys           sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts       devpts   gid=5,mode=620      0     0
tmpfs          /run           tmpfs    defaults            0     0
devtmpfs       /dev           devtmpfs mode=0755,nosuid    0     0
tmpfs          /dev/shm       tmpfs    nosuid,nodev        0     0
cgroup2        /sys/fs/cgroup cgroup2  nosuid,noexec,nodev 0     0
# End /etc/fstab
EXI

bash /sources/notpm linux
echo 12.0 > /etc/lfs-release
cat > /etc/lsb-release << "EXI"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="12.0"
DISTRIB_CODENAME="<your name here>"
DISTRIB_DESCRIPTION="Linux From Scratch"
EXI

cat > /etc/os-release << "EXI"
NAME="Linux From Scratch"
VERSION="12.0"
ID=lfs
PRETTY_NAME="Linux From Scratch 12.0"
VERSION_CODENAME="<your name here>"
EXI

EOF
END

umount -v $LFS/dev/pts
mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm
umount -v $LFS/dev
umount -v $LFS/run
umount -v $LFS/proc
umount -v $LFS/sys

userdel -r lfs
[ ! -e /etc/bash.bashrc.NOUSE ] || mv -v /etc/bash.bashrc.NOUSE /etc/bash.bashrc
