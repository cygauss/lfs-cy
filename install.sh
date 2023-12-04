export MAKEFLAGS='-j16'
#ensure the partition mkfsed
export LFS_PART=/dev/nvme0n1p3
#the dir of sources(don't put / at end)
export LFS_SOURCES=/root/sources

export LFS=/mnt/lfs
mkdir -pv $LFS

mount -v $LFS_PART $LFS

mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources
cp $LFS_SOURCES/* $LFS/sources
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
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE MAKEFLAGS NOT_SOURCES
EOF

. ~/.bash_profile

. ~/.bashrc

NOT_DIF=".cc"  bash $LFS/sources/notpm binutils
NOT_DIF=".cc"  bash $LFS/sources/notpm gcc
NOT_DIF=".cc-headers" bash $LFS/sources/notpm linux
NOT_DIF=".cc"  bash $LFS/sources/notpm glibc
NOT_DIF=".cc-libstdc++"  bash $LFS/sources/notpm gcc
export NOT_DIF=".tt"
bash /mnt/lfs/sources/notpm m4
bash /mnt/lfs/sources/notpm ncurses
bash /mnt/lfs/sources/notpm bash
bash /mnt/lfs/sources/notpm coreutils
bash /mnt/lfs/sources/notpm diffutils
bash /mnt/lfs/sources/notpm file
bash /mnt/lfs/sources/notpm findutils
bash /mnt/lfs/sources/notpm gawk
bash /mnt/lfs/sources/notpm grep
bash /mnt/lfs/sources/notpm gzip
bash /mnt/lfs/sources/notpm make
bash /mnt/lfs/sources/notpm patch
bash /mnt/lfs/sources/notpm sed
bash /mnt/lfs/sources/notpm tar
bash /mnt/lfs/sources/notpm xz
bash /mnt/lfs/sources/notpm binutils
bash /mnt/lfs/sources/notpm gcc
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

echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd
echo "tester:x:101:" >> /etc/group
install -o tester -d /home/tester
exec /usr/bin/bash --login
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
END

mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm
umount $LFS/dev/pts
umount $LFS/{sys,proc,run,dev}
cd $LFS
tar -cpf ~/lfs-temp-tools-12.0.tar .

userdel -r lfs
[ ! -e /etc/bash.bashrc.NOUSE ] || mv -v /etc/bash.bashrc.NOUSE /etc/bash.bashrc
