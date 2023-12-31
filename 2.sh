#以root将文件放在/usr/sources中
chmod -v a+wt /usr/sources

useradd -s /bin/bash -m -k /dev/null lfs
#为什么-k /dev/null? https://blog.csdn.net/mjb115889/article/details/82115708

[ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE
su - lfs << "SU"
#The ' and ' around the END delimiter are important, otherwise things inside the block like for example $(command) will be parsed and executed.
#https://stackoverflow.com/questions/9712630/what-is-the-difference-between-eof-and-eof-in-shell-heredocs

cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

#主要变量在这，LFS_TGT设计为lfs而非pc是为了和build的程序分开且兼容 ''内的$,()会被当字符输出，所以注意makeflags的写法(""不会)
cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/home/lfs/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
MAKEFLAGS=-j$(cat /proc/cpuinfo | grep 'processor' | wc -l)
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE MAKEFLAGS
EOF

#source ~/.bash_profile在脚本中不可行， . ~/.bash_profile 虽然可以在当前shell进行，但是因为是在其开了的shell里运行.bashrc导致继续运行脚本时没有正确环境
#即使如同下一列，也没有读取bashrc 而若执行/bin/bash改成执行bashrc，不仅要解决权限问题，也将无法完成之后命令
env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash << "ENV"
. ~/.bashrc
mkdir -pv $LFS/{etc,var,lib,bin} $LFS/usr $LFS/tools/bin
ln -sv $LFS/lib $LFS/usr/lib
ln -sv $LFS/bin $LFS/sbin
ln -sv $LFS/bin $LFS/usr/bin
ln -sv $LFS/bin $LFS/usr/sbin

case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64
  ln -sv $LFS/lib $LFS/lib64
  ln -sv $LFS/lib $LFS/usr/lib64 ;;
esac

cat > $LFS/tools/bin/notpm << "EOF"
pushd /usr/sources
tar xvf $@*.tar.*
pushd $@*/
bash ../$@.sh$NOT_DIF
popd
popd
EOF

export NOT_DIF=".cc"
notpm binutils
notpm gcc
NOT_DIF=".cc-headers" notpm linux
notpm glibc
NOT_DIF=".cc-libstdc++" notpm gcc

export NOT_DIF=".tt"
for i in m4 ncurses bash coreutils diffutils file findutils gawk grep gzip make patch sed tar xz binutils gcc; do
notpm $i
done
mkdir $LFS/usr
cp /usr/sources/. $LFS/usr/sources

mv $LFS/tools/bin/notpm $LFS/bin
ENV
SU
[ ! -e /etc/bash.bashrc.NOUSE ] || mv -v /etc/bash.bashrc.NOUSE /etc/bash.bashrc
export LFS=/root/lfs
cp -r /home/lfs/lfs /root/lfs
chown -R root:root $LFS
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
    MAKEFLAGS=-j$(cat /proc/cpuinfo | grep 'processor' | wc -l) \
    /bin/bash --login << "CHROOT"
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

cat > /etc/hosts << EOF
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

for i in gettext bison perl Python texinfo util-linux; do
notpm $i
done

rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
rm -rf /tools

CHROOT

mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm
umount $LFS/dev/pts
umount $LFS/{sys,proc,run,dev}